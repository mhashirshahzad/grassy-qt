import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "../theme" 1.0

Item {
    id: root

    property var options: []
    property int currentIndex: 0
    property bool editable: false
    readonly property bool editing: editable && editField.activeFocus
    property string editText: currentIndex >= 0 && currentIndex < options.length
        ? options[currentIndex] : ""
    signal activated(string value)
    signal textEdited(string value)

    implicitWidth: 220
    implicitHeight: 34

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: Theme.surface0
        border.width: 1
        border.color: root.editing ? Theme.borderFocus : Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            Label {
                visible: !root.editable
                text: (root.options && root.options.length > root.currentIndex && root.currentIndex >= 0)
                    ? root.options[root.currentIndex]
                    : ""
                color: Theme.text
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            CustomTextField {
                id: editField
                visible: root.editable
                Layout.fillWidth: true
                showSearchIcon: false
                borderColor: Theme.transparent
                focusBorderColor: Theme.transparent
                hoverEnabled: false
                horizontalAlignment: Text.AlignLeft
                text: root.editText
                onTextEdited: root.textEdited(text)
                onActiveFocusChanged: {
                    if (activeFocus)
                        root.openPopup()
                }
                onAccepted: {
                    root.editText = text
                    root.activated(text)
                    root.closePopup()
                }
            }

            Label {
                id: arrowLabel
                text: controlPopup.visible ? "▲" : "▼"
                color: Theme.subtext
            }
        }

        MouseArea {
            visible: !root.editable
            id: controlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (controlPopup.visible)
                    root.closePopup()
                else
                    root.openPopup()
            }
        }

        MouseArea {
            visible: root.editable
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: arrowLabel.width + 16
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (controlPopup.visible)
                    root.closePopup()
                else
                    root.openPopup()
            }
        }
    }

    Popup {
        id: controlPopup
        y: {
            const win = root.Window.window
            if (!win)
                return root.height + 4
            const pt = root.mapToItem(null, 0, 0)
            const popupH = height
            if (pt.y + root.height + popupH + 8 > win.height)
                return -popupH - 4
            return root.height + 4
        }
        width: root.width
        height: Math.min((root.options ? root.options.length : 0) * 32 + 8, 220)
        padding: 4
        modal: false
        z: 100
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.surface0
            border.color: Theme.border
            radius: 7
        }

        contentItem: ListView {
            id: optionsView
            clip: true
            model: root.options
            property var owner: root

            delegate: Rectangle {
                width: optionsView.width
                height: 32
                radius: 5
                color: optionMouse.containsMouse ? Theme.surface3 : Theme.transparent

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    text: modelData
                    color: Theme.text
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: optionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        const selectedValue = modelData
                        const control = optionsView.owner
                        control.currentIndex = control.options.indexOf(selectedValue)
                        control.editText = modelData
                        control.activated(modelData)
                        control.closePopup()
                    }
                }
            }

        }
    }

    function closePopup() {
        controlPopup.close()
    }

    function openPopup() {
        controlPopup.open()
    }
}
