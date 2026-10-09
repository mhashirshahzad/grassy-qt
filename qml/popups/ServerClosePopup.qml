import "../components" 1.0
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// TODO: Fix the fact that the labbels never get updated as serverWindow just goes into
// close state and doesnt update
CustomPopup {
    id: root

    property bool safeClosing: false

    signal closeSafelyRequested()
    signal forceCloseRequested()

    width: 420
    height: safeClosing ? 180 : 230

    modal: true
    dim: true
    padding: 20
    closePolicy: Popup.NoAutoClose
    showCloseButton: !safeClosing
    destructiveClose: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Label {
            Layout.fillWidth: true

            text: root.safeClosing
                ? "Closing server..."
                : "Close server safely?"

            color: Theme.textBright
            font.pixelSize: 20
            font.bold: true
        }

        Label {
            Layout.fillWidth: true

            text: root.safeClosing
                ? "Waiting for the server to stop safely."
                : "The server is still running. Wait for it to stop safely or force close it."

            color: Theme.subtext
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/icons/warning.svg"
            sourceSize: Qt.size(64, 64)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: !root.safeClosing

            ThemedButton {
                Layout.fillWidth: true

                text: "Close safely"

                onClicked: root.closeSafelyRequested()
            }

            ThemedButton {
                Layout.fillWidth: true

                text: "Force close"

                buttonColor: Theme.failure
                buttonHoverColor: Theme.failureHover
                buttonPressedColor: Theme.failureMuted
                buttonTextColor: Theme.textBright

                onClicked: root.forceCloseRequested()
            }
        }
    }
}
