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

        // TODO: give each one a unique border to make them apparent and popout (from the theme) 
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

            ColumnLayout {
                Layout.preferredWidth: 120
                Layout.minimumWidth : 120
                Layout.maximumWidth : 120
                spacing: 3


                Label {
                    text: "Port"
                    color: Theme.subtext2
                }

                RowLayout {
                    spacing: 4

                    Label {
                        text: runner && runner.port > 0
                            ? runner.port
                            : "--"
                        color: runner && runner.port > 0 ? Theme.text : Theme.subtext2
                    }

                    Item { Layout.fillWidth: true }

                    IconButton {
                        iconSize: 18
                        visible: runner !== null && runner.port > 0
                        iconSource: root.portCopied
                            ? "qrc:/icons/check.svg"
                            : "qrc:/icons/copy.svg"
                        ToolTip.text: root.portCopied ? "Copied" : "Copy address"
                        ToolTip.visible: hovered
                        onClicked: {
                            if (root.utilsObject
                                    && root.utilsObject.copyToClipboard(runner.address())) {
                                root.portCopied = true
                                portCopyTimer.restart()
                            }
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
