import QtQuick 2.15
import "../theme" 1.0

ServerSettingCard {
    property var popup
    property string settingKey
    property string fallback: ""

    CustomTextField {
        anchors.fill: parent
        showSearchIcon: false
        text: root.popup.value(root.settingKey, root.fallback)
        onTextChanged: root.popup.setValue(root.settingKey, text)
    }
}
