import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Rectangle {
    id: root

    property string label
    property string description: ""
    property string settingKey
    property var searchHost
    default property alias control: controlHost.data

    Layout.fillWidth: true
    visible: !searchHost
        || searchHost.matches(label + " " + description + " " + settingKey)
    implicitHeight: cardLayout.implicitHeight + 16
    radius: 0
    color: Theme.transparent
    border.width: 0

    RowLayout {
        id: cardLayout
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

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
