import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0

ServerSettingCard {
    property var popup
    property string settingKey
    property var options: []
    property string fallback: ""

    ComboBox {
        anchors.fill: parent
        model: root.options
        currentIndex: Math.max(0, root.options.indexOf(
            root.popup.value(root.settingKey, root.fallback)))
        onActivated: root.popup.setValue(root.settingKey, currentText)
        palette.text: Theme.text
        palette.buttonText: Theme.text
    }
}
