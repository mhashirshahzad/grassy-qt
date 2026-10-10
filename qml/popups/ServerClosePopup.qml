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
    height: safeClosing ? 180 : 260

    modal: true
    dim: true
    padding: 20
    closePolicy: Popup.NoAutoClose
    showCloseButton: !safeClosing
    destructiveClose: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

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
                ? "Waiting for the server to save world data and stop cleanly..."
                : "The server is still running. Wait for it to stop safely or force close it."

            color: Theme.subtext
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        // Playful status indicator
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64

            // Warning icon when asking
            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/warning.svg"
                sourceSize: Qt.size(54, 54)
                visible: !root.safeClosing
            }

            // Playful pulsing spinner when closing
            Item {
                anchors.fill: parent
                visible: root.safeClosing

                Rectangle {
                    id: pulseRing
                    anchors.centerIn: parent
                    width: 48
                    height: 48
                    radius: width / 2
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: 3

                    RotationAnimation on rotation {
                        running: root.safeClosing
                        from: 0
                        to: 360
                        duration: 1200
                        loops: Animation.Infinite
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    radius: width / 2
                    color: Theme.accent

                    SequentialAnimation on scale {
                        running: root.safeClosing
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.3; duration: 600; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 0.8; duration: 600; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        // Action buttons
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
                onClicked: root.forceCloseRequested()
            }
        }

        // Secondary force-close option while waiting for safe close
        RowLayout {
            Layout.fillWidth: true
            visible: root.safeClosing

            ThemedButton {
                Layout.fillWidth: true
                text: "Force close now"
                buttonColor: Theme.failureMuted
                buttonHoverColor: Theme.failure
                buttonPressedColor: Theme.failureMuted
                onClicked: root.forceCloseRequested()
            }
        }
    }
}
