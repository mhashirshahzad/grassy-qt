// import QtQuick.Controls 2.15

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "components"
import "popups"
import "popups/downloaders" 1.0
import "theme"
import "runner"

ApplicationWindow {
    id: root

    property var modelObject: typeof serverModel !== "undefined" ? serverModel : null
    property var serverWindows: []
    property int runningRevision: 0

    function openServer(folder, name) {
        const window = serverWindowComponent.createObject(null);
        if (!window) {
            console.warn("Could not create server window");
            return ;
        }
        serverWindows.push(window);
        window.closing.connect(function() {
            const index = serverWindows.indexOf(window);
            if (index >= 0)
                serverWindows.splice(index, 1);

            runningRevision++;
        });
        window.runner.runningChanged.connect(function() {
            runningRevision++;
            metadataRefreshTimer.restart();
        });
        window.openForServer(folder, name);
        runningRevision++;
    }

    function isServerRunning(folder) {
        for (const window of serverWindows) {
            if (window.runner && window.runner.serverFolder === folder && window.runner.running)
                return true;

        }
        return false;
    }

    title: "Grassy Qt"
    font.family: Theme.fontFamily
    visible: true
    width: 800
    height: 600
    color: Theme.background
    onActiveChanged: {
        if (active)
            raise();

    }

    Timer {
        id: metadataRefreshTimer

        interval: 1500
        repeat: false
        onTriggered: {
            if (root.modelObject) {
                root.modelObject.refresh();
            }
        }
    }

    Shortcut {
        sequences: ["Ctrl+R"]
        context: Qt.WindowShortcut
        onActivated: root.modelObject ? root.modelObject.refresh() : undefined
    }

    CustomTitleBar {
        id: customTitleBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        window: root
        z: 10
        onReloadClicked: {
            if (root.modelObject)
                root.modelObject.refresh();
            else
                console.warn("error: serverModel is null");
        }
        onSettingsClicked: {
            appSettings.open();
        }
    }

    ThemeTransition {
    }

    Component {
        id: serverWindowComponent

        ServerWindow {
        }

    }

    ListView {
        // ScrollBar.vertical: ScrollBar {
        //     policy: ScrollBar.AlwaysOn
        // }

        id: serverList

        anchors.top: customTitleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: javaStatusBar.top
        anchors.margins: 12
        spacing: 12
        model: root.modelObject

        delegate: ServerCard {
            required property string name
            required property string motd
            required property string folder
            required property string serverTypeRole
            required property bool serverInstallRequired
            required property string serverMetadataText

            serverName: name
            serverMotd: motd
            serverFolder: folder
            serverType: serverTypeRole
            installRequired: serverInstallRequired
            serverMetadata: serverMetadataText
            modelObject: root.modelObject
            serverRunning: root.runningRevision >= 0 && root.isServerRunning(folder)
            onStartClicked: root.openServer(folder, name)
            onFolderClicked: Qt.openUrlExternally("file://" + folder)
        }

    }

    DropArea {
        id: fileDropArea
        anchors.top: customTitleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: javaStatusBar.top

        property bool activeDrag: false

        onEntered: function(drag) {
            if (drag.hasUrls) {
                drag.acceptProposedAction();
                activeDrag = true;
            }
        }
        onExited: {
            activeDrag = false;
        }
        onDropped: function(drop) {
            activeDrag = false;
            if (drop.hasUrls && drop.urls.length > 0) {
                if (root.modelObject) {
                    addServerPopup.openFresh();
                    root.modelObject.refresh();
                }
            }
        }
    }

    // Playful Drag & Drop Target Overlay
    Rectangle {
        anchors.fill: fileDropArea
        anchors.margins: 16
        radius: Theme.radiusLarge
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.90)
        border.color: Theme.accent
        border.width: 2
        visible: fileDropArea.activeDrag
        opacity: fileDropArea.activeDrag ? 1 : 0
        scale: fileDropArea.activeDrag ? 1.0 : 0.94
        z: 20

        Behavior on opacity { NumberAnimation { duration: 160 } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/icons/folder.svg"
                sourceSize: Qt.size(48, 48)
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Drop Minecraft server folder or jar here"
                font.pixelSize: 18
                font.bold: true
                color: Theme.accent
            }
        }
    }

    JavaStatusBar {
        id: javaStatusBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    GrassySettingsPopup {
        id: appSettings

        utilsObject: typeof utils !== "undefined" ? utils : null
        onDirectorySaved: {
            if (root.modelObject)
                root.modelObject.refresh();

        }
    }

    AddServerPopup {
        id: addServerPopup

        parent: Overlay.overlay
        modelObject: root.modelObject
        anchors.centerIn: parent
    }

    MinecraftServerPopup {
        id: minecraftServerPopup

        parent: Overlay.overlay
        modelObject: root.modelObject
        anchors.centerIn: parent
    }

    FabricServerPopup {
        id: fabricServerPopup

        parent: Overlay.overlay
        modelObject: root.modelObject
        anchors.centerIn: parent
    }

    ForgeServerPopup {
        id: forgeServerPopup

        parent: Overlay.overlay
        modelObject: root.modelObject
        anchors.centerIn: parent
    }

    Connections {
        function onMinecraftSelected() {
            minecraftServerPopup.openFresh();
        }

        function onFabricSelected() {
            fabricServerPopup.openFresh();
        }

        function onForgeSelected() {
            forgeServerPopup.openFresh();
        }

        target: addServerPopup
    }

    Connections {
        function onInstallationCompleted() {
            addServerPopup.closeAfterInstall();
        }

        target: minecraftServerPopup
    }

    Connections {
        function onInstallationCompleted() {
            addServerPopup.closeAfterInstall();
        }

        target: fabricServerPopup
    }

    Connections {
        function onInstallationCompleted() {
            addServerPopup.closeAfterInstall();
        }

        target: forgeServerPopup
    }

    Connections {
        function onAddServerClicked() {
            addServerPopup.openFresh();
        }

        target: customTitleBar
    }

}
