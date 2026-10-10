import "../theme"
import QtQuick 2.15

Item {
    id: control

    property bool checked: false

    signal toggled(bool checked)

    implicitWidth: 52
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusPill > 0 ? height / 2 : Theme.radiusSmall
        color: control.checked ? Theme.accent : Theme.surface0
        border.color: toggleMouse.containsMouse ? Theme.borderHover : Theme.border
        border.width: 1

        Rectangle {
            id: thumb
            width: toggleMouse.pressed ? 25 : 22
            height: 22
            radius: Theme.radiusPill > 0 ? height / 2 : Theme.radiusSmall
            anchors.verticalCenter: parent.verticalCenter
            x: control.checked ? parent.width - width - 4 : 4
            color: control.checked ? Theme.onAccent : Theme.text

            Behavior on x {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 140
                }
            }

            Behavior on radius {
                NumberAnimation {
                    duration: 180
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 140
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 180
            }
        }
    }

    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.toggled(!control.checked)
    }
}
