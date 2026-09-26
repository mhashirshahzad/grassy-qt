import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme" 1.0

ServerSettingCard {
    property var popup
    property string settingKey
    property int minimumValue: 0
    property int maximumValue: 100
    property int fallback: 0

    SpinBox {
        anchors.fill: parent
        from: root.minimumValue
        to: root.maximumValue
        value: Number(root.popup.value(root.settingKey, root.fallback))
        onValueChanged: root.popup.setValue(root.settingKey, value)
        palette.text: Theme.text
        palette.buttonText: Theme.text
    }
}
