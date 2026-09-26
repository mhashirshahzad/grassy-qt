import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "World"
    visible: root.popup.matches("world name seed type generator structures hardcore size")

    ServerTextSetting {
        popup: root.popup
        label: "World name"
        settingKey: "level-name"
        fallback: "world"
    }
    ServerTextSetting {
        popup: root.popup
        label: "World seed"
        description: "Leave empty for a random seed."
        settingKey: "level-seed"
    }
    ServerChoiceSetting {
        popup: root.popup
        label: "World type"
        settingKey: "level-type"
        options: ["minecraft:normal", "minecraft:flat",
                  "minecraft:large_biomes", "minecraft:amplified",
                  "minecraft:single_biome_surface"]
        fallback: "minecraft:normal"
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Generate structures"
        description: "Generate villages, temples, and other structures."
        settingKey: "generate-structures"
        fallback: true
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Hardcore mode"
        description: "Players are banned on death."
        settingKey: "hardcore"
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Max world size (blocks)"
        settingKey: "max-world-size"
        minimumValue: 1000
        maximumValue: 29999984
        fallback: 29999984
    }
}
