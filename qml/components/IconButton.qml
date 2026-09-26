import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../theme" 1.0

Button {
    id: control

    property url iconSource
    property bool destructive: false

    property int iconSize: 24

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: iconSize
    height: iconSize
    hoverEnabled: true
    padding: 0

    background: Rectangle {
        color: Theme.transparent
    }

    contentItem: Item {
        id: iconContent
        transformOrigin: Item.Center
        scale: 1
        rotation: 0

        Image {
            id: iconImage

            anchors.fill: parent
            source: control.iconSource
            sourceSize: Qt.size(control.iconSize, control.iconSize)
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        ColorOverlay {
            anchors.fill: iconImage
            source: iconImage
            visible: iconImage.status === Image.Ready
            color: !control.enabled
                ? Theme.disabledText
                : control.destructive && control.hovered
                    ? Theme.failure
                    : control.hovered
                        ? Theme.accent
                        : Theme.text
            opacity: control.enabled ? 1 : 0.4

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        SequentialAnimation {
            id: hoverAnimation

            PropertyAction {
                target: iconContent
                property: "scale"
                value: 1
            }

            ParallelAnimation {
                NumberAnimation {
                    target: iconContent
                    property: "scale"
                    to: 1.25
                    duration: 100
                    easing.type: Easing.OutBack
                }

                SequentialAnimation {
                    NumberAnimation {
                        target: iconContent
                        property: "rotation"
                        to: -8
                        duration: 50
                    }

                    NumberAnimation {
                        target: iconContent
                        property: "rotation"
                        to: 8
                        duration: 100
                    }

                    NumberAnimation {
                        target: iconContent
                        property: "rotation"
                        to: -5
                        duration: 80
                    }

                    NumberAnimation {
                        target: iconContent
                        property: "rotation"
                        to: 0
                        duration: 70
                    }
                }
            }
        }

        ParallelAnimation {
            id: restoreAnimation

            NumberAnimation {
                target: iconContent
                property: "scale"
                to: 1
                duration: 120
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: iconContent
                property: "rotation"
                to: 0
                duration: 100
                easing.type: Easing.OutCubic
            }
        }

        Connections {
            target: control

            function onHoveredChanged() {
                if (control.hovered) {
                    restoreAnimation.stop()
                    hoverAnimation.restart()
                } else {
                    hoverAnimation.stop()
                    restoreAnimation.restart()
                }
            }
        }
    }
}
