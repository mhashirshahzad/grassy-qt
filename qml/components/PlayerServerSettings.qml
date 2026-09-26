import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "Players"
    visible: root.popup.matches("player idle online log pause")

    ServerNumberSetting {
        popup: root.popup
        label: "Idle timeout (minutes)"
        description: "0 disables the timeout."
        settingKey: "player-idle-timeout"
        maximumValue: 60
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Hide online players"
        settingKey: "hide-online-players"
    }
    ServerToggleSetting {
        popup: root.popup
        label: "Log player IPs"
        settingKey: "log-ips"
        fallback: true
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Pause when empty (seconds)"
        description: "0 disables pausing."
        settingKey: "pause-when-empty-seconds"
        maximumValue: 3600
        fallback: 60
    }
}
