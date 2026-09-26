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

    title: "Delete server"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent

    onAccepted: {
        if (!root.modelObject
                || !root.modelObject.deleteServer(root.serverFolder)) {
            root.errorMessage = "Could not delete the server folder."
            open()
        }
    }

    ColumnLayout {
        width: 400
        spacing: 12

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/icons/warning.svg"
            sourceSize: Qt.size(48, 48)
        }

        Label {
            Layout.fillWidth: true
            text: "Delete \"%1\" and all of its files permanently?"
                .arg(root.serverName)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            text: root.errorMessage
            color: Theme.failure
            visible: text.length > 0
        }
    }
}
