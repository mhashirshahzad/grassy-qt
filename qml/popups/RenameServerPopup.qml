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

    width: 420
    height: 160

    function accept() {
        if (!root.modelObject
                || !root.modelObject.renameServer(
                    root.serverFolder, root.serverName)) {
            root.errorMessage = "Could not rename the server folder."
            return
        }
        root.close()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            text: "Rename server folder ?"
            font.pixelSize: 20
            font.bold: true
        }

        CustomTextField {
            id: renameField
            Layout.fillWidth: true
            showSearchIcon: false
            text: root.serverName
            onTextChanged: root.serverName = text
            Component.onCompleted: selectAll()
        }

        Label {
            text: root.errorMessage
            color: Theme.failure
            visible: text.length > 0
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8


            Layout.fillWidth : true

            ThemedButton {
                Layout.fillWidth : true
                text: "Rename"
                onClicked: root.accept()
            }
        }
    }
}
