import "../theme" 1.0
import QtQuick 2.15

Item {
    id: root

    property int currentIndex: 0
    property var tabs: []
    property color barColor: Theme.surface0
    property color selectedColor: Theme.accentMuted
    property color hoverColor: Theme.surface2
    property color textColor: Theme.text
    property color selectedTextColor: Theme.textBright
    property bool hovered: tabHover.hovered

    implicitHeight: 32
    implicitWidth: tabRow.implicitWidth

    // Bar hover indicator
    Rectangle {
        anchors.top : parent.top
        anchors.horizontalCenter : parent.horizontalCenter
        radius: 6
        width: 200
        height: 3
        opacity: root.hovered ? 0 : 1
        color: Theme.border
        
    }
    
    // Border
    Rectangle {
        opacity: root.hovered ? 1 : 0
        anchors.fill: parent
        color: root.barColor
        radius: 6
        border.color: Theme.border
    }

    HoverHandler {
        id: tabHover
    }

    Row {
        opacity: root.hovered ? 1 : 0
        id: tabRow

        anchors.fill: parent
        anchors.margins: 2
        spacing: 2

        Repeater {
            model: root.tabs

            delegate: Item {
                id: tab

                required property int index
                required property string modelData

                width: Math.max(76, tabLabel.implicitWidth + 24)
                height: tabRow.height

                Rectangle {
                    anchors.fill: parent
                    color: root.currentIndex === tab.index ? root.selectedColor : tabMouse.containsMouse ? root.hoverColor : "transparent"
                    radius: 4

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                        }
                    }
                }

                Text {
                    id: tabLabel

                    anchors.centerIn: parent
                    text: tab.modelData
                    color: root.currentIndex === tab.index ? root.selectedTextColor : root.textColor
                    font.bold: root.currentIndex === tab.index
                    font.pixelSize: 12
                }

                MouseArea {
                    id: tabMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.currentIndex = tab.index
                }
            }
        }
    }
}
