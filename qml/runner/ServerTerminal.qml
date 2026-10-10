import "../components"
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

FocusScope {
    id: root

    property var runner: null
    property color borderColor: Theme.border
    property int searchIndex: -1
    property var searchMatches: []
    property string renderedHtml: ""
    property bool updatingSearch: false

    function updateSearch() {
        var html = root.runner ? root.runner.consoleHtml : "error: runner is null";
        var source = root.runner ? root.runner.consoleText : "";
        var query = searchBar.query;
        var normalizedSource = source.toLocaleLowerCase();
        var normalizedQuery = query.toLocaleLowerCase();
        var matches = [];

        if (normalizedQuery.length > 0) {
            var offset = 0;
            while ((offset = normalizedSource.indexOf(normalizedQuery, offset)) >= 0) {
                matches.push(offset);
                offset += normalizedQuery.length;
            }
        }

        root.searchMatches = matches;
        root.searchIndex = matches.length > 0 ? matches[0] : -1;
        if (query.length > 0 && matches.length > 0)
            html = root.highlightMatches(html, matches, query.length);

        root.updatingSearch = true;
        root.renderedHtml = html;
        root.updatingSearch = false;
    }

    function highlightMatches(html, matches, matchLength) {
        var result = "";
        var plainIndex = 0;
        var matchNumber = 0;
        var index = 0;

        while (index < html.length) {
            if (html[index] === "<") {
                var tagEnd = html.indexOf(">", index);
                if (tagEnd < 0) {
                    result += html.slice(index);
                    break;
                }
                var tag = html.slice(index, tagEnd + 1);
                result += tag;
                if (tag.toLowerCase().indexOf("<br") === 0)
                    plainIndex++;
                index = tagEnd + 1;
                continue;
            }

            var unitEnd = html[index] === "&" ? html.indexOf(";", index) + 1 : index + 1;
            if (unitEnd <= index)
                unitEnd = index + 1;

            if (matchNumber < matches.length && plainIndex === matches[matchNumber])
                result += "<span style=\"background-color: " + Theme.selection + ";\">";

            result += html.slice(index, unitEnd);
            plainIndex++;
            index = unitEnd;

            if (matchNumber < matches.length && plainIndex === matches[matchNumber] + matchLength) {
                result += "</span>";
                matchNumber++;
            }
        }

        return result;
    }

    function openSearch() {
        if (searchBar.shown) {
            closeSearch();
            return;
        }

        searchBar.showSearch();
    }

    function closeSearch() {
        searchBar.hideSearch();
        outputText.deselect();
        root.updateSearch();
        commandInput.forceActiveFocus();
    }

    function scrollToMatch(position) {
        var matchRect = outputText.positionToRectangle(position);
        var topInset = 12;
        var bottomInset = outputScroll.height - 12;
        var maximumContentY = Math.max(0, outputScroll.contentHeight - outputScroll.height);
        var targetContentY = outputScroll.contentY;

        if (matchRect.y < targetContentY + topInset)
            targetContentY = matchRect.y - topInset;
        else if (matchRect.y + matchRect.height > targetContentY + bottomInset)
            targetContentY = matchRect.y + matchRect.height - bottomInset;

        outputScroll.contentY = Math.max(0, Math.min(maximumContentY, targetContentY));
    }

    function findMatch(backward) {
        if (root.searchMatches.length === 0) {
            root.searchIndex = -1;
            outputText.deselect();
            return;
        }

        var current = root.searchMatches.indexOf(root.searchIndex);
        var next = (current + (backward ? -1 : 1) + root.searchMatches.length) % root.searchMatches.length;
        root.searchIndex = root.searchMatches[next];
        outputText.select(root.searchIndex, root.searchIndex + searchBar.query.length);
        var selectedPosition = root.searchIndex;
        Qt.callLater(function() {
            root.scrollToMatch(selectedPosition);
        });
    }

    function scrollToBottom() {
        outputScroll.contentY = Math.max(0, outputScroll.contentHeight - outputScroll.height);
    }

    Shortcut {
        sequence: "Ctrl+F"
        context: Qt.WindowShortcut
        onActivated: root.openSearch()
    }

    Component.onCompleted: {
        root.updateSearch();
        commandInput.forceActiveFocus();
    }

    onRunnerChanged: root.updateSearch()

    Connections {
        target: root.runner
        function onConsoleHtmlChanged() {
            root.updateSearch();
        }
        function onConsoleTextChanged() {
            root.updateSearch();
        }
    }

    Rectangle {
        id: terminalFrame

        anchors.fill: parent
        color: Theme.surface0
        border.color: root.borderColor
        radius: Theme.radius

        Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Flickable {
            id: outputScroll

            anchors.fill: parent
            anchors.margins: 12
            anchors.bottomMargin: commandBar.height + 24
            contentWidth: width
            contentHeight: outputText.implicitHeight
            clip: true
            onContentHeightChanged: Qt.callLater(root.scrollToBottom)

            TextEdit {
                id: outputText

                width: outputScroll.width
                readOnly: true
                text: root.renderedHtml
                textFormat: TextEdit.RichText
                color: Theme.text
                font.family: Theme.monoFamily
                font.pixelSize: 13
                selectByMouse: true
                wrapMode: TextEdit.Wrap
                onTextChanged: {
                    if (!root.updatingSearch)
                        Qt.callLater(root.scrollToBottom);
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

        }

        SearchBar {
            id: searchBar

            anchors.bottom: commandBar.top
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.bottomMargin: 8
            width: 360
            height: 40
            z: 2

            currentMatch: root.searchMatches.indexOf(root.searchIndex)
            matchCount: root.searchMatches.length
            onQueryChanged: {
                root.updateSearch();
                root.searchIndex = -1;
                if (root.searchMatches.length > 0)
                    Qt.callLater(function() {
                        root.findMatch(false);
                    });
            }
            onCloseClicked: root.closeSearch()
            onPreviousClicked: root.findMatch(true)
            onNextClicked: root.findMatch(false)
            onSearchSubmitted: function(backward) {
                root.findMatch(backward);
            }

        }

        RowLayout {
            id: commandBar

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            spacing: 8

            TextField {
                id: commandInput

                Layout.fillWidth: true
                placeholderText: root.runner ? "Enter a server command..." : "error: runner is null"
                enabled: root.runner !== null
                color: Theme.text
                placeholderTextColor: Theme.subtext
                selectionColor: Theme.selection
                selectedTextColor: Theme.textBright
                leftPadding: 12
                rightPadding: 12
                onAccepted: {
                    if (root.runner)
                        root.runner.sendCommand(text);

                    text = "";
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_C && (event.modifiers & Qt.ControlModifier)) {
                        if (root.runner)
                            root.runner.interrupt();

                        event.accepted = true;
                    }
                }

                background: Rectangle {
                    radius: Theme.radius
                    color: Theme.surface
                    border.width: commandInput.activeFocus ? 1 : 0
                    border.color: Theme.borderFocus

                    Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                }

            }

            ThemedButton {
                text: "Stop"
                enabled: root.runner !== null && root.runner.running
                buttonColor: Theme.failureMuted
                buttonHoverColor: Theme.failure
                buttonPressedColor: Theme.failureMuted
                onClicked: {
                    if (root.runner) {
                        root.runner.stop();
                    }
                }
            }

        }

    }

}
