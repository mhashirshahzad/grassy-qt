import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Rectangle {
    id: root

    property string title
    default property alias content: sectionLayout.data

    Layout.fillWidth: true
    implicitHeight: sectionLayout.implicitHeight + 24
    color: Theme.surface
    radius: 10
    border.color: Theme.border
    border.width: 1

    ColumnLayout {
        id: sectionLayout
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Label {
            text: root.title
            font.pixelSize: 15
            font.bold: true
            color: Theme.accent
        }
    }
}
