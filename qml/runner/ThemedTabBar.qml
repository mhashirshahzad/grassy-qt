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

    implicitHeight: 42
    implicitWidth: tabRow.implicitWidth

    Rectangle {
        anchors.fill: parent
        color: root.barColor
        radius: 6
        border.color: Theme.border
    }

    Row {
        id: tabRow

        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        Repeater {
            model: root.tabs

            delegate: Item {
                id: tab

                required property int index
                required property string modelData

                width: Math.max(110, tabLabel.implicitWidth + 28)
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
                }

                Text {
                    id: tabLabel

                    anchors.centerIn: parent
                    text: tab.modelData
                    color: root.currentIndex === tab.index ? root.selectedTextColor : root.textColor
                    font.bold: root.currentIndex === tab.index
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
