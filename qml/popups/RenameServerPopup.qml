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
    errorState: errorMessage.length > 0

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

    onOpened: {
        renameField.forceActiveFocus()
        renameField.selectAll()
    }
    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: root.opened
        context: Qt.WindowShortcut
        onActivated : root.accept()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            text: root.errorMessage.length > 0 ? root.errorMessage : "Rename server folder ?"
            font.pixelSize: 20
            font.bold: true
            color: root.errorMessage.length > 0 ? Theme.failure : Theme.textBright
        }

        CustomTextField {
            id: renameField
            Layout.fillWidth: true
            showSearchIcon: false
            text: root.serverName
            onTextChanged: root.serverName = text
        }

        Label {
            text: root.errorMessage
            color: Theme.failure
            visible: false
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8


            Layout.fillWidth : true

            ThemedButton {
                Layout.fillWidth : true
                text: "Rename (Enter)"
                onClicked: root.accept()
            }
        }
    }
}
