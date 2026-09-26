import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "Security"
    searchHost: hostPopup
    searchBlob: "security whitelist permission op"

    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Whitelist"
        description: "Only whitelisted players can join."
        settingKey: "white-list"
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Enforce whitelist"
        description: "Kick non-whitelisted players in-game."
        settingKey: "enforce-whitelist"
    }
    ServerChoiceSetting {
        settingsPopup: hostPopup
        label: "OP permission level"
        settingKey: "op-permission-level"
        choices: ["1", "2", "3", "4"]
        fallback: "4"
    }
}
