import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Dialog {
    id: root

    property var modelObject
    property string serverFolder
    property string propertiesText
    property string errorMessage

    title: "Edit server.properties"
    modal: true
    standardButtons: Dialog.Save | Dialog.Cancel
    anchors.centerIn: parent

    onAccepted: {
        if (!root.modelObject
                || !root.modelObject.saveServerProperties(
                    root.serverFolder, root.propertiesText)) {
            root.errorMessage = "Could not save server.properties."
            open()
        }
    }

    ColumnLayout {
        width: 620
        height: 420
        spacing: 8

        Label {
            text: "Changes apply the next time the server starts."
            color: Theme.subtext
        }

        TextArea {
            id: propertiesEditor
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.propertiesText
            wrapMode: TextEdit.NoWrap
            font.family: Theme.monoFamily
            color: Theme.text
            selectByMouse: true
            background: Rectangle {
                color: Theme.surface0
                border.color: Theme.border
                radius: 6
            }
            onTextChanged: root.propertiesText = text
        }

        Label {
            text: root.errorMessage
            color: Theme.failure
            visible: text.length > 0
        }
    }
}
