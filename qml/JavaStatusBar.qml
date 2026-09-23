import QtQuick 2.15
import "." 1.0

Rectangle {
    id: root

    height: 32
    color: Theme.surface
    property bool javaInstalled: utils ?  utils.javaInstalled : false

     // Top separator
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.overlay
        z: 1
    }
    // Subtle shadow above the footer
    Rectangle {
        anchors.bottom: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 4
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.16) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.0) }
        }
        z: -1
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: root.javaInstalled ? Theme.success : Theme.failure
        }


        Text {
            text: root.javaInstalled ? "Java detected" : "Java not found"

            color: Theme.text
            font.pixelSize: 12
            font.bold: true
        }
    }
}
