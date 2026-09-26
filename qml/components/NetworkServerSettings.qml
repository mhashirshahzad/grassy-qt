import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "Network"
    visible: root.popup.matches("network online secure proxy rate compression status transfers")

    ServerToggleSetting {
        popup: root.popup
        label: "Online mode"
        description: "Enable Mojang authentication."
        settingKey: "online-mode"
        fallback: true
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Enforce secure profile"
        description: "Require chat signing and secure profiles."
        settingKey: "enforce-secure-profile"
        fallback: true
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Prevent proxy connections"
        settingKey: "prevent-proxy-connections"
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Rate limit"
        description: "Maximum packets per second; 0 is unlimited."
        settingKey: "rate-limit"
        maximumValue: 100
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Network compression threshold (bytes)"
        settingKey: "network-compression-threshold"
        maximumValue: 1024
        fallback: 256
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Enable server status"
        settingKey: "enable-status"
        fallback: true
    }
}
