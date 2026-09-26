import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../theme" 1.0

Item {
    id: control

    property var options: []
    property int currentIndex: 0
    signal activated(string value)

    implicitWidth: 220
    implicitHeight: 34

    function popupPoint() {
        if (!Overlay.overlay)
            return Qt.point(0, 0)
        return control.mapToItem(Overlay.overlay, 0, 0)
    }

    function popupX() {
        if (!Overlay.overlay)
            return 4
        const point = popupPoint()
        return Math.max(4, Math.min(
            point.x, Overlay.overlay.width - controlPopup.width - 4))
    }

    function popupY() {
        if (!Overlay.overlay)
            return 4
        const point = popupPoint()
        const below = point.y + control.height + 4
        const above = point.y - controlPopup.height - 4
        const fitsBelow = below + controlPopup.height <= Overlay.overlay.height - 4
        return fitsBelow
            ? below
            : Math.max(4, above)
    }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: Theme.surface2
        border.color: Theme.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            Label {
                text: control.options.length > control.currentIndex
                    ? control.options[control.currentIndex] : ""
                color: Theme.text
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: controlPopup.visible ? "▲" : "▼"
                color: Theme.subtext
            }
        }

        MouseArea {
            id: controlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: controlPopup.open()
        }
    }

    Popup {
        id: controlPopup
        parent: Overlay.overlay
        x: control.popupX()
        y: control.popupY()
        width: control.width
        height: Math.min(control.options.length * 32 + 8, 220)
        padding: 4
        modal: false
        z: 10
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.surface2
            border.color: Theme.border
            radius: 7
        }

        contentItem: ListView {
            anchors.fill: parent
            model: control.options
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 32
                radius: 5
                color: optionMouse.containsMouse ? Theme.surface3 : Theme.transparent

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    text: modelData
                    color: Theme.text
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: optionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        control.currentIndex = index
                        control.activated(modelData)
                        controlPopup.close()
                    }
                }
            }
        }
    }
}
