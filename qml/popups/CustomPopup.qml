import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0
import "../components" 1.0

Popup {
    id: root

    property bool destructiveClose: true
    property bool showCloseButton: true
    property int closeButtonTopMargin: 2
    property int closeButtonRightMargin: 2
    property int closeButtonSize: 24

    modal: true
    dim: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 20

    background: Rectangle {
        color: Theme.background
        border.color: Theme.border
        border.width: 1
        radius: 12
    }

    Overlay.modal: Rectangle {
        color: Theme.scrim
    }

    IconButton {
        visible: root.showCloseButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.closeButtonTopMargin
        anchors.rightMargin: root.closeButtonRightMargin
        iconSize: root.closeButtonSize
        iconSource: "qrc:/icons/close.svg"
        destructive: root.destructiveClose
        ToolTip.text: "Close"
        ToolTip.visible: hovered
        z: 2
        onClicked: root.close()
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 0.92; to: 1; duration: 180; easing.type: Easing.OutCubic }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 1; to: 0.96; duration: 120; easing.type: Easing.InCubic }
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
        }
    }
}
