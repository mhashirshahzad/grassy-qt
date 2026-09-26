import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../theme" 1.0

Button {
    id: control

    property url iconSource

    width: 18
    height: 18
    hoverEnabled: true
    padding: 0

    background: Item {}

    contentItem: Item {
        id: iconContent
        transformOrigin: Item.Center
        scale: 1
        rotation: 0

        Image {
            id: iconImage

            anchors.fill: parent
            source: control.iconSource
            sourceSize: Qt.size(18, 18)
            fillMode: Image.PreserveAspectFit
            opacity: control.enabled ? 1 : 0.4
        }

        ColorOverlay {
            anchors.fill: iconImage
            source: iconImage
            color: control.enabled
                ? (control.hovered ? Theme.accent : Theme.text)
                : Theme.disabledText
            opacity: control.enabled ? 1 : 0.7

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
                    to: 1.15
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

        Connections {
            target: control

            function onHoveredChanged() {
                if (control.hovered)
                    hoverAnimation.restart()
            }
        }
    }
}
