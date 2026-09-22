import QtQuick 2.15
import QtQuick.Controls 2.15
import "." 1.0

Rectangle {
    id: root

    required property Window window

    height: 32
    color: Theme.surface

    signal settingsClicked()
    signal searchClicked()
    signal reloadClicked()
    signal addServerClicked()

    // Left side
    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        IconButton {
            iconSource: "qrc:/qml/icons/cog.svg"
            onClicked: root.settingsClicked()
        }

        IconButton {
            iconSource: "qrc:/qml/icons/magnify.svg"
            onClicked: root.searchClicked()
        }
    }


    Row {
        id: center
        anchors.centerIn: parent

        CustomTextField {
            placeholderText: "Search for servers..."
        }
    }

    // Right side
    Row {
        id: right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        IconButton {
            iconSource: "qrc:/qml/icons/refresh.svg"
            onClicked: root.reloadClicked()
        }

        IconButton {
            iconSource: "qrc:/qml/icons/plus.svg"
            onClicked: root.addServerClicked()
        }
    }
}
