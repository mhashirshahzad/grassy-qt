import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

ColumnLayout {
    id: root

    property var runner: null
    property string label: ""
    property real current_value: 0
    property real maximum_value: 0
    property string value_text: ""

    readonly property bool active: runner !== null && runner.running
    readonly property real ratio: maximum_value > 0
        ? Math.max(0, current_value / maximum_value)
        : 0
    readonly property string shown_text: value_text.length > 0
        ? value_text
        : current_value + " / " + maximum_value

    Layout.fillWidth: true
    spacing: 3

    Label {
        text: root.label + (root.active ? " " + root.shown_text : " --")
        color: root.active ? root.usageColor(root.ratio) : Theme.subtext
    }

    ProgressBar {
        id: bar
        Layout.fillWidth: true
        from: 0
        to: 1
        value: root.active ? Math.min(1, root.ratio) : 0
        enabled: root.active
        background: Rectangle {
            implicitHeight: 6
            radius: 3
            color: Theme.surface3
        }
        contentItem: Item {
            Rectangle {
                width: parent.width * Math.min(1, Math.max(0, bar.value))
                height: parent.height
                radius: 3
                color: root.active ? root.usageColor(bar.value) : Theme.disabled
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
