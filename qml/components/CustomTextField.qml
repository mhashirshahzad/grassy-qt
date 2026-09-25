import QtQuick 2.15
import QtQuick.Controls 2.15
import "." 1.0

TextField {
    id: control

    property color borderColor: Theme.subtext
    property color focusBorderColor: Theme.accent

    implicitWidth: 280
    implicitHeight: 30
    hoverEnabled: true
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter

    leftPadding: 38
    rightPadding: 12

    color: Theme.text
    placeholderTextColor: Theme.subtext
    selectionColor: Theme.accent
    selectedTextColor: Theme.background

    background: Rectangle {
        anchors.fill: parent

        radius: 8

        color: Qt.rgba(
            Theme.surface.r,
            Theme.surface.g,
            Theme.surface.b,
            0.8
        )

        border.width: control.activeFocus ? 2 : control.hovered ? 1 : 0
        border.color: control.activeFocus
            ? control.focusBorderColor
            : Qt.rgba(
                  control.borderColor.r,
                  control.borderColor.g,
                  control.borderColor.b,
                  0.35
              )

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

        Behavior on border.width {
            NumberAnimation { duration: 120 }
        }
    }

    Image {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        width: 16
        height: 16

        source: "qrc:/qml/icons/magnify.svg"
        opacity: control.enabled ? (control.activeFocus ? 1 : 0.7) : 0.4

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }
}
