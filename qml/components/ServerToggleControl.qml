import QtQuick 2.15
import "../theme" 1.0

Item {
    id: control

    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 52
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: control.checked ? Theme.accent : Theme.surface3
        border.color: control.checked ? Theme.accentHover : Theme.borderHover
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }

        Rectangle {
            width: 22
            height: 22
            radius: 11
            anchors.verticalCenter: parent.verticalCenter
            x: control.checked ? parent.width - width - 3 : 3
            color: control.checked ? Theme.background : Theme.text

            Behavior on x {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: control.toggled(!control.checked)
    }
}
