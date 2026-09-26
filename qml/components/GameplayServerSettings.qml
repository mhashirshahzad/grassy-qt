import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "Gameplay"
    visible: root.popup.matches("gameplay game mode difficulty flight spawn protection")

    ServerChoiceSetting {
        popup: root.popup
        label: "Default game mode"
        settingKey: "gamemode"
        options: ["survival", "creative", "adventure", "spectator"]
        fallback: "survival"
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Force game mode"
        description: "Force players to the default game mode on join."
        settingKey: "force-gamemode"
    }
    ServerChoiceSetting {
        popup: root.popup
        label: "Difficulty"
        settingKey: "difficulty"
        options: ["peaceful", "easy", "normal", "hard"]
        fallback: "easy"
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Allow flight"
        description: "Allow players to fly without anti-cheat kicking."
        settingKey: "allow-flight"
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Spawn protection (blocks)"
        description: "0 disables spawn protection."
        settingKey: "spawn-protection"
        maximumValue: 100
        fallback: 16
    }
}
