import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
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

    width: Math.min(parent ? parent.width - 32 : 980, 980)
    height: Math.min(parent ? parent.height - 32 : 760, 760)
    closeButtonSize: 34
    closeButtonTopMargin: 10
    closeButtonRightMargin: 10

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
        return query.length === 0 || text.toLowerCase().indexOf(query) >= 0
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
        serverSettingsPopup.close()
    }

    function openEditor() {
        values = readProperties(modelObject ? modelObject.serverProperties(serverFolder) : "")
        errorMessage = ""
        searchText = ""
    }

    onOpened: openEditor()

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        ColumnLayout {
            Layout.fillWidth: true
            Layout.rightMargin: serverSettingsPopup.closeButtonSize
                + serverSettingsPopup.closeButtonRightMargin + 12
            spacing: 4

            Label {
                text: "Server settings"
                font.pixelSize: 24
                font.bold: true
                color: Theme.textBright
            }

            Label {
                text: "Configure how this server behaves. Changes are saved to server.properties."
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
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width
                spacing: 12

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
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 8

            ThemedButton {
                text: "Cancel"
                buttonColor: Theme.surface3
                buttonHoverColor: Theme.overlay1
                buttonPressedColor: Theme.overlay2
                onClicked: serverSettingsPopup.close()
            }

            ThemedButton {
                text: "Save changes"
                onClicked: serverSettingsPopup.save()
            }
        }
    }
}
