import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: Theme.surface0
    border.color: Theme.border
    radius: 6

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Players"
            color: Theme.text
            font.bold: true
            font.pixelSize: 18
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Player tracking is not available yet."
            color: Theme.subtext
        }
    }
}
