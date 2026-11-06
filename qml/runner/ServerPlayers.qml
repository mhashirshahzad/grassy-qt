import "../components"
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var runner: null
    property string searchText: ""
    readonly property var visiblePlayers: {
        const players = runner && runner.players ? runner.players : [];
        const query = searchText.trim().toLocaleLowerCase();
        return players.filter(function(player) {
            return query.length === 0 || player.name.toLocaleLowerCase().indexOf(query) >= 0;
        });
    }

    color: Theme.surface0
    border.color: Theme.border
    radius: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "Players"
                color: Theme.text
                font.pixelSize: 18
                Layout.fillWidth: true
            }

            Label {
                text: {
                    const players = root.runner && root.runner.players ? root.runner.players : [];
                    const online = players.filter(function(player) { return player.online; }).length;
                    return online + " online / " + players.length + " known";
                }
                color: Theme.subtext
                font.pixelSize: 12
            }
        }

        CustomTextField {
            Layout.fillWidth: true
            placeholderText: "Search players..."
            showSearchIcon: true
            onTextChanged: root.searchText = text
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: root.visiblePlayers

            delegate: PlayerCard {
                required property var modelData
                width: ListView.view.width
                playerName: modelData.name
                playerOnline: modelData.online
            }

            Label {
                anchors.centerIn: parent
                visible: root.visiblePlayers.length === 0
                text: root.searchText.trim().length > 0
                      ? "No matching players"
                      : "Players will appear here as they join"
                color: Theme.subtext
            }
        }
    }
}
