import QtQuick 2.15
import QtQuick.Window 2.15
// import QtQuick.Controls 2.15

import "." 1.0

Window {
    id: root
    title: "Grassy Qt"

    visible: true
    width: 800
    height: 600
    color: Theme.background


    CustomTitleBar {
        id: customTitleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        window: root

        z: 10
        onReloadClicked: serverModel.refresh()
    }

    ListView {
        id: serverList
        anchors.top: customTitleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: javaStatusBar.top
        anchors.margins: 12
        spacing: 12
        model: serverModel

        delegate: ServerCard {
            required property string name
            required property string motd
            required property string folder
            serverName: name
            serverMotd: motd
            serverFolder: folder
        }

        // ScrollBar.vertical: ScrollBar {
        //     policy: ScrollBar.AlwaysOn
        // }
    }
    JavaStatusBar {
        id: javaStatusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom : parent.bottom

    }
    
}
