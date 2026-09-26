import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../theme" 1.0
import "../popups" 1.0

Rectangle {
    id: card

    required property string serverName
    required property string serverMotd
    required property string serverFolder
    required property var modelObject
    property bool serverRunning: false

    signal startClicked()
    signal editClicked()
    signal settingsClicked()
    signal folderClicked()
    signal deleteClicked()

    implicitHeight: 100
    radius: 8
    color: Theme.surface
    border.color: Theme.surface
    border.width: 1

    width: ListView.view ? ListView.view.width: 0
    
    ColumnLayout {
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

        // Bottom row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: card.serverMotd
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
                text: card.serverRunning ? "Running" : "Start Server"
                buttonColor: card.serverRunning ? Theme.success : Theme.accent
                buttonHoverColor: card.serverRunning ? Theme.successHover : Theme.accentHover
                buttonPressedColor: card.serverRunning ? Theme.successMuted : Theme.accentPressed
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

    function openRenameDialog() {
        renameDialog.serverFolder = card.serverFolder
        renameDialog.serverName = card.serverName
        renameDialog.errorMessage = ""
        renameDialog.open()
    }

    function openSettingsDialog() {
        settingsDialog.serverFolder = card.serverFolder
        settingsDialog.propertiesText = card.modelObject
            ? card.modelObject.serverProperties(card.serverFolder)
            : ""
        settingsDialog.errorMessage = ""
        settingsDialog.open()
    }

    function openDeleteDialog() {
        deleteDialog.serverFolder = card.serverFolder
        deleteDialog.serverName = card.serverName
        deleteDialog.errorMessage = ""
        deleteDialog.open()
    }
}
