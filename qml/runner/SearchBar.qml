import "../components"
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property alias query: searchInput.text
    property int currentMatch: -1
    property int matchCount: 0
    property bool shown: false

    signal closeClicked
    signal nextClicked
    signal previousClicked
    signal searchSubmitted(bool backward)

    function focusSearch() {
        searchInput.forceActiveFocus();
        searchInput.selectAll();
    }

    function showSearch() {
        shown = true;
        visible = true;
        focusSearch();
    }

    function hideSearch() {
        shown = false;
        searchInput.clear();
    }

    function clearSearch() {
        searchInput.clear();
    }

    color: Theme.surface
    border.color: Theme.border
    radius: 6
    visible: shown || opacity > 0
    enabled: shown
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.92

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        SpringAnimation {
            spring: 3
            damping: 0.25
            mass: 0.8
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 4

        TextField {
            id: searchInput

            Layout.fillWidth: true
            Layout.minimumWidth: 100
            placeholderText: "Find in terminal"
            color: Theme.text
            placeholderTextColor: Theme.subtext
            selectionColor: Theme.selection
            selectedTextColor: Theme.textBright
            leftPadding: 8
            rightPadding: 8
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.closeClicked();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.searchSubmitted(event.modifiers & Qt.ShiftModifier);
                    event.accepted = true;
                }
            }

            background: Rectangle {
                radius: 4
                color: Theme.surface0
                border.width: searchInput.activeFocus ? 1 : 0
                border.color: Theme.borderFocus
            }
        }

        Label {
            text: root.matchCount > 0 ? (root.currentMatch + 1) + " / " + root.matchCount : "0 / 0"
            color: Theme.subtext
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 42
        }

        ThemedButton {
            buttonColor: Theme.surface0
            buttonHoverColor: Theme.surface0
            buttonPressedColor: Theme.surface1
            buttonTextColor: Theme.text
            text: "<"
            enabled: root.matchCount > 0
            Layout.preferredWidth: 24
            Layout.preferredHeight: 28
            leftPadding: 0
            rightPadding: 0
            onClicked: root.previousClicked()
        }

        ThemedButton {
            buttonColor: Theme.surface0
            buttonHoverColor: Theme.surface0
            buttonPressedColor: Theme.surface1
            buttonTextColor: Theme.text
            text: ">"
            enabled: root.matchCount > 0
            Layout.preferredWidth: 24
            Layout.preferredHeight: 28
            leftPadding: 0
            rightPadding: 0
            onClicked: root.nextClicked()
        }

        ThemedButton {
            buttonColor: Theme.surface0
            buttonHoverColor: Theme.surface0
            buttonPressedColor: Theme.surface1
            buttonTextColor: Theme.text
            text: "x"
            Layout.preferredWidth: 24
            Layout.preferredHeight: 28
            leftPadding: 0
            rightPadding: 0
            onClicked: root.closeClicked()
        }
    }
}
