import "../theme"
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string title
    property var searchHost
    property string searchBlob: title
    default property alias content: sectionLayout.data

    Layout.fillWidth: true
    visible: !searchHost || searchHost.matches(searchBlob)
    implicitHeight: sectionLayout.implicitHeight + 20
    color: Theme.surface1
    radius: Theme.radiusLarge

    Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    ColumnLayout {
        id: sectionLayout

        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Label {
            text: root.title
            font.pixelSize: 14
            font.bold: true
            color: Theme.text
        }

    }

}
