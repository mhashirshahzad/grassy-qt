import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: card

    required property string playerName
    required property bool playerOnline

    implicitHeight: 52
    color: playerOnline ? Theme.surface1 : Theme.surface0
    border.color: playerOnline ? Theme.border : Theme.surface2
    border.width: 1
    opacity: playerOnline ? 1 : 0.58

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 8
            height: 8
            radius: width / 2
            color: card.playerOnline ? Theme.success : Theme.subtext2
        }

        Label {
            text: card.playerName
            color: Theme.text
            Layout.fillWidth: true
        }

        Label {
            text: card.playerOnline ? "Online" : "Offline"
            color: card.playerOnline ? Theme.successText : Theme.subtext
            font.pixelSize: 12
        }
    }
}
