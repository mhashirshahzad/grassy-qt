import "../theme"
import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control

    property color buttonColor: Theme.accent
    property color buttonHoverColor: Theme.accentHover
    property color buttonPressedColor: Theme.accentPressed
    property color buttonTextColor: {
        if (buttonColor === Theme.failure) return Theme.onFailure;
        if (buttonColor === Theme.success) return Theme.onSuccess;
        if (buttonColor === Theme.warning) return Theme.onWarning;
        return Theme.onAccent;
    }
    property int radius: Theme.radius

    hoverEnabled: true
    padding: 10
    leftPadding: 14
    rightPadding: 14
    scale: !control.enabled ? 1.0 : control.pressed ? 0.93 : control.hovered ? 1.04 : 1.0

    contentItem: Text {
        text: control.text
        color: control.enabled ? control.buttonTextColor : Theme.disabledText
        font.bold: true
        font.family: Theme.fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: control.radius
        color: control.pressed ? control.buttonPressedColor : control.hovered ? control.buttonHoverColor : control.buttonColor
        opacity: control.enabled ? 1 : 0.5

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutBack
            easing.overshoot: 2.0
        }
    }

}
