import QtQuick 2.15
import QtQuick.Controls 2.15
ServerSettingCard {
    property var settingsPopup
    property int minimumValue: 0
    property int maximumValue: 100
    property int fallback: 0
    searchHost: settingsPopup

    CustomTextField {
        anchors.fill: parent
        showSearchIcon: false
        text: String(settingsPopup.value(settingKey, fallback))
        inputMethodHints: Qt.ImhDigitsOnly
        validator: IntValidator {
            bottom: minimumValue
            top: maximumValue
        }
        onTextChanged: {
            if (acceptableInput)
                settingsPopup.setValue(settingKey, text)
        }
    }
}
