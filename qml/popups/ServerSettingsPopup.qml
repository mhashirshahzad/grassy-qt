import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../theme" 1.0
import "../components" 1.0
import "." 1.0

CustomPopup {
    id: root

    property var modelObject
    property string serverFolder
    property string errorMessage
    property var values: ({})
    property string searchText: ""

    width: Math.min(parent ? parent.width - 32 : 900, 900)
    height: Math.min(parent ? parent.height - 32 : 700, 700)
    closeButtonRightMargin: 18

    function readProperties(contents) {
        const result = {}
        const lines = contents.split("\n")
        for (const line of lines) {
            if (!line || line.trim().startsWith("#"))
                continue
            const separator = line.indexOf("=")
            if (separator < 0)
                continue
            const key = line.slice(0, separator).trim()
            let value = line.slice(separator + 1)
            if (key === "level-type")
                value = value.replace(/\\:/g, ":")
            result[key] = value
        }
        return result
    }

    function value(key, fallback) {
        return values[key] !== undefined ? values[key] : fallback
    }

    function setValue(key, value) {
        values[key] = String(value)
        values = values
    }

    function matches(text) {
        return searchText.trim().length === 0
            || text.toLowerCase().indexOf(searchText.trim().toLowerCase()) >= 0
    }

    function save() {
        if (!modelObject) {
            errorMessage = "Server model is unavailable."
            return
        }
        for (const key in values) {
            if (!modelObject.setServerProperty(serverFolder, key, String(values[key]))) {
                errorMessage = "Could not save server.properties."
                return
            }
        }
        errorMessage = ""
        root.close()
    }

    function openEditor() {
        values = readProperties(modelObject ? modelObject.serverProperties(serverFolder) : "")
        errorMessage = ""
        searchText = ""
    }

    onOpened: openEditor()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Server settings"
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
            }

            TextField {
                id: searchField
                Layout.preferredWidth: 220
                placeholderText: "Search settings..."
                onTextChanged: root.searchText = text
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                SettingsSection {
                    title: "Basic Settings"
                    visible: root.matches("basic motd server port server ip max players bug report")

                    SettingsTextField {
                        label: "Server Name (MOTD)"
                        settingKey: "motd"
                        fallback: "A Minecraft Server"
                    }
                    SettingsTextField {
                        label: "Server Port"
                        settingKey: "server-port"
                        fallback: "25565"
                    }
                    SettingsTextField {
                        label: "Server IP"
                        description: "Leave empty to bind to all interfaces"
                        settingKey: "server-ip"
                        fallback: ""
                    }
                    SettingsSpinBox {
                        label: "Max Players"
                        settingKey: "max-players"
                        minimumValue: 1
                        maximumValue: 100
                        fallback: 20
                    }
                    SettingsTextField {
                        label: "Bug Report Link"
                        settingKey: "bug-report-link"
                        fallback: ""
                    }
                }

                SettingsSection {
                    title: "Gameplay Settings"
                    visible: root.matches("gameplay game mode difficulty flight spawn protection")

                    SettingsComboBox {
                        label: "Default Game Mode"
                        settingKey: "gamemode"
                        options: ["survival", "creative", "adventure", "spectator"]
                        fallback: "survival"
                    }
                    SettingsSwitch {
                        label: "Force Game Mode"
                        description: "Force players to the default game mode on join"
                        settingKey: "force-gamemode"
                    }
                    SettingsComboBox {
                        label: "Difficulty"
                        settingKey: "difficulty"
                        options: ["peaceful", "easy", "normal", "hard"]
                        fallback: "easy"
                    }
                    SettingsSwitch {
                        label: "Allow Flight"
                        description: "Allow players to fly without anti-cheat kicking"
                        settingKey: "allow-flight"
                    }
                    SettingsSpinBox {
                        label: "Spawn Protection (blocks)"
                        description: "0 disables spawn protection"
                        settingKey: "spawn-protection"
                        minimumValue: 0
                        maximumValue: 100
                        fallback: 16
                    }
                }

                SettingsSection {
                    title: "World Settings"
                    visible: root.matches("world name seed type generator structures hardcore world size")

                    SettingsTextField {
                        label: "World Name"
                        settingKey: "level-name"
                        fallback: "world"
                    }
                    SettingsTextField {
                        label: "World Seed"
                        description: "Leave empty for a random seed"
                        settingKey: "level-seed"
                        fallback: ""
                    }
                    SettingsComboBox {
                        label: "World Type"
                        settingKey: "level-type"
                        options: ["minecraft:normal", "minecraft:flat",
                                  "minecraft:large_biomes", "minecraft:amplified",
                                  "minecraft:single_biome_surface"]
                        fallback: "minecraft:normal"
                    }
                    SettingsSwitch {
                        label: "Generate Structures"
                        description: "Generate villages, temples, and other structures"
                        settingKey: "generate-structures"
                        fallback: true
                    }
                    SettingsSwitch {
                        label: "Hardcore Mode"
                        description: "Players are banned on death"
                        settingKey: "hardcore"
                    }
                    SettingsSpinBox {
                        label: "Max World Size (blocks)"
                        settingKey: "max-world-size"
                        minimumValue: 1000
                        maximumValue: 29999984
                        fallback: 29999984
                    }
                }

                SettingsSection {
                    title: "Network Settings"
                    visible: root.matches("network online secure proxy rate compression status transfers")

                    SettingsSwitch {
                        label: "Online Mode"
                        description: "Enable Mojang authentication"
                        settingKey: "online-mode"
                        fallback: true
                    }
                    SettingsSwitch {
                        label: "Enforce Secure Profile"
                        description: "Require chat signing and secure profiles"
                        settingKey: "enforce-secure-profile"
                        fallback: true
                    }
                    SettingsSwitch {
                        label: "Prevent Proxy Connections"
                        settingKey: "prevent-proxy-connections"
                    }
                    SettingsSpinBox {
                        label: "Rate Limit"
                        description: "Maximum packets per second; 0 is unlimited"
                        settingKey: "rate-limit"
                        minimumValue: 0
                        maximumValue: 100
                        fallback: 0
                    }
                    SettingsSpinBox {
                        label: "Network Compression Threshold (bytes)"
                        settingKey: "network-compression-threshold"
                        minimumValue: 0
                        maximumValue: 1024
                        fallback: 256
                    }
                    SettingsSwitch {
                        label: "Enable Server Status"
                        settingKey: "enable-status"
                        fallback: true
                    }
                }

                SettingsSection {
                    title: "Performance Settings"
                    visible: root.matches("performance view simulation entity tick transport chunk compression")

                    SettingsSpinBox {
                        label: "View Distance (chunks)"
                        settingKey: "view-distance"
                        minimumValue: 3
                        maximumValue: 32
                        fallback: 10
                    }
                    SettingsSpinBox {
                        label: "Simulation Distance (chunks)"
                        settingKey: "simulation-distance"
                        minimumValue: 3
                        maximumValue: 32
                        fallback: 10
                    }
                    SettingsSpinBox {
                        label: "Entity Broadcast Range (%)"
                        settingKey: "entity-broadcast-range-percentage"
                        minimumValue: 10
                        maximumValue: 1000
                        fallback: 100
                    }
                    SettingsSwitch {
                        label: "Use Native Transport"
                        settingKey: "use-native-transport"
                        fallback: true
                    }
                    SettingsSwitch {
                        label: "Sync Chunk Writes"
                        settingKey: "sync-chunk-writes"
                        fallback: true
                    }
                    SettingsComboBox {
                        label: "Region File Compression"
                        settingKey: "region-file-compression"
                        options: ["deflate", "lz4", "none"]
                        fallback: "deflate"
                    }
                }

                SettingsSection {
                    title: "Player Settings"
                    visible: root.matches("player idle online log pause")

                    SettingsSpinBox {
                        label: "Idle Timeout (minutes)"
                        description: "0 disables the timeout"
                        settingKey: "player-idle-timeout"
                        minimumValue: 0
                        maximumValue: 60
                        fallback: 0
                    }
                    SettingsSwitch {
                        label: "Hide Online Players"
                        settingKey: "hide-online-players"
                    }
                    SettingsSwitch {
                        label: "Log Player IPs"
                        settingKey: "log-ips"
                        fallback: true
                    }
                    SettingsSpinBox {
                        label: "Pause When Empty (seconds)"
                        description: "0 disables pausing"
                        settingKey: "pause-when-empty-seconds"
                        minimumValue: 0
                        maximumValue: 3600
                        fallback: 60
                    }
                }

                SettingsSection {
                    title: "Security Settings"
                    visible: root.matches("security whitelist permission op")

                    SettingsSwitch {
                        label: "Whitelist"
                        description: "Only whitelisted players can join"
                        settingKey: "white-list"
                    }
                    SettingsSwitch {
                        label: "Enforce Whitelist"
                        description: "Kick non-whitelisted players in-game"
                        settingKey: "enforce-whitelist"
                    }
                    SettingsComboBox {
                        label: "OP Permission Level"
                        settingKey: "op-permission-level"
                        options: ["1", "2", "3", "4"]
                        fallback: "4"
                    }
                }
            }
        }

        Label {
            text: root.errorMessage
            color: Theme.failure
            visible: text.length > 0
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight

            ThemedButton {
                text: "Cancel"
                buttonColor: Theme.surface3
                buttonHoverColor: Theme.overlay1
                buttonPressedColor: Theme.overlay2
                onClicked: root.close()
            }
            ThemedButton {
                text: "Save"
                onClicked: root.save()
            }
        }
    }

    component SettingsSection: Rectangle {
        property string title
        default property alias content: sectionLayout.data
        implicitHeight: sectionLayout.implicitHeight + 20
        Layout.fillWidth: true
        color: Theme.surface1
        radius: 8
        border.color: Theme.border

        ColumnLayout {
            id: sectionLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Label {
                text: parent.parent.title
                font.bold: true
                color: Theme.accent
            }
        }
    }

    component SettingsTextField: ColumnLayout {
        property string label
        property string description: ""
        property string settingKey
        property string fallback: ""
        Layout.fillWidth: true
        spacing: 3

        Label { text: label; color: Theme.text }
        TextField {
            Layout.fillWidth: true
            text: root.value(settingKey, fallback)
            onTextChanged: root.setValue(settingKey, text)
        }
        Label {
            text: description
            visible: description.length > 0
            color: Theme.subtext
            font.pixelSize: 11
        }
    }

    component SettingsSpinBox: ColumnLayout {
        property string label
        property string description: ""
        property string settingKey
        property int minimumValue: 0
        property int maximumValue: 100
        property int fallback: 0
        Layout.fillWidth: true
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            Label { text: label; Layout.fillWidth: true }
            SpinBox {
                from: minimumValue
                to: maximumValue
                value: Number(root.value(settingKey, fallback))
                onValueChanged: root.setValue(settingKey, value)
            }
        }
        Label {
            text: description
            visible: description.length > 0
            color: Theme.subtext
            font.pixelSize: 11
        }
    }

    component SettingsSwitch: ColumnLayout {
        property string label
        property string description: ""
        property string settingKey
        property bool fallback: false
        Layout.fillWidth: true

        Switch {
            Layout.fillWidth: true
            text: label
            checked: root.value(settingKey, fallback) === true
                || root.value(settingKey, fallback) === "true"
            onToggled: root.setValue(settingKey, checked ? "true" : "false")
        }
        Label {
            text: description
            visible: description.length > 0
            color: Theme.subtext
            font.pixelSize: 11
        }
    }

    component SettingsComboBox: RowLayout {
        property string label
        property string settingKey
        property var options: []
        property string fallback: ""
        Layout.fillWidth: true

        Label { text: label; Layout.fillWidth: true }
        ComboBox {
            model: options
            currentIndex: Math.max(0, options.indexOf(root.value(settingKey, fallback)))
            onActivated: root.setValue(settingKey, currentText)
        }
    }
}
