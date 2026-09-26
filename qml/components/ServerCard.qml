import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../theme" 1.0

Rectangle {
    id: card

    required property string serverName
    required property string serverMotd
    required property string serverFolder
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

                onClicked: card.deleteClicked()
            }

            IconButton {
                iconSource: "qrc:/icons/edit.svg"
                ToolTip.text: "Edit Server"
                ToolTip.visible: hovered
                enabled: !card.serverRunning

                onClicked: card.editClicked()
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
}
