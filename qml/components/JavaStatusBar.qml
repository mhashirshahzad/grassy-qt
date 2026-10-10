import "../theme"
import QtQuick 2.15

Rectangle {
    id: root

    property bool javaInstalled: typeof utils !== "undefined" && utils ? utils.javaInstalled : false

    height: 32
    color: Theme.surface

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
        z: -1

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(0, 0, 0, 0.16)
            }

            GradientStop {
                position: 1
                color: Qt.rgba(0, 0, 0, 0)
            }

        }

    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: Theme.radiusPill > 0 ? 4 : 0
            color: root.javaInstalled ? Theme.success : Theme.failure

            Behavior on radius { NumberAnimation { duration: 180 } }
        }

        Text {
            text: root.javaInstalled ? "Java detected" : "Java not found"
            color: root.javaInstalled ? Theme.text : Theme.failureText
            font.pixelSize: 12
            font.bold: true
        }

    }

}
