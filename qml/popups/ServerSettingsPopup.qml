import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0
import "../components" 1.0
import "." 1.0

CustomPopup {
    id: serverSettingsPopup

    property var modelObject
    property string serverFolder
    property string errorMessage
    property var values: ({})
    property string searchText: ""
    property string minimumMemory: "2G"
    property string maximumMemory: "4G"
    property string javaExecutable: "java"
    errorState: errorMessage.length > 0

    width: Math.min(parent ? parent.width - 32 : 980, 980)
    height: Math.min(parent ? parent.height - 32 : 760, 760)

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
        const query = searchText.trim().toLowerCase()
        if (query.length === 0)
            return true

        let queryIndex = 0
        const candidate = text.toLowerCase()
        for (let index = 0; index < candidate.length; ++index) {
            if (candidate[index] === query[queryIndex])
                ++queryIndex
            if (queryIndex === query.length)
                return true
        }
        return false
    }

    function createStartScript() {
        if (!modelObject
                || !modelObject.createStartScript(
                    serverFolder, minimumMemory, maximumMemory, javaExecutable)) {
            errorMessage = "Enter valid Java and memory values."
            return false
        }
        errorMessage = ""
        return true
    }

    function openEditor() {
        values = readProperties(modelObject ? modelObject.serverProperties(serverFolder) : "")
        if (modelObject && modelObject.readStartScript) {
            const startSettings = modelObject.readStartScript(serverFolder)
            if (startSettings.minMemory)
                minimumMemory = startSettings.minMemory
            if (startSettings.maxMemory)
                maximumMemory = startSettings.maxMemory
            if (startSettings.javaExecutable)
                javaExecutable = startSettings.javaExecutable
        }
        errorMessage = ""
        searchText = ""
    }

    function save() {
        if (!createStartScript())
            return

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
        serverSettingsPopup.close()
    }

    onOpened: openEditor()

    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: serverSettingsPopup.opened
        context: Qt.WindowShortcut
        onActivated: serverSettingsPopup.save()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            Layout.rightMargin: serverSettingsPopup.closeButtonSize
                + serverSettingsPopup.closeButtonRightMargin + 12
            spacing: 4

            Label {
                text: serverSettingsPopup.errorMessage.length > 0
                    ? serverSettingsPopup.errorMessage : "Server settings"
                font.pixelSize: 24
                font.bold: true
                color: serverSettingsPopup.errorMessage.length > 0
                    ? Theme.failure : Theme.textBright
            }

            Label {
                text: "Configure how this server behaves. Changes are saved to server.properties, run.sh, and run.bat."
                color: Theme.subtext
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        CustomTextField {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            showSearchIcon: true
            placeholderText: "Search server settings..."
            onTextChanged: serverSettingsPopup.searchText = text
            onAccepted: serverSettingsPopup.save()
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width
                spacing: 12

                JavaServerSettings { hostPopup: serverSettingsPopup }
                BasicServerSettings { hostPopup: serverSettingsPopup }
                GameplayServerSettings { hostPopup: serverSettingsPopup }
                WorldServerSettings { hostPopup: serverSettingsPopup }
                NetworkServerSettings { hostPopup: serverSettingsPopup }
                PerformanceServerSettings { hostPopup: serverSettingsPopup }
                PlayerServerSettings { hostPopup: serverSettingsPopup }
                SecurityServerSettings { hostPopup: serverSettingsPopup }
            }
        }

        Label {
            text: serverSettingsPopup.errorMessage
            color: Theme.failure
            visible: false
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 8

            ThemedButton {
                Layout.fillWidth: true
                text: "Save changes (Enter)"
                onClicked: serverSettingsPopup.save()
            }
        }
    }
}
