import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0
import "../components" 1.0

Popup {
    id: root

    property var utilsObject: null
    signal directorySaved()
    property bool localIpCopied: false
    property bool publicIpCopied: false

    width: Math.min(parent ? parent.width - 40 : 620, 620)
    height: Math.min(parent ? parent.height - 40 : 360, 360)
    anchors.centerIn: Overlay.overlay
    modal: true
    dim: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    background: Rectangle {
        color: Theme.background
        border.color: Theme.border
        border.width: 1
        radius: 12
    }

    IconButton {
        id: closeButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.rightMargin: 14
        iconSource: "qrc:/icons/close.svg"
        destructive: true
        ToolTip.text: "Close"
        ToolTip.visible: hovered
        z: 2
        onClicked: root.close()
    }

    Overlay.modal: Rectangle {
        color: "#99000000"
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "scale"
                from: 0.92
                to: 1
                duration: 180
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 140
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.96
                duration: 120
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 100
            }
        }
    }

    function saveDirectory() {
        const path = directoryField.text.trim()
        if (!utilsObject || path.length === 0 || !utilsObject.saveServersDirectory(path)) {
            errorLabel.text = "Could not save that folder."
            return
        }
        errorLabel.text = ""
        directorySaved()
        root.close()
    }

    onOpened: {
        errorLabel.text = ""
        localIpCopied = false
        publicIpCopied = false
    }

    Component.onCompleted: {
        if (utilsObject)
            directoryField.text = utilsObject.serversDirectory
    }

    Connections {
        target: root.utilsObject
        function onServersDirectoryChanged() {
            directoryField.text = root.utilsObject.serversDirectory
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Label {
            text: "Server storage"
            font.pixelSize: 20
            font.bold: true
            Layout.rightMargin: closeButton.width + 12
        }

        Label {
            text: "Choose the folder where Grassy discovers Minecraft servers."
            color: Theme.subtext
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: directoryField
                Layout.fillWidth: true
                selectByMouse: true
                placeholderText: "Server folder path"
            }

            ThemedButton {
                text: "Browse"
                onClicked: {
                    if (utilsObject) {
                        const selected = utilsObject.chooseDirectory(directoryField.text)
                        if (selected.length > 0)
                            directoryField.text = selected
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        GridLayout {
            columns: 2
            columnSpacing: 20
            rowSpacing: 8

            Label { text: "Local IP"; color: Theme.subtext; Layout.fillWidth: true }
            RowLayout {
                spacing: 8

                Rectangle {
                    id: localIpCell
                    implicitWidth: 180
                    implicitHeight: 28
                    radius: 5

                    color: Theme.surface3
                    Label {
                        anchors.fill: parent
                        anchors.margins: 6

                        text: utilsObject ? utilsObject.localIp : "Unavailible"
                        color: Theme.text
                        elide: Text.ElideRight
                        verticalAlignment : Text.AlignVCenter
                    }
                }

                IconButton {
                    iconSource: localIpCopied
                        ? "qrc:/icons/check.svg"
                        : "qrc:/icons/copy.svg"
                    ToolTip.text: localIpCopied ? "Copied" : "Copy local IP"
                    ToolTip.visible: hovered
                    onClicked: {
                        if (utilsObject && utilsObject.copyToClipboard(utilsObject.localIp)) {
                            localIpCopied = true
                            localCopyTimer.restart()
                        }
                    }
                }
            }

            Label { text: "Public IP"; color: Theme.subtext ; Layout.fillWidth : true}
            RowLayout {
                spacing: 8

                Rectangle {
                    id: publicIpCell
                    implicitWidth: 180
                    implicitHeight: 28
                    color: publicIpMouse.containsMouse ? Theme.surface3 : Theme.surface2
                    radius: 5

                    Label {
                        anchors.fill: parent
                        anchors.margins: 6
                        text: publicIpMouse.containsMouse
                            ? (utilsObject ? utilsObject.publicIp : "Unavailable")
                            : "Hover to reveal"
                        color: Theme.text
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        id: publicIpMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                IconButton {
                    iconSource: publicIpCopied
                        ? "qrc:/icons/check.svg"
                        : "qrc:/icons/copy.svg"
                    ToolTip.text: publicIpCopied ? "Copied" : "Copy public IP"
                    ToolTip.visible: hovered
                    onClicked: {
                        if (utilsObject && utilsObject.copyToClipboard(utilsObject.publicIp)) {
                            publicIpCopied = true
                            publicCopyTimer.restart()
                        }
                    }
                }
            }
        }

        Label {
            id: errorLabel
            color: Theme.failure
            visible: text.length > 0
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8


            ThemedButton {
                text: "Save"
                onClicked: root.saveDirectory()
            }
        }

        Timer {
            id: localCopyTimer
            interval: 1200
            onTriggered: root.localIpCopied = false
        }

        Timer {
            id: publicCopyTimer
            interval: 1200
            onTriggered: root.publicIpCopied = false
        }
    }
}
