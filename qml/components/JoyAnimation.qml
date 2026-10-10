import QtQuick 2.15

QtObject {
    id: root

    readonly property int springDur: 260
    readonly property int easeDur: 140
    readonly property int squishDur: 90
    readonly property int wobbleDur: 300
    readonly property int popDur: 200

    readonly property real springOvershoot: 1.8
    readonly property real popOvershoot: 2.2
}
