import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import "../theme" 1.0

Item {
    id: root

    property color transitionColor: Theme.background
    property real progress: 0
    property bool running: false

    anchors.fill: parent
    visible: running
    z: 1000

    // Old theme covering the new theme
    Rectangle {
        id: transitionLayer
        anchors.fill: parent
        color: root.transitionColor
    }

    // Expanding transparent hole (mask source, hidden from render via ShaderEffectSource)
    Rectangle {
        id: revealMask

        x: root.progress * root.width - width / 2
        y: root.progress * root.height - height / 2

        width: root.progress * root.diagonal * 2
        height: width
        radius: width / 2

        color: "white"
    }

    readonly property real diagonal: Math.hypot(root.width, root.height)

    ShaderEffectSource {
        id: revealMaskSource
        sourceItem: revealMask
        hideSource: true
        live: true
    }

    OpacityMask {
        anchors.fill: parent

        source: transitionLayer
        maskSource: revealMaskSource
        invert: true
    }

    Connections {
        target: Theme

        function onThemeTransitionRequested(oldBackground) {
            root.transitionColor = oldBackground
            root.progress = 0
            root.running = true

            revealAnimation.restart()
        }
    }

    NumberAnimation {
        id: revealAnimation

        target: root
        property: "progress"

        to: 1

        duration: 500
        easing.type: Easing.OutCubic

        onFinished: {
            root.running = false
        }
    }
}
