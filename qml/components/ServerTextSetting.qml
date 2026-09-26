import QtQuick 2.15
ServerSettingCard {
    property var settingsPopup
    property string settingKey
    property string fallback: ""

    CustomTextField {
        anchors.fill: parent
        showSearchIcon: false
        text: settingsPopup.value(settingKey, fallback)
        onTextChanged: settingsPopup.setValue(settingKey, text)
    }
}
