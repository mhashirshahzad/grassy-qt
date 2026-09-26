import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "Players"
    visible: hostPopup.matches("player idle online log pause")

    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Idle timeout (minutes)"
        description: "0 disables the timeout."
        settingKey: "player-idle-timeout"
        maximumValue: 60
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Hide online players"
        settingKey: "hide-online-players"
    }
    ServerToggleSetting {
        settingsPopup: hostPopup
        label: "Log player IPs"
        settingKey: "log-ips"
        fallback: true
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Pause when empty (seconds)"
        description: "0 disables pausing."
        settingKey: "pause-when-empty-seconds"
        maximumValue: 3600
        fallback: 60
    }
}
