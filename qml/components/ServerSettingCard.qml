import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Rectangle {
    id: root

    property string label
    property string description: ""
    property color accentColor: Theme.accent
    default property alias control: controlHost.data

    Layout.fillWidth: true
    implicitHeight: cardLayout.implicitHeight + 20
    radius: 8
    color: Theme.surface1
    border.color: Theme.border
    border.width: 1

    RowLayout {
        id: cardLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 4
            Layout.fillHeight: true
            radius: 2
            color: root.accentColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: root.label
                color: Theme.textBright
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                text: root.description
                visible: text.length > 0
                color: Theme.subtext
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Item {
            id: controlHost
            Layout.preferredWidth: 220
            Layout.minimumWidth: 140
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
