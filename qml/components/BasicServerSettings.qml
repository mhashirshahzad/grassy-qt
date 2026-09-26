import QtQuick 2.15

ServerSettingsSection {
    property var hostPopup
    title: "Basic"
    visible: hostPopup.matches("basic motd server port ip players bug report")

    ServerTextSetting {
        settingsPopup: hostPopup
        label: "Server name (MOTD)"
        settingKey: "motd"
        fallback: "A Minecraft Server"
    }
    ServerTextSetting {
        settingsPopup: hostPopup
        label: "Server port"
        settingKey: "server-port"
        fallback: "25565"
    }
    ServerTextSetting {
        settingsPopup: hostPopup
        label: "Server IP"
        description: "Leave empty to bind to all interfaces."
        settingKey: "server-ip"
    }
    ServerNumberSetting {
        settingsPopup: hostPopup
        label: "Max players"
        settingKey: "max-players"
        minimumValue: 1
        maximumValue: 100
        fallback: 20
    }
    ServerTextSetting {
        settingsPopup: hostPopup
        label: "Bug report link"
        settingKey: "bug-report-link"
    }
}
