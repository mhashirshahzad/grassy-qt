import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "Security"
    visible: root.popup.matches("security whitelist permission op")

    ServerToggleSetting {
        popup: root.popup
        label: "Whitelist"
        description: "Only whitelisted players can join."
        settingKey: "white-list"
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Enforce whitelist"
        description: "Kick non-whitelisted players in-game."
        settingKey: "enforce-whitelist"
    }
    ServerChoiceSetting {
        popup: root.popup
        label: "OP permission level"
        settingKey: "op-permission-level"
        options: ["1", "2", "3", "4"]
        fallback: "4"
    }
}
