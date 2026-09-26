import QtQuick 2.15
ServerSettingCard {
    property var settingsPopup
    property string settingKey
    property int minimumValue: 0
    property int maximumValue: 100
    property int fallback: 0

    ServerNumberControl {
        anchors.fill: parent
        from: minimumValue
        to: maximumValue
        value: Number(settingsPopup.value(settingKey, fallback))
        onValueEdited: settingsPopup.setValue(settingKey, value)
    }
}
