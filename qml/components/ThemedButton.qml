import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0

Button {
    id: control

    property color buttonColor: Theme.accent
    property color buttonHoverColor: Theme.accentHover
    property color buttonPressedColor: Theme.accentPressed
    property color buttonTextColor: "#000000"

    hoverEnabled: true
    padding: 10
    leftPadding: 14
    rightPadding: 14

    contentItem: Text {
        text: control.text
        color: control.enabled ? control.buttonTextColor : Theme.disabledText
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 7
        color: control.pressed
            ? control.buttonPressedColor
            : control.hovered
                ? control.buttonHoverColor
                : control.buttonColor
        opacity: control.enabled ? 1 : 0.5

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }

    scale: control.hovered ? 1.03 : 1

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutBack
        }
    }

}
