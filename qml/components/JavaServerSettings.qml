import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

ServerSettingsSection {
    id: root

    property var hostPopup

    title: "Java memory"
    searchHost: hostPopup
    searchBlob: "java executable memory ram start script minimum maximum heap xms xmx"

    function javaSuggestions(query) {
        const available = typeof utils !== "undefined" && utils
            ? utils.javaExecutables() : []
        const normalized = query.trim().toLowerCase()
        return available.filter(function(path) {
            return normalized.length === 0
                || path.toLowerCase().indexOf(normalized) >= 0
        })
    }

    ServerSettingCard {
        label: "Java executable"
        description: "Java command or absolute path used to start this server."
        settingKey: "java-executable"
        searchHost: root.hostPopup

        CustomTextField {
            id: javaField
            anchors.fill: parent
            showSearchIcon: false
            text: root.hostPopup ? root.hostPopup.javaExecutable : "java"
            onTextEdited: {
                if (root.hostPopup)
                    root.hostPopup.javaExecutable = text
            }
            onActiveFocusChanged: if (activeFocus) javaPopup.open()
            onAccepted: {
                if (root.hostPopup)
                    root.hostPopup.save()
            }

            Popup {
                id: javaPopup
                y: javaField.height + 4
                width: javaField.width
                padding: 4
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                visible: javaField.activeFocus && javaList.count > 0

                background: Rectangle {
                    color: Theme.surface
                    border.color: Theme.border
                    radius: 6
                }

                ListView {
                    id: javaList
                    width: parent.width
                    height: Math.min(contentHeight, 140)
                    model: root.javaSuggestions(javaField.text)
                    clip: true

                    delegate: Label {
                        required property string modelData
                        width: javaList.width
                        height: 28
                        text: modelData
                        color: Theme.text
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideMiddle

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                javaField.text = modelData
                                if (root.hostPopup)
                                    root.hostPopup.javaExecutable = modelData
                                javaField.forceActiveFocus()
                                javaField.cursorPosition = javaField.length
                            }
                        }
                    }
                }
            }
        }
    }

    ServerSettingCard {
        label: "Minimum memory"
        description: "Initial Java heap size (e.g. 2G, 1024M)."
        settingKey: "java-xms"
        searchHost: root.hostPopup

        CustomTextField {
            anchors.fill: parent
            showSearchIcon: false
            text: root.hostPopup ? root.hostPopup.minimumMemory : "2G"
            onTextEdited: {
                if (root.hostPopup)
                    root.hostPopup.minimumMemory = text
            }
            onAccepted: {
                if (root.hostPopup)
                    root.hostPopup.save()
            }
        }
    }

    ServerSettingCard {
        label: "Maximum memory"
        description: "Maximum Java heap size (e.g. 4G, 2048M)."
        settingKey: "java-xmx"
        searchHost: root.hostPopup

        CustomTextField {
            anchors.fill: parent
            showSearchIcon: false
            text: root.hostPopup ? root.hostPopup.maximumMemory : "4G"
            onTextEdited: {
                if (root.hostPopup)
                    root.hostPopup.maximumMemory = text
            }
            onAccepted: {
                if (root.hostPopup)
                    root.hostPopup.save()
            }
        }
    }
}
