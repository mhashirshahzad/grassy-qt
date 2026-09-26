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

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: controlMouse.containsMouse ? Theme.surface3 : Theme.surface2
        border.color: controlPopup.visible ? Theme.accent : Theme.border
        border.width: controlPopup.visible ? 2 : 1

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
        x: control.mapToItem(parent, 0, control.height).x
        y: control.mapToItem(parent, 0, control.height).y + 4
        width: control.width
        padding: 4
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.surface1
            border.color: Theme.borderHover
            radius: 7
        }

        contentItem: ListView {
            implicitHeight: Math.min(contentHeight, 220)
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
