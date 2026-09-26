import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0
import "../components" 1.0
import "." 1.0

CustomPopup {
    id: root

    property var modelObject
    property string serverFolder
    property string serverName
    property string errorMessage

    width: 460
    height: 280

    function accept() {
        if (!root.modelObject
                || !root.modelObject.deleteServer(root.serverFolder)) {
            root.errorMessage = "Could not delete the server folder."
            return
        }
        root.close()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Label {
            text: "Delete server ?"
            font.pixelSize: 20
            font.bold: true
        }

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/icons/warning.svg"
            sourceSize: Qt.size(64, 64)
        }

        Label {
            Layout.fillWidth: true
            font.pixelSize: 16
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

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: 8
            Layout.fillWidth : true


            ThemedButton {
                text: "Delete?"
                Layout.fillWidth: true
                buttonColor: Theme.failure
                buttonHoverColor: Theme.failureHover
                buttonPressedColor: Theme.failureMuted
                onClicked: root.accept()
            }
        }
    }
}
