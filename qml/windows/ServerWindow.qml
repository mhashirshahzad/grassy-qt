import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "." 1.0

Window {
    id: root

    property string serverFolder
    property string serverTitle
    property var runner: null

    width: 900
    height: 600
    minimumWidth: 600
    minimumHeight: 360
    color: Theme.background
    title: runner
        ? (serverTitle.length > 0 ? serverTitle + " - Console" : "Server Console")
        : "error: runner is null"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: runner ? root.title : "error: runner is null"
                color: Theme.text
                font.bold: true
                font.pixelSize: 18
                Layout.fillWidth: true
            }

            Label {
                text: runner
                    ? (runner.running ? "Running" : "Stopped")
                    : "error: runner is null"
                color: runner
                    ? (runner.running ? Theme.success : Theme.subtext)
                    : Theme.failure
            }
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: runner
                    ? (runner.running ? Theme.success : Theme.subtext2)
                    : Theme.failure
            }
        }

        ServerTerminal {
            id: terminal
            runner: root.runner
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    function openForServer(folder, name) {
        serverFolder = folder
        serverTitle = name
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
