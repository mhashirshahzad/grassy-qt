import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "Gameplay"
    searchHost: hostPopup
    searchBlob: "gameplay game mode difficulty flight spawn protection"

    ServerChoiceSetting {
        settingsPopup: hostPopup
        label: "Default game mode"
        settingKey: "gamemode"
        choices: ["survival", "creative", "adventure", "spectator"]
        fallback: "survival"
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Force game mode"
        description: "Force players to the default game mode on join."
        settingKey: "force-gamemode"
    }
    ServerChoiceSetting {
        settingsPopup: hostPopup
        label: "Difficulty"
        settingKey: "difficulty"
        choices: ["peaceful", "easy", "normal", "hard"]
        fallback: "easy"
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Allow flight"
        description: "Allow players to fly without anti-cheat kicking."
        settingKey: "allow-flight"
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Spawn protection (blocks)"
        description: "0 disables spawn protection."
        settingKey: "spawn-protection"
        maximumValue: 100
        fallback: 16
    }
}
