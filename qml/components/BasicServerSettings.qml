import QtQuick 2.15

ServerSettingsSection {
    property var popup
    title: "Basic"
    visible: root.popup.matches("basic motd server port ip players bug report")

    ServerTextSetting {
        popup: root.popup
        label: "Server name (MOTD)"
        settingKey: "motd"
        fallback: "A Minecraft Server"
    }
    ServerTextSetting {
        popup: root.popup
        label: "Server port"
        settingKey: "server-port"
        fallback: "25565"
    }
    ServerTextSetting {
        popup: root.popup
        label: "Server IP"
        description: "Leave empty to bind to all interfaces."
        settingKey: "server-ip"
    }
    ServerNumberSetting {
        popup: root.popup
        label: "Max players"
        settingKey: "max-players"
        minimumValue: 1
        maximumValue: 100
        fallback: 20
    }
    ServerTextSetting {
        popup: root.popup
        label: "Bug report link"
        settingKey: "bug-report-link"
    }
}
