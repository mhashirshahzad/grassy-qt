import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "World"
    searchHost: hostPopup
    searchBlob: "world name seed type generator structures hardcore size"

    ServerTextSetting {
        settingsPopup: hostPopup
        label: "World name"
        settingKey: "level-name"
        fallback: "world"
    }
    ServerTextSetting {
        settingsPopup: hostPopup
        label: "World seed"
        description: "Leave empty for a random seed."
        settingKey: "level-seed"
    }
    ServerChoiceSetting {
        settingsPopup: hostPopup
        label: "World type"
        settingKey: "level-type"
        choices: ["minecraft:normal", "minecraft:flat",
                  "minecraft:large_biomes", "minecraft:amplified",
                  "minecraft:single_biome_surface"]
        fallback: "minecraft:normal"
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Generate structures"
        description: "Generate villages, temples, and other structures."
        settingKey: "generate-structures"
        fallback: true
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Hardcore mode"
        description: "Players are banned on death."
        settingKey: "hardcore"
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Max world size (blocks)"
        settingKey: "max-world-size"
        minimumValue: 1000
        maximumValue: 29999984
        fallback: 29999984
    }
}
