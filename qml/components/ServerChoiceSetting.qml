import QtQuick 2.15
ServerSettingCard {
    property var settingsPopup
    property string settingKey
    property var choices: []
    property string fallback: ""

    ServerChoiceControl {
        anchors.fill: parent
        currentIndex: Math.max(0, choices.indexOf(
            settingsPopup.value(settingKey, fallback)))
        options: choices
        onActivated: settingsPopup.setValue(settingKey, value)
    }
}
