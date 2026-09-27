import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

ServerSettingsSection {
    id: root

    property var hostPopup

    title: "Java memory"
    searchHost: hostPopup
    searchBlob: "java memory ram start script minimum maximum heap xms xmx"

    ServerSettingCard {
        label: "Minimum memory"
        description: "Initial Java heap size (e.g. 2G, 1024M)."
        settingKey: "java-xms"
        searchHost: root.hostPopup

        CustomTextField {
            anchors.fill: parent
            showSearchIcon: false
            backgroundColor: Theme.surface2
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
            backgroundColor: Theme.surface2
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
