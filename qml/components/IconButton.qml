import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects

Button {
    id: control

    property url iconSource
    property bool destructive: false
    property int iconSize: 24
    property real visualIconScale: 1

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
        rotation: 0

        Image {
            id: iconImage

            anchors.centerIn: parent
            width: control.iconSize * control.visualIconScale
            height: control.iconSize * control.visualIconScale
            source: control.iconSource
            sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
            fillMode: Image.PreserveAspectFit
            visible: false
            smooth: true
            mipmap: true
        }

        MultiEffect {
            anchors.fill: iconImage
            source: iconImage
            colorization: 1
            colorizationColor: !control.enabled ? Theme.disabledText : control.destructive && control.hovered ? Theme.failure : control.hovered ? Theme.accent : Theme.text
            visible: iconImage.status === Image.Ready
            opacity: control.enabled ? 1 : 0.4

            Behavior on colorizationColor {
                ColorAnimation {
                    duration: 120
                }

            }

        }

        SequentialAnimation {
            id: hoverAnimation

            PropertyAction {
                target: control
                property: "visualIconScale"
                value: 1
            }

            ParallelAnimation {
                NumberAnimation {
                    target: control
                    property: "visualIconScale"
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
                target: control
                property: "visualIconScale"
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
            function onHoveredChanged() {
                if (control.hovered) {
                    restoreAnimation.stop();
                    hoverAnimation.restart();
                } else {
                    hoverAnimation.stop();
                    restoreAnimation.restart();
                }
            }

            target: control
        }

    }

}
