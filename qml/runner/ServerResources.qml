import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var runner: null

    color: Theme.surface0
    border.color: Theme.border
    radius: 6

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Resources"
            color: Theme.text
            font.bold: true
            font.pixelSize: 18
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Detailed resources will be coming soon :/"
            color: Theme.subtext
        }
    }
    // GridLayout {
    //     anchors.fill: parent
    //     anchors.margins: 16
    //     columns: 2
    //     rowSpacing: 12
    //     columnSpacing: 12

    //     Label { text: "Process status"; color: Theme.subtext }
    //     Label {
    //         text: root.runner && root.runner.running ? "Running" : "Stopped"
    //         color: root.runner && root.runner.running ? Theme.success : Theme.subtext2
    //     }
    //     Label { text: "CPU usage"; color: Theme.subtext }
    //     Label { text: root.runner ? root.runner.cpuUsage.toFixed(1) + "%" : "--"; color: Theme.text }
    //     Label { text: "CPU cores"; color: Theme.subtext }
    //     Label { text: root.runner ? root.runner.cpuCoreCount : "--"; color: Theme.text }
    //     Label { text: "Memory usage"; color: Theme.subtext }
    //     Label {
    //         text: root.runner ? (root.runner.memoryUsageKb / 1024).toFixed(1) + " MB" : "--"
    //         color: Theme.text
    //     }
    //     Label { text: "Memory limit"; color: Theme.subtext }
    //     Label {
    //         text: root.runner ? (root.runner.memoryLimitKb / 1024).toFixed(1) + " MB" : "--"
    //         color: Theme.text
    //     }
    //     Label { text: "Server port"; color: Theme.subtext }
    //     Label {
    //         text: root.runner && root.runner.port > 0 ? root.runner.port : "--"
    //         color: Theme.text
    //     }
    // }
}
