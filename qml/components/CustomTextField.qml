import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0

TextField {
    id: control

    property color borderColor: Theme.subtext
    property color focusBorderColor: Theme.accent
    property color backgroundColor: Theme.surface2
    property bool showSearchIcon: true

    implicitWidth: 280
    implicitHeight: 30
    hoverEnabled: true
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter

    leftPadding: showSearchIcon ? 38 : 12
    rightPadding: 12

    color: Theme.text
    placeholderTextColor: Theme.subtext
    selectionColor: Theme.accent
    selectedTextColor: Theme.background

    background: Rectangle {
        anchors.fill: parent

        radius: 8

        color: control.backgroundColor

        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
            ? control.focusBorderColor : control.borderColor
    }

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
            NumberAnimation { duration: 120 }
        }
    }
}
