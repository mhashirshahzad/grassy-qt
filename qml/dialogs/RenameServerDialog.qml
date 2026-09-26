import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Dialog {
    id: root

    property var modelObject
    property string serverFolder
    property string serverName
    property string errorMessage

    title: "Rename server folder"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent

    onAccepted: {
        if (!root.modelObject
                || !root.modelObject.renameServer(
                    root.serverFolder, root.serverName)) {
            root.errorMessage = "Could not rename the server folder."
            open()
        }
    }

    ColumnLayout {
        width: 360
        spacing: 10

        Label {
            text: "New folder name"
        }

        TextField {
            id: renameField
            Layout.fillWidth: true
            text: root.serverName
            onTextChanged: root.serverName = text
            Component.onCompleted: selectAll()
        }

        Label {
            text: root.errorMessage
            color: Theme.failure
            visible: text.length > 0
        }
    }
}
