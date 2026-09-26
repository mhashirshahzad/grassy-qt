import QtQuick 2.15
ServerSettingCard {
    property var settingsPopup
    property var choices: []
    property string fallback: ""
    searchHost: settingsPopup

    ServerChoiceControl {
        anchors.fill: parent
        currentIndex: Math.max(0, choices.indexOf(
            settingsPopup.value(settingKey, fallback)))
        options: choices
        onActivated: function (selectedValue) {
            settingsPopup.setValue(settingKey, selectedValue)
        }
    }
}
