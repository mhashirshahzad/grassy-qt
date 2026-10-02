import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme" 1.0
import "../../components" 1.0
import Grassy 1.0
import ".."

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
    errorState: hasError

    width: Math.min(parent ? parent.width - 32 : 620, 620)
    height: content.implicitHeight + topPadding + bottomPadding

    ServerDownloader {
        id: downloader
    }

    function openFresh() {
        statusMessage = "Loading available versions..."
        downloading = false
        completed = false
        minecraftVersions = []
        loaderVersions = []
        installerVersions = []
        minecraftVersion = ""
        loaderVersion = ""
        installerVersion = ""
        downloader.refresh()
        root.open()
    }

    Connections {
        target: downloader
        function onMinecraftVersionsChanged(versions) {
            root.minecraftVersions = versions
            if (versions.length > 0) {
                root.minecraftVersion = versions[0]
                downloader.refreshLoaders(root.minecraftVersion)
            }
            root.statusMessage = ""
        }
        function onLoaderVersionsChanged(versions) {
            root.loaderVersions = versions
            root.loaderVersion = versions.length > 0 ? versions[0] : ""
        }
        function onInstallerVersionsChanged(versions) {
            root.installerVersions = versions
            root.installerVersion = versions.length > 0 ? versions[0] : ""
        }
        function onProgressChanged(progress) {
            progressBar.progressValue = progress
        }
        function onCompleted(folderName) {
            root.downloading = false
            root.completed = true
            root.statusMessage = "Installed " + folderName
            if (root.modelObject)
                root.modelObject.refresh()
        }
        function onFailed(message) {
            root.downloading = false
            root.completed = false
            root.statusMessage = "Error: " + message
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: 12

        Label {
            text: root.hasError ? root.statusMessage : "Add Fabric server"
            color: root.hasError ? Theme.failure : Theme.textBright
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            visible: !root.hasError
            text: "Download a Fabric server before it appears in your server list."
            color: Theme.subtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: "Minecraft version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ServerChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.minecraftVersions
            currentIndex: Math.max(0, root.minecraftVersions.indexOf(root.minecraftVersion))
            editText: root.minecraftVersion
            onTextEdited: function(value) { root.minecraftVersion = value }
            onActivated: function(value) {
                root.minecraftVersion = value
                downloader.refreshLoaders(value)
            }
        }

        Label {
            text: "Fabric loader version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ServerChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.loaderVersions
            currentIndex: Math.max(0, root.loaderVersions.indexOf(root.loaderVersion))
            editText: root.loaderVersion
            onTextEdited: function(value) { root.loaderVersion = value }
            onActivated: function(value) { root.loaderVersion = value }
        }

        Label {
            text: "Fabric installer version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ServerChoiceControl {
            Layout.fillWidth: true
            editable: true
            options: root.installerVersions
            currentIndex: Math.max(0, root.installerVersions.indexOf(root.installerVersion))
            editText: root.installerVersion
            onTextEdited: function(value) { root.installerVersion = value }
            onActivated: function(value) { root.installerVersion = value }
        }

        CustomLabeledProgressBar {
            id: progressBar
            visible: root.downloading
            Layout.fillWidth: true
            label: "Download progress"
            standaloneActive: true
            currentValue: progressBar.progressValue
            maximumValue: 1
            valueText: Math.round(progressBar.progressValue * 100) + "%"
            property real progressValue: 0
            progressStartColor: Theme.accent
            progressEndColor: Theme.accentHover
            labelColor: Theme.accent
            inactiveColor: Theme.surface3
        }

        Label {
            visible: root.completed && !root.downloading
            text: "fabric.jar installed; run the server to fetch mods and mc.jar."
            color: Theme.accent
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        ThemedButton {
            Layout.fillWidth: true
            text: root.downloading ? "Downloading..." : "Download server"
            enabled: !root.downloading && root.minecraftVersion.length > 0
                && root.loaderVersion.length > 0 && root.installerVersion.length > 0
            onClicked: {
                root.statusMessage = "Downloading..."
                root.downloading = true
                root.completed = false
                downloader.download("Fabric", root.minecraftVersion,
                                    root.loaderVersion, root.installerVersion)
            }
        }
    }

    onClosed: downloading = false
}
