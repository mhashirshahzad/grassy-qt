import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
// import QtQuick.Controls 2.15

import "theme" 1.0
import "components" 1.0
import "windows" 1.0

Window {
    id: root
    property var modelObject: typeof serverModel !== "undefined" ? serverModel : null
    property var runnerObject: typeof serverRunner !== "undefined" ? serverRunner : null
    title: "Grassy Qt"

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
                renameFolder = folder
                renameName = name
                renameError = ""
                renameDialog.open()
            }
            onSettingsClicked: {
                settingsFolder = folder
                settingsText = root.modelObject
                    ? root.modelObject.serverProperties(folder)
                    : ""
                settingsError = ""
                settingsDialog.open()
            }
            onFolderClicked: Qt.openUrlExternally("file://" + folder)
            onDeleteClicked: {
                deleteFolder = folder
                deleteName = name
                deleteError = ""
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

    property string renameFolder
    property string renameName
    property string renameError
    property string settingsFolder
    property string settingsText
    property string settingsError
    property string deleteFolder
    property string deleteName
    property string deleteError

    Dialog {
        id: renameDialog
        title: "Rename server folder"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        onAccepted: {
            if (!root.modelObject || !root.modelObject.renameServer(
                    root.renameFolder, root.renameName)) {
                root.renameError = "Could not rename the server folder."
                open()
            }
        }

        ColumnLayout {
            width: 360
            spacing: 10

            Label { text: "New folder name" }
            TextField {
                id: renameField
                Layout.fillWidth: true
                text: root.renameName
                onTextChanged: root.renameName = text
                Component.onCompleted: selectAll()
            }
            Label {
                text: root.renameError
                color: Theme.failure
                visible: text.length > 0
            }
        }
    }

    Dialog {
        id: settingsDialog
        title: "Edit server.properties"
        modal: true
        standardButtons: Dialog.Save | Dialog.Cancel
        anchors.centerIn: parent
        onAccepted: {
            if (!root.modelObject || !root.modelObject.saveServerProperties(
                    root.settingsFolder, root.settingsText)) {
                root.settingsError = "Could not save server.properties."
                open()
            }
        }

        ColumnLayout {
            width: 620
            height: 420
            spacing: 8

            Label {
                text: "Changes apply the next time the server starts."
                color: Theme.subtext
            }
            TextArea {
                id: propertiesEditor
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.settingsText
                wrapMode: TextEdit.NoWrap
                font.family: "monospace"
                color: Theme.text
                selectByMouse: true
                background: Rectangle {
                    color: Theme.surface0
                    border.color: Theme.border
                    radius: 6
                }
                onTextChanged: root.settingsText = text
            }
            Label {
                text: root.settingsError
                color: Theme.failure
                visible: text.length > 0
            }
        }
    }

    Dialog {
        id: deleteDialog
        title: "Delete server"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        onAccepted: {
            if (!root.modelObject || !root.modelObject.deleteServer(root.deleteFolder)) {
                root.deleteError = "Could not delete the server folder."
                open()
            }
        }

        ColumnLayout {
            width: 400
            spacing: 12

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/icons/warning.svg"
                sourceSize: Qt.size(48, 48)
            }
            Label {
                Layout.fillWidth: true
                text: "Delete \"%1\" and all of its files permanently?"
                    .arg(root.deleteName)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                text: root.deleteError
                color: Theme.failure
                visible: text.length > 0
            }
        }
    }
    
}
