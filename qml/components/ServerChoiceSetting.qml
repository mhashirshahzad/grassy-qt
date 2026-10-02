import QtQuick 2.15
ServerSettingCard {
    property var settingsPopup
    property var choices: []
    property string fallback: ""
    searchHost: settingsPopup

    ChoiceControl {
        anchors.fill: parent
        currentIndex: {
            if (!settingsPopup || !settingsPopup.values)
                return 0
            const currentVal = settingsPopup.values[settingKey] !== undefined
                ? settingsPopup.values[settingKey]
                : fallback
            const idx = choices.indexOf(currentVal)
            return idx >= 0 ? idx : 0
        }
        options: choices
        onActivated: function (selectedValue) {
            settingsPopup.setValue(settingKey, selectedValue)
        }
    }
}
