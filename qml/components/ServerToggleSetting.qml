import QtQuick 2.15
ServerSettingCard {
    property var settingsPopup
    property bool fallback: false
    searchHost: settingsPopup

    ServerToggleControl {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        checked: settingsPopup.value(settingKey, fallback) === true
            || settingsPopup.value(settingKey, fallback) === "true"
        onToggled: function (nextChecked) {
            checked = nextChecked
            settingsPopup.setValue(settingKey, nextChecked ? "true" : "false")
        }
    }
}
