import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "." 1.0

Rectangle {
    id: card

    required property string serverName
    required property string serverMotd
    required property string serverFolder

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

            ToolButton {
                icon.name: "user-trash-symbolic"
                ToolTip.text: "Delete Server"
                ToolTip.visible: hovered

                onClicked: card.deleteClicked()
            }

            ToolButton {
                icon.name: "document-edit-symbolic"
                ToolTip.text: "Edit Server"
                ToolTip.visible: hovered

                onClicked: card.editClicked()
            }

            ToolButton {
                icon.name: "folder-open-symbolic"
                ToolTip.text: "Open Server Folder"
                ToolTip.visible: hovered

                onClicked: card.folderClicked()
            }

            ToolButton {
                icon.name: "emblem-system-symbolic"
                ToolTip.text: "Server Settings"
                ToolTip.visible: hovered

                onClicked: card.settingsClicked()
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

            Button {
                text: "Start Server"
                highlighted: true

                onClicked: card.startClicked()
            }
        }
    }
}
