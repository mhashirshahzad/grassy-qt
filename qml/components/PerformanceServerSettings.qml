import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "Performance"
    visible: root.popup.matches("performance view simulation entity tick transport chunk compression")

    ServerNumberSetting {
        popup: root.popup
        label: "View distance (chunks)"
        settingKey: "view-distance"
        minimumValue: 3
        maximumValue: 32
        fallback: 10
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Simulation distance (chunks)"
        settingKey: "simulation-distance"
        minimumValue: 3
        maximumValue: 32
        fallback: 10
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Entity broadcast range (%)"
        settingKey: "entity-broadcast-range-percentage"
        minimumValue: 10
        maximumValue: 1000
        fallback: 100
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Use native transport"
        settingKey: "use-native-transport"
        fallback: true
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Sync chunk writes"
        settingKey: "sync-chunk-writes"
        fallback: true
    }
    ServerChoiceSetting {
        popup: root.popup
        label: "Region file compression"
        settingKey: "region-file-compression"
        options: ["deflate", "lz4", "none"]
        fallback: "deflate"
    }
}
