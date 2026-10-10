import QtQuick 2.15

SequentialAnimation {
    id: root

    property Item targetItem: parent

    NumberAnimation {
        target: root.targetItem
        property: "scale"
        to: 1.15
        duration: 90
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        target: root.targetItem
        property: "scale"
        to: 0.94
        duration: 90
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        target: root.targetItem
        property: "scale"
        to: 1.00
        duration: 120
        easing.type: Easing.OutBack
        easing.overshoot: 1.6
    }
}
