import QtQuick 2.15

MouseArea {
    id: root

    property Item targetItem: parent
    property real hoverScale: 1.04
    property real pressScale: 0.93
    property real normalScale: 1.0
    property bool enableWobble: true

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    JoyWobble {
        id: wobble
        targetItem: root.targetItem
    }

    function triggerWobble() {
        wobble.restart();
    }
}
