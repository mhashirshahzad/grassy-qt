import "../components" 1.0
import "../runner" 1.0
import "../theme" 1.0
import "../popups" 1.0
import Grassy 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Window {
    id: root

    property string serverFolder
    property string serverTitle
    property var runner: localRunner
    property var utilsObject: typeof utils !== "undefined" ? utils : null
    property bool portCopied: false
    property bool closeApproved: false
    property bool safeClosing: false

    function openForServer(folder, name) {
        serverFolder = folder;
        serverTitle = name;
        portCopied = false;
        closeApproved = false;
        safeClosing = false;
        if (!runner) {
            console.warn("error: runner is null");
            return ;
        }
        runner.serverFolder = folder;
        show();
        raise();
        requestActivate();
        runner.start();
    }

    modality: Qt.NonModal
    flags: Qt.Window
    transientParent: null
    width: 900
    height: 600
    minimumWidth: 600
    minimumHeight: 360
    color: Theme.background
    title: runner ? (serverTitle.length > 0 ? serverTitle : "Server") : "error: runner is null"
    onClosing: function(close) {
        if (closeApproved)
            return;

        if (runner && runner.running) {
            close.accepted = false;
            closeServerPopup.open();
        } else if (runner) {
            runner.shutdown();
        }
    }

    Connections {
        target: root.runner

        function onRunningChanged() {
            if (root.safeClosing && root.runner && !root.runner.running) {
                root.closeApproved = true;
                closeServerPopup.close();
                root.close();
            }
        }
    }

    Timer {
        id: portCopyTimer

        interval: 1500
        onTriggered: root.portCopied = false
    }

    ServerRunner {
        id: localRunner

        themePalette: Theme.palette
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            CustomLabeledProgressBar {
                Layout.minimumWidth: 220
                Layout.preferredWidth: 220
                runner: root.runner
                label: "RAM"
                currentValue: root.runner ? root.runner.memoryUsageKb : 0
                maximumValue: root.runner ? root.runner.memoryLimitKb : 0
                valueText: root.runner ? (root.runner.memoryUsageKb / 1024).toFixed(1) + " / " + (root.runner.memoryLimitKb / 1024).toFixed(1) + " MB" : ""
            }

            Item {
                id: addressContainer

                Layout.minimumWidth: 220
                Layout.preferredWidth: 220
                Layout.fillWidth: true
                implicitHeight: addressCard.implicitHeight + 12
                implicitWidth: addressCard.implicitWidth + 12

                Rectangle {
                    z: -1
                    anchors.fill: parent
                    color: addressMouse.containsMouse ? Theme.surface2 : Theme.surface0
                    border.color: Theme.surface2
                    border.width: 1
                    radius: Theme.radius

                    Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 140 } }
                }

                ColumnLayout {
                    id: addressCard

                    property string address: runner && runner.port > 0 ? (root.utilsObject ? root.utilsObject.publicIp : "Unavailable") + ":" + runner.port : "--"

                    spacing: 4
                    anchors.fill: parent
                    anchors.margins: 8

                    Label {
                        text: "Public IP + Port"
                        color: Theme.text
                    }

                    RowLayout {
                        spacing: 4

                        Label {
                            Layout.fillWidth: true
                            text: addressMouse.containsMouse ? addressCard.address : "Hover to reveal"
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
                        if (root.utilsObject && root.utilsObject.copyToClipboard(addressCard.address)) {
                            root.portCopied = true;
                            portCopyTimer.restart();
                        }
                    }
                }

            }

            CustomLabeledProgressBar {
                Layout.minimumWidth: 220
                Layout.preferredWidth: 220
                runner: root.runner
                label: "CPU"
                currentValue: root.runner ? root.runner.cpuUsage : 0
                maximumValue: root.runner ? root.runner.cpuCoreCount * 100 : 0
                valueText: root.runner ? root.runner.cpuUsage.toFixed(1) + "% (" + root.runner.cpuCoreCount + " cores)" : ""
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                id: serverPages

                anchors.fill: parent
                readonly property var pageIndices: ({ "Terminal": 0, "Players": 1, "Resources": 2 })
                currentIndex: pageIndices[serverTabs.currentTab] !== undefined ? pageIndices[serverTabs.currentTab] : serverTabs.currentIndex

                ServerTerminal {
                    id: terminal

                    runner: root.runner
                    borderColor: runner ? (runner.running ? Theme.success : Theme.subtext2) : Theme.failure
                }

                ServerPlayers { }

                ServerResources {
                    runner: root.runner
                }

            }

            ThemedTabBar {
                id: serverTabs

                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 10
                z: 2
                tabs: ["Terminal", "Players", "Resources"]
            }
        }

    }

    ServerClosePopup {
        id: closeServerPopup
        parent: root.contentItem
        anchors.centerIn: parent

        safeClosing: root.safeClosing

        onCloseSafelyRequested: {
            root.safeClosing = true;
            closeServerPopup.safeClosing = true
            
            Qt.callLater(function() {
                if (root.runner)
                    root.runner.shutdown();
            });
                    
        }

        onForceCloseRequested: {
            root.closeApproved = true;
            closeServerPopup.close();

            if (root.runner)
                root.runner.forceShutdown();

            root.close();
        }
    }
}
