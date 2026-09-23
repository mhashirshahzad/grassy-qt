import QtQuick 2.15
import QtQuick.Controls 2.15
import "." 1.0

Rectangle {
    id: root

    required property Window window

    height: 40
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

    }


    Item {
        id: center
        anchors.left: left.right
        anchors.right: right.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        height: 32

        CustomTextField {
            id: searchField
            
            anchors.fill: parent
            placeholderText: "Search for servers..."
            font.pixelSize: 12
            onTextChanged: serverModel.setSearchText(text)
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
    
    // seperator
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.overlay
        z: 1
    }
    
}
