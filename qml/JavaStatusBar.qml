import QtQuick 2.15
import "." 1.0

Rectangle {
    id: root

    height: 32
    color: Theme.surface
    property bool javaInstalled: utils.isJavaInstalled()

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
            font.pixelSize: 13
        }
    }
}
