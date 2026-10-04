import "../popups"
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: card

    required property string serverName
    required property string serverMotd
    required property string serverFolder
    property string serverMetadata: ""
    property string serverType: "Minecraft"
    property bool installRequired: false
    required property var modelObject
    property bool serverRunning: false

    signal startClicked()
    signal editClicked()
    signal settingsClicked()
    signal folderClicked()
    signal deleteClicked()

    function openRenameDialog() {
        renameDialog.serverFolder = card.serverFolder;
        renameDialog.serverName = card.serverName;
        renameDialog.errorMessage = "";
        renameDialog.open();
    }

    function openSettingsDialog() {
        settingsDialog.serverFolder = card.serverFolder;
        settingsDialog.errorMessage = "";
        settingsDialog.open();
    }

    function openDeleteDialog() {
        deleteDialog.serverFolder = card.serverFolder;
        deleteDialog.serverName = card.serverName;
        deleteDialog.errorMessage = "";
        deleteDialog.open();
    }

    implicitHeight: content.implicitHeight + 24
    radius: 8
    color: Theme.surface
    border.color: Theme.surface
    border.width: 1
    width: ListView.view ? ListView.view.width : 0

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Top row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: card.serverName
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }

            IconButton {
                iconSource: "qrc:/icons/delete.svg"
                destructive: true
                ToolTip.text: "Delete Server"
                ToolTip.visible: hovered
                enabled: !card.serverRunning
                onClicked: card.openDeleteDialog()
            }

            IconButton {
                iconSource: "qrc:/icons/edit.svg"
                ToolTip.text: "Edit Server"
                ToolTip.visible: hovered
                enabled: !card.serverRunning
                onClicked: card.openRenameDialog()
            }

            IconButton {
                iconSource: "qrc:/icons/folder.svg"
                ToolTip.text: "Open Server Folder"
                ToolTip.visible: hovered
                onClicked: card.folderClicked()
            }

            IconButton {
                iconSource: "qrc:/icons/settings.svg"
                ToolTip.text: "Server Settings"
                ToolTip.visible: hovered
                onClicked: card.openSettingsDialog()
            }

        }

        Label {
            text: "Motd: " + card.serverMotd
            color: Theme.subtext
            elide: Text.ElideRight
            font.pixelSize: 14
            Layout.fillWidth: true
        }

        // Bottom row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "MetaData: " + card.serverMetadata
                color: Theme.subtext
                font.pixelSize: 11
                opacity: 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: card.serverRunning ? Theme.success : Theme.subtext2
            }

            ThemedButton {
                text: card.serverRunning ? "Running" : (card.installRequired ? "Install Server" : "Start Server")
                buttonColor: card.installRequired ? Theme.warning : card.serverRunning ? Theme.success : Theme.accent
                buttonHoverColor: card.installRequired ? Theme.warningHover : card.serverRunning ? Theme.successHover : Theme.accentHover
                buttonPressedColor: card.installRequired ? Theme.warningMuted : card.serverRunning ? Theme.successMuted : Theme.accentPressed
                onClicked: card.startClicked()
            }

        }

    }

    RenameServerPopup {
        id: renameDialog

        parent: Overlay.overlay
        modelObject: card.modelObject
        serverFolder: card.serverFolder
        serverName: card.serverName
        anchors.centerIn: parent
    }

    ServerSettingsPopup {
        id: settingsDialog

        parent: Overlay.overlay
        modelObject: card.modelObject
        serverFolder: card.serverFolder
        anchors.centerIn: parent
    }

    DeleteServerPopup {
        id: deleteDialog

        parent: Overlay.overlay
        modelObject: card.modelObject
        serverFolder: card.serverFolder
        serverName: card.serverName
        anchors.centerIn: parent
    }

}
