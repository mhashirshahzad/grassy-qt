import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../theme" 1.0

Item {
    id: control

    property int value: 0
    property int from: 0
    property int to: 100
    signal valueEdited(int value)

    implicitWidth: 150
    implicitHeight: 34

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: Theme.surface2
        border.color: Theme.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item { Layout.fillWidth: true }

            Label {
                text: control.value
                color: Theme.text
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 62
            }

            Rectangle {
                Layout.fillHeight: true
                width: 1
                color: Theme.border
            }

            Rectangle {
                Layout.fillHeight: true
                width: 34
                color: incrementMouse.containsMouse ? Theme.surface3 : Theme.transparent
                Label {
                    anchors.centerIn: parent
                    text: "+"
                    color: Theme.text
                    font.pixelSize: 18
                }
                MouseArea {
                    id: incrementMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.valueEdited(Math.min(control.to, control.value + 1))
                }
            }

            Rectangle {
                Layout.fillHeight: true
                width: 34
                color: decrementMouse.containsMouse ? Theme.surface3 : Theme.transparent
                Label {
                    anchors.centerIn: parent
                    text: "−"
                    color: Theme.text
                    font.pixelSize: 18
                }
                MouseArea {
                    id: decrementMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.valueEdited(Math.max(control.from, control.value - 1))
                }
            }
        }
    }
}
