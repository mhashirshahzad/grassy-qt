import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
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
        color: Theme.surface2
        border.color: Theme.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            Label {
                text: (control.options && control.options.length > control.currentIndex && control.currentIndex >= 0)
                    ? control.options[control.currentIndex]
                    : ""
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
            onClicked: {
                if (controlPopup.visible)
                    controlPopup.close()
                else
                    controlPopup.open()
            }
        }
    }

    Popup {
        id: controlPopup
        y: {
            const win = control.Window.window
            if (!win)
                return control.height + 4
            const pt = control.mapToItem(null, 0, 0)
            const popupH = height
            if (pt.y + control.height + popupH + 8 > win.height)
                return -popupH - 4
            return control.height + 4
        }
        width: control.width
        height: Math.min((control.options ? control.options.length : 0) * 32 + 8, 220)
        padding: 4
        modal: false
        z: 100
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.surface2
            border.color: Theme.border
            radius: 7
        }

        contentItem: ListView {
            clip: true
            model: control.options

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : (control.width - 8)
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
