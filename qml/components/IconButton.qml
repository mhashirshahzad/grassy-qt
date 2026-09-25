import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0

Button {
    id: control

    property url iconSource

    width: 18
    height: 18
    hoverEnabled: true
    padding: 0

    background: Rectangle {
        radius: 7
        color: control.hovered
            ? Qt.rgba(
                  Theme.background.r,
                  Theme.background.g,
                  Theme.background.b,
                  0.75
              )
            : "transparent"

        border.width: control.hovered ? 1 : 0
        border.color: Qt.rgba(
            Theme.text.r,
            Theme.text.g,
            Theme.text.b,
            0.25
        )

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }
    }

    contentItem: Image {
        id: iconImage

        source: control.iconSource
        sourceSize: Qt.size(18, 18)
        fillMode: Image.PreserveAspectFit

        transformOrigin: Item.Center

        // Zoom
        scale: 1

        // Shake
        rotation: 0

        SequentialAnimation {
            id: hoverAnimation

            PropertyAction {
                target: iconImage
                property: "scale"
                value: 1
            }

            ParallelAnimation {
                NumberAnimation {
                    target: iconImage
                    property: "scale"
                    to: 1.15
                    duration: 100
                    easing.type: Easing.OutBack
                }

                SequentialAnimation {
                    NumberAnimation {
                        target: iconImage
                        property: "rotation"
                        to: -8
                        duration: 50
                    }

                    NumberAnimation {
                        target: iconImage
                        property: "rotation"
                        to: 8
                        duration: 100
                    }

                    NumberAnimation {
                        target: iconImage
                        property: "rotation"
                        to: -5
                        duration: 80
                    }

                    NumberAnimation {
                        target: iconImage
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
