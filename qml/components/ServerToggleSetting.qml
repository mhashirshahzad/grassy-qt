import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0

ServerSettingCard {
    property var popup
    property string settingKey
    property bool fallback: false

    Switch {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        checked: root.popup.value(root.settingKey, root.fallback) === true
            || root.popup.value(root.settingKey, root.fallback) === "true"
        onToggled: root.popup.setValue(root.settingKey, checked ? "true" : "false")
    }
}
