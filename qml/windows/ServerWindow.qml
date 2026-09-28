import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Grassy 1.0
import "../theme" 1.0
import "../components" 1.0
import "../terminal" 1.0

Window {
    id: root

    property string serverFolder
    property string serverTitle
    property var runner: localRunner
    property var utilsObject: typeof utils !== "undefined" ? utils : null
    property bool portCopied: false

    modality: Qt.NonModal
    flags: Qt.Window
    Timer {
        id: portCopyTimer
        interval: 1500
        onTriggered: root.portCopied = false
    }

    ServerRunner {
        id: localRunner
    }

    width: 900
    height: 600
    minimumWidth: 600
    minimumHeight: 360
    color: Theme.background
    title: runner
        ? (serverTitle.length > 0 ? serverTitle : "Server")
        : "error: runner is null"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            CustomLabeledProgressBar {
                Layout.minimumWidth : 220
                runner: root.runner
                label: "RAM"
                current_value: root.runner ? root.runner.memoryUsageKb : 0
                maximum_value: root.runner ? root.runner.memoryLimitKb : 0
                value_text: root.runner
                    ? (root.runner.memoryUsageKb / 1024).toFixed(1) + " / "
                        + (root.runner.memoryLimitKb / 1024).toFixed(1) + " MB"
                    : ""
            }
            Item {
                id: addressContainer

                Layout.preferredWidth: 220
                Layout.minimumWidth: 220
                Layout.maximumWidth: 220

                implicitHeight: addressCard.implicitHeight + 12
                implicitWidth: addressCard.implicitWidth + 12

                Rectangle {
                    z: -1
                    anchors.fill: parent

                    color: addressMouse.containsMouse
                        ? Theme.surface2
                        : Theme.surface0

                    border.color: Theme.surface2
                    border.width: 1
                    radius: 6
                }

                ColumnLayout {
                    id: addressCard

                    spacing: 3
                    anchors.fill: parent
                    anchors.margins: 6

                    property string address: runner && runner.port > 0
                        ? utils.publicIp + ":" + runner.port
                        : "--"

                    Label {
                        text: "Public IP + Port"
                        color: Theme.text
                    }

                    RowLayout {
                        spacing: 4

                        Label {
                            Layout.fillWidth: true

                            text: addressMouse.containsMouse
                                ? addressCard.address
                                : "Hover to reveal"

                        color: Theme.subtext2

                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }

                MouseArea {
                    id: addressMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    ToolTip.text: root.portCopied ? "Copied" : "Copy address"
                    ToolTip.visible: addressMouse.containsMouse

                    onClicked: {
                        if (root.utilsObject &&
                            root.utilsObject.copyToClipboard(addressCard.address)) {

                            root.portCopied = true
                            portCopyTimer.restart()
                        }
                    }
                }
            }
            CustomLabeledProgressBar {
                Layout.minimumWidth : 220
                runner: root.runner
                label: "CPU"
                current_value: root.runner ? root.runner.cpuUsage : 0
                maximum_value: root.runner ? root.runner.cpuCoreCount * 100 : 0
                value_text: root.runner
                    ? root.runner.cpuUsage.toFixed(1) + "% ("
                        + root.runner.cpuCoreCount + " cores)"
                    : ""
            }
        }

        ServerTerminal {
            id: terminal
            runner: root.runner
            Layout.fillWidth: true
            Layout.fillHeight: true

            borderColor: runner
                ? (runner.running ? Theme.success : Theme.subtext2)
                : Theme.failure
        }
    }

    function openForServer(folder, name) {
        serverFolder = folder
        serverTitle = name
        portCopied = false
        if (!runner) {
            console.warn("error: runner is null")
            return
        }

        runner.serverFolder = folder
        show()
        raise()
        requestActivate()
        runner.start()
    }

    onClosing: function(close) {
        if (runner)
            runner.shutdown()
    }
}
