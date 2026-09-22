import QtQuick 2.15
import QtQuick.Controls 2.15
import "."

TextField {
    id: control

    property color borderColor: Theme.subtext
    property color focusBorderColor: Theme.accent

    implicitWidth: 240
    implicitHeight: 24

    leftPadding: 12
    rightPadding: 12

    color: Theme.text
    placeholderTextColor: Theme.subtext
    selectionColor: Theme.accent
    selectedTextColor: Theme.background

    background: Rectangle {
        radius: 8

        color: Qt.rgba(
            Theme.surface.r,
            Theme.surface.g,
            Theme.surface.b,
            0.8
        )

        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
            ? control.focusBorderColor
            : control.borderColor

        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }
    }
}
