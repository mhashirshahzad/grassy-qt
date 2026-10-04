import "."
import "../components" 1.0
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

CustomPopup {
    id: root

    property var modelObject

    signal minecraftSelected()
    signal fabricSelected()
    signal forgeSelected()
    signal ftbSelected()

    function openFresh() {
        root.open();
    }

    function closeAfterInstall() {
        closeTimer.restart();
    }

    width: Math.min(parent ? parent.width - 32 : 520, 520)
    height: content.implicitHeight + topPadding + bottomPadding

    Timer {
        id: closeTimer

        interval: 1000
        repeat: false
        onTriggered: root.close()
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
                root.close();
                root.minecraftSelected();
            }
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "Fabric"
            onClicked: {
                root.close();
                root.fabricSelected();
            }
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "Forge"
            onClicked: {
                root.close();
                root.forgeSelected();
            }
        }

        ThemedButton {
            Layout.fillWidth: true
            text: "FTB modpack"
            enabled: false
            ToolTip.visible: hovered
            ToolTip.text: "FTB modpack downloading is not available yet."
            onClicked: root.ftbSelected()
        }

        Item {
            Layout.fillHeight: true
        }

    }

}
