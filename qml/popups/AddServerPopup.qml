import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0
import "../components" 1.0
import Grassy 1.0
import "."

CustomPopup {
    id: root

    property var modelObject
    property string kind: "Minecraft"
    property string minecraftVersion: ""
    property string loaderVersion: ""
    property string installerVersion: ""
    property string statusMessage: ""
    property bool downloading: false
    property var minecraftVersions: []
    property var loaderVersions: []
    property var installerVersions: []
    property bool hasError: statusMessage.startsWith("Error")
    errorState: hasError

    width: Math.min(parent ? parent.width - 32 : 620, 620)
    height: Math.min(parent ? parent.height - 32 : 620, 620)

    ServerDownloader {
        id: downloader
    }

    function openFresh() {
        statusMessage = "Loading available versions..."
        downloading = false
        minecraftVersions = []
        loaderVersions = []
        installerVersions = []
        kind = "Minecraft"
        downloader.refresh()
        root.open()
    }

    function startDownload() {
        statusMessage = "Downloading..."
        downloading = true
        downloader.download(kind, minecraftVersion, loaderVersion, installerVersion)
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
            root.statusMessage = "Installed " + folderName
            if (root.modelObject)
                root.modelObject.refresh()
        }
        function onFailed(message) {
            root.downloading = false
            root.statusMessage = "Error: " + message
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Label {
            text: root.hasError ? root.statusMessage : "Add server"
            color: root.hasError ? Theme.failure : Theme.textBright
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            visible: !root.hasError
            text: "Download a server before it appears in your server list."
            color: Theme.subtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: "Server type"
            color: Theme.text
            Layout.fillWidth: true
        }

        ServerChoiceControl {
            Layout.fillWidth: true
            options: ["Minecraft", "Fabric", "Forge"]
            currentIndex: ["Minecraft", "Fabric", "Forge"].indexOf(root.kind)
            onActivated: function(value) {
                root.kind = value
            }
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
            visible: root.kind === "Fabric"
            text: "Fabric loader version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ServerChoiceControl {
            visible: root.kind === "Fabric"
            Layout.fillWidth: true
            editable: true
            options: root.loaderVersions
            currentIndex: Math.max(0, root.loaderVersions.indexOf(root.loaderVersion))
            editText: root.loaderVersion
            onTextEdited: function(value) { root.loaderVersion = value }
            onActivated: function(value) { root.loaderVersion = value }
        }

        Label {
            visible: root.kind === "Fabric"
            text: "Fabric installer version"
            color: Theme.text
            Layout.fillWidth: true
        }

        ServerChoiceControl {
            visible: root.kind === "Fabric"
            Layout.fillWidth: true
            editable: true
            options: root.installerVersions
            currentIndex: Math.max(0, root.installerVersions.indexOf(root.installerVersion))
            editText: root.installerVersion
            onTextEdited: function(value) { root.installerVersion = value }
            onActivated: function(value) { root.installerVersion = value }
        }

        Label {
            visible: root.kind === "Forge"
            text: "Forge downloads are not available yet."
            color: Theme.warning
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
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

        // Label {
        //     id: statusLabel
        //     text: root.statusMessage
        //     color: root.hasError ? Theme.failure : Theme.subtext
        //     visible: text.length > 0 && !root.hasError
        //     wrapMode: Text.WordWrap
        //     Layout.fillWidth: true
        // }

        Item { Layout.fillHeight: true }

        ThemedButton {
            Layout.fillWidth: true
            text: root.downloading ? "Downloading..." : "Download server"
            enabled: !root.downloading && root.kind !== "Forge"
                && root.minecraftVersion.length > 0
                && (root.kind !== "Fabric"
                    || (root.loaderVersion.length > 0 && root.installerVersion.length > 0))
            onClicked: root.startDownload()
        }
    }

    onClosed: downloading = false
}
