import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "Network"
    searchHost: hostPopup
    searchBlob: "network online secure proxy rate compression status transfers"

    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Online mode"
        description: "Enable Mojang authentication."
        settingKey: "online-mode"
        fallback: true
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Enforce secure profile"
        description: "Require chat signing and secure profiles."
        settingKey: "enforce-secure-profile"
        fallback: true
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Prevent proxy connections"
        settingKey: "prevent-proxy-connections"
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Rate limit"
        description: "Maximum packets per second; 0 is unlimited."
        settingKey: "rate-limit"
        maximumValue: 100
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Network compression threshold (bytes)"
        settingKey: "network-compression-threshold"
        maximumValue: 1024
        fallback: 256
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Enable server status"
        settingKey: "enable-status"
        fallback: true
    }
}
