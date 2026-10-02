import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Item {
    id: root

    property var runner: null
    property string label: ""
    property real currentValue: 0
    property real maximumValue: 0
    property string valueText: ""

    readonly property bool active: runner !== null && runner.running

    readonly property real ratio: maximumValue > 0
        ? Math.max(0, currentValue / maximumValue)
        : 0

    readonly property string shownText: valueText.length > 0
        ? valueText
        : currentValue + " / " + maximumValue

    Layout.fillWidth: true

    implicitHeight: content.implicitHeight + 12
    implicitWidth: content.implicitWidth + 12

    Rectangle {
        anchors.fill: parent
        color: Theme.surface0
        border.color: Theme.surface2
        border.width: 1
        radius: 6
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 6

        spacing: 3

        Label {
            text: root.label
            color: root.active
                ? root.usageColor(root.ratio)
                : Theme.subtext

            font.pixelSize: 12
        }

        Label {
            text: root.active ? " " + root.shownText : " --"
            color: Theme.subtext
            font.pixelSize: 10
        }

        ProgressBar {
            id: bar

            Layout.fillWidth: true

            from: 0
            to: 1
            value: root.active
                ? Math.min(1, root.ratio)
                : 0

            enabled: root.active

            background: Rectangle {
                implicitHeight: 6
                radius: 3
                color: Theme.surface3
            }

            contentItem: Item {
                Rectangle {
                    width: parent.width
                        * Math.min(1, Math.max(0, bar.value))

                    height: parent.height
                    radius: 3

                    color: root.active
                        ? root.usageColor(bar.value)
                        : Theme.disabled
                }
            }
        }
    }

    function usageColor(value) {
        if (value >= 0.9)
            return Theme.failure

        if (value >= 0.75)
            return Theme.warning

        return Theme.success
    }
}
