import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0
import "../components" 1.0
import "."

CustomPopup {
    id: root

    property var modelObject

    signal minecraftSelected()
    signal fabricSelected()
    signal forgeSelected()
    signal ftbSelected()

    width: Math.min(parent ? parent.width - 32 : 520, 520)
    height: content.implicitHeight + topPadding + bottomPadding

    function openFresh() {
        root.open()
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: 12

        Label {
            text: "Add server"
            color: Theme.textBright
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            text: "Choose how you want to install the server."
            color: Theme.subtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "Minecraft"
            onClicked: {
                root.close()
                root.minecraftSelected()
            }
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "Fabric"
            onClicked: {
                root.close()
                root.fabricSelected()
            }
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "Forge"
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: "Forge downloading is not available yet."
            onClicked: root.forgeSelected()
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "FTB modpack"
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: "FTB modpack downloading is not available yet."
            onClicked: root.ftbSelected()
        }

        Item { Layout.fillHeight: true }
    }
}
