import QtQuick 2.15
import QtQuick.Window 2.15
import "." 1.0

Window {
    id: root
    title: "Grassy Qt"

    visible: true
    width: 800
    height: 600
    color: Theme.background

    CustomTitleBar {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        window: root
    }

    JavaStatusBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom : parent.bottom

    }
}
