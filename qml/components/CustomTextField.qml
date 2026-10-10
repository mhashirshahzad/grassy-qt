import "../theme"
import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: control

    property color borderColor: Theme.subtext
    property color focusBorderColor: Theme.accent
    property color backgroundColor: Theme.surface0
    property bool showSearchIcon: true
    property int radius: Theme.radius

    implicitWidth: 280
    implicitHeight: 30
    hoverEnabled: true
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: TextInput.AlignLeft
    leftPadding: showSearchIcon ? 38 : 12
    rightPadding: 12
    color: Theme.text
    placeholderTextColor: Theme.subtext
    selectionColor: Theme.accent
    selectedTextColor: Theme.onAccent

    Image {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        source: "qrc:/icons/magnify.svg"
        visible: control.showSearchIcon
        opacity: control.enabled ? (control.activeFocus ? 1 : 0.7) : 0.4

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }

        }

    }

    background: Rectangle {
        anchors.fill: parent
        radius: control.radius
        color: control.backgroundColor
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? control.focusBorderColor : control.borderColor

        Behavior on border.color {
            ColorAnimation { duration: 140 }
        }
        Behavior on radius {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

}
