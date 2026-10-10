import ".."
import "../../components" 1.0
import "../../theme" 1.0
import Grassy 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

CustomPopup {
    id: root

    property var modelObject
    property string minecraftVersion: ""
    property string forgeVersion: ""
    property string statusMessage: ""
    property bool downloading: false
    property bool completed: false
    property var minecraftVersions: []
    property var forgeVersions: []
    property bool hasError: statusMessage.startsWith("Error")

    signal installationCompleted()

    function openFresh() {
        statusMessage = "Loading available versions...";
        downloading = false;
        completed = false;
        minecraftVersions = [];
        forgeVersions = [];
        minecraftVersion = "";
        forgeVersion = "";
        downloader.refresh();
        root.open();
    }

    errorState: hasError
    successState: completed && !hasError
    width: Math.min(parent ? parent.width - 32 : 620, 620)
    height: content.implicitHeight + topPadding + bottomPadding
    onClosed: downloading = false

    Timer {
        id: closeTimer

        interval: 1000
        repeat: false
        onTriggered: root.close()
    }

    ServerDownloader {
        id: downloader
    }

    Connections {
        function onMinecraftVersionsChanged(versions) {
            root.minecraftVersions = versions;
            if (versions.length > 0) {
                root.minecraftVersion = versions[0];
                downloader.refreshForgeVersions(root.minecraftVersion);
            }
            root.statusMessage = "";
        }

        function onForgeVersionsChanged(versions) {
            root.forgeVersions = versions;
            root.forgeVersion = versions.length > 0 ? versions[0] : "";
        }

        function onProgressChanged(progress) {
            progressBar.progressValue = progress;
        }

        function onCompleted(folderName) {
            root.downloading = false;
            root.completed = true;
            root.statusMessage = "Installed " + folderName;
            if (root.modelObject)
                root.modelObject.refresh();

            root.installationCompleted();
            closeTimer.start();
        }

        function onFailed(message) {
            root.downloading = false;
            root.completed = false;
            root.statusMessage = "Error: " + message;
        }

        target: downloader
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 12

        Label {
            text: root.completed ? "Server Downloaded!" : root.hasError ? root.statusMessage : "Add Forge server"
            color: root.hasError ? Theme.failureText : root.completed ? Theme.accent : Theme.textBright
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            visible: !root.hasError
            text: "Download a Forge server inside your servers folder"
            color: Theme.subtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            visible: !root.hasError
            text: "<b>Run the server at least once after downloading to install Forge and fetch the required libraries.</b>"
            textFormat: Text.RichText
            color: Theme.warning
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: "Minecraft version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.minecraftVersions
            currentIndex: Math.max(0, root.minecraftVersions.indexOf(root.minecraftVersion))
            editText: root.minecraftVersion
            onTextEdited: function(value) {
                root.minecraftVersion = value;
            }
            onActivated: function(value) {
                root.minecraftVersion = value;
                root.forgeVersion = "";
                downloader.refreshForgeVersions(value);
            }
        }

        Label {
            text: "Forge version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.forgeVersions
            currentIndex: Math.max(0, root.forgeVersions.indexOf(root.forgeVersion))
            editText: root.forgeVersion
            onTextEdited: function(value) {
                root.forgeVersion = value;
            }
            onActivated: function(value) {
                root.forgeVersion = value;
            }
        }

        CustomLabeledProgressBar {
            id: progressBar

            property real progressValue: 0

            visible: root.downloading
            Layout.fillWidth: true
            label: "Download progress"
            standaloneActive: true
            currentValue: progressValue
            maximumValue: 1
            valueText: Math.round(progressValue * 100) + "%"
            progressStartColor: Theme.accent
            progressEndColor: Theme.accentHover
            labelColor: Theme.accent
            inactiveColor: Theme.surface3
        }

        Item {
            Layout.fillHeight: true
        }

        ThemedButton {
            Layout.fillWidth: true
            text: root.downloading ? "Downloading..." : "Download server"
            enabled: !root.downloading && root.minecraftVersion.length > 0 && root.forgeVersion.length > 0
            onClicked: {
                root.statusMessage = "Downloading and installing...";
                root.downloading = true;
                root.completed = false;
                downloader.download("Forge", root.minecraftVersion, root.forgeVersion);
            }
        }

    }

}
