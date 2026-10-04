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
    property string loaderVersion: ""
    property string installerVersion: ""
    property string statusMessage: ""
    property bool downloading: false
    property bool completed: false
    property var minecraftVersions: []
    property var loaderVersions: []
    property var installerVersions: []
    property bool hasError: statusMessage.startsWith("Error")

    signal installationCompleted()

    function openFresh() {
        statusMessage = "Loading available versions...";
        downloading = false;
        completed = false;
        minecraftVersions = [];
        loaderVersions = [];
        installerVersions = [];
        minecraftVersion = "";
        loaderVersion = "";
        installerVersion = "";
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
                downloader.refreshLoaders(root.minecraftVersion);
            }
            root.statusMessage = "";
        }

        function onLoaderVersionsChanged(versions) {
            root.loaderVersions = versions;
            root.loaderVersion = versions.length > 0 ? versions[0] : "";
        }

        function onInstallerVersionsChanged(versions) {
            root.installerVersions = versions;
            root.installerVersion = versions.length > 0 ? versions[0] : "";
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
            text: root.completed ? "Server Downloaded!" : root.hasError ? root.statusMessage : "Add Fabric server"
            color: root.hasError ? Theme.failure : root.completed ? Theme.accent : Theme.textBright
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            visible: !root.hasError
            text: "Download a Fabric server inside your servers folder"
            color: Theme.subtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            visible: !root.hasError
            text: "<b>Run the server at least once after downloading to fetch the required libraries.</b>"
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
                downloader.refreshLoaders(value);
            }
        }

        Label {
            text: "Fabric loader version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.loaderVersions
            currentIndex: Math.max(0, root.loaderVersions.indexOf(root.loaderVersion))
            editText: root.loaderVersion
            onTextEdited: function(value) {
                root.loaderVersion = value;
            }
            onActivated: function(value) {
                root.loaderVersion = value;
            }
        }

        Label {
            text: "Fabric installer version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.installerVersions
            currentIndex: Math.max(0, root.installerVersions.indexOf(root.installerVersion))
            editText: root.installerVersion
            onTextEdited: function(value) {
                root.installerVersion = value;
            }
            onActivated: function(value) {
                root.installerVersion = value;
            }
        }

        CustomLabeledProgressBar {
            id: progressBar

            property real progressValue: 0

            visible: root.downloading
            Layout.fillWidth: true
            label: "Download progress"
            standaloneActive: true
            currentValue: progressBar.progressValue
            maximumValue: 1
            valueText: Math.round(progressBar.progressValue * 100) + "%"
            progressStartColor: Theme.accent
            progressEndColor: Theme.accentHover
            labelColor: Theme.accent
            inactiveColor: Theme.surface3
        }

        Label {
            visible: root.completed && !root.downloading
            text: "<b>Run the server at least once to fetch the required libraries and Minecraft server jar.</b>"
            textFormat: Text.RichText
            color: Theme.accent
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }

        ThemedButton {
            Layout.fillWidth: true
            text: root.downloading ? "Downloading..." : "Download server"
            enabled: !root.downloading && root.minecraftVersion.length > 0 && root.loaderVersion.length > 0 && root.installerVersion.length > 0
            onClicked: {
                root.statusMessage = "Downloading...";
                root.downloading = true;
                root.completed = false;
                downloader.download("Fabric", root.minecraftVersion, root.loaderVersion, root.installerVersion);
            }
        }

    }

}
