import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "Performance"
    searchHost: hostPopup
    searchBlob: "performance view simulation entity tick transport entity broadcast transport chunk compression"

    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "View distance (chunks)"
        settingKey: "view-distance"
        minimumValue: 3
        maximumValue: 32
        fallback: 10
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Simulation distance (chunks)"
        settingKey: "simulation-distance"
        minimumValue: 3
        maximumValue: 32
        fallback: 10
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Entity broadcast range (%)"
        settingKey: "entity-broadcast-range-percentage"
        minimumValue: 10
        maximumValue: 1000
        fallback: 100
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Use native transport"
        settingKey: "use-native-transport"
        fallback: true
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Sync chunk writes"
        settingKey: "sync-chunk-writes"
        fallback: true
    }
    ServerChoiceSetting {
        settingsPopup: hostPopup
        label: "Region file compression"
        settingKey: "region-file-compression"
        choices: ["deflate", "lz4", "none"]
        fallback: "deflate"
    }
}
