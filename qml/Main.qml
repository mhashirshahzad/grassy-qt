import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
// import QtQuick.Controls 2.15

import "theme" 1.0
import "components" 1.0
import "dialogs" 1.0
import "windows" 1.0

ApplicationWindow {
    id: root
    property var modelObject: typeof serverModel !== "undefined" ? serverModel : null
    property var runnerObject: typeof serverRunner !== "undefined" ? serverRunner : null
    title: "Grassy Qt"

    font.family: Theme.fontFamily

    visible: true
    width: 800
    height: 600
    color: Theme.background


    CustomTitleBar {
        id: customTitleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        window: root

        z: 10
        onReloadClicked: {
            if (root.modelObject)
                root.modelObject.refresh()
            else
                console.warn("error: serverModel is null")
        }
        onSettingsClicked: {
            appSettings.open()
        }
    }

    ServerWindow {
        id: serverWindow
        runner: root.runnerObject
    }

    ListView {
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
            serverName: name
            serverMotd: motd
            serverFolder: folder
            serverRunning: root.runnerObject !== null
                && root.runnerObject.running
                && root.runnerObject.serverFolder === folder
            onStartClicked: serverWindow.openForServer(folder, name)
            onEditClicked: {
                renameDialog.serverFolder = folder
                renameDialog.serverName = name
                renameDialog.errorMessage = ""
                renameDialog.open()
            }
            onSettingsClicked: {
                settingsDialog.serverFolder = folder
                settingsDialog.propertiesText = root.modelObject
                    ? root.modelObject.serverProperties(folder)
                    : ""
                settingsDialog.errorMessage = ""
                settingsDialog.open()
            }
            onFolderClicked: Qt.openUrlExternally("file://" + folder)
            onDeleteClicked: {
                deleteDialog.serverFolder = folder
                deleteDialog.serverName = name
                deleteDialog.errorMessage = ""
                deleteDialog.open()
            }
        }

        // ScrollBar.vertical: ScrollBar {
        //     policy: ScrollBar.AlwaysOn
        // }
    }
    JavaStatusBar {
        id: javaStatusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom : parent.bottom

    }

    RenameServerDialog {
        id: renameDialog
        modelObject: root.modelObject
    }

    ServerPropertiesDialog {
        id: settingsDialog
        modelObject: root.modelObject
    }

    DeleteServerDialog {
        id: deleteDialog
        modelObject: root.modelObject
    }

    SettingsWindow {
        id: appSettings
        utilsObject: typeof utils !== "undefined" ? utils : null
        onDirectorySaved: {
            if (root.modelObject)
                root.modelObject.refresh()
        }
    }
    
}
