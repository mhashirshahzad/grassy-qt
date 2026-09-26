import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0
import "../components" 1.0

FocusScope {
    id: root

    property var runner: null
    property color borderColor: Theme.border

    Rectangle {
        id: terminalFrame
        anchors.fill: parent
        color: Theme.surface0
        border.color: root.borderColor
        radius: 6

        Flickable {
            id: outputScroll
            anchors.fill: parent
            anchors.margins: 12
            anchors.bottomMargin: commandBar.height + 24
            contentWidth: width
            contentHeight: outputText.implicitHeight
            clip: true
            onContentHeightChanged: Qt.callLater(root.scrollToBottom)

            TextEdit {
                id: outputText
                width: outputScroll.width
                readOnly: true
                text: root.runner
                    ? root.runner.consoleHtml
                    : "error: runner is null"
                textFormat: TextEdit.RichText
                color: Theme.text
                font.family: Theme.monoFamily
                font.pixelSize: 13
                selectByMouse: true
                wrapMode: TextEdit.Wrap
                onTextChanged: Qt.callLater(root.scrollToBottom)
            }
        }

        RowLayout {
            id: commandBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            spacing: 8

            TextField {
                id: commandInput
                Layout.fillWidth: true
                placeholderText: root.runner
                    ? "Enter a server command..."
                    : "error: runner is null"
                enabled: root.runner !== null
                color: Theme.text
                placeholderTextColor: Theme.subtext
                selectionColor: Theme.selection
                selectedTextColor: Theme.textBright
                leftPadding: 12
                rightPadding: 12
                background: Rectangle {
                    radius: 6
                    color: Theme.surface
                    border.width: commandInput.activeFocus ? 1 : 0
                    border.color: Theme.borderFocus
                }
                onAccepted: {
                    if (root.runner)
                        root.runner.sendCommand(text)
                    text = ""
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_C &&
                            (event.modifiers & Qt.ControlModifier)) {
                        if (root.runner)
                            root.runner.interrupt()
                        event.accepted = true
                    }
                }

            }

            ThemedButton {
                text: "Stop"
                enabled: root.runner !== null && root.runner.running
                buttonColor: "#7f1d2d"
                buttonHoverColor: "#a52a3d"
                buttonPressedColor: "#5b1421"
                buttonTextColor: "#000000"
                onClicked: if (root.runner) root.runner.stop()
            }
        }
    }

    Component.onCompleted: commandInput.forceActiveFocus()

    function scrollToBottom() {
        outputScroll.contentY = Math.max(
            0, outputScroll.contentHeight - outputScroll.height
        )
    }
}
