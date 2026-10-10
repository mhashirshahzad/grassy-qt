import "../components" 1.0
import "../theme" 1.0
import QtQuick 2.15
import QtQuick.Effects

Item {
    id: root

    property int currentIndex: 0
    property var tabs: []
    readonly property string currentTab: tabs.length > currentIndex && currentIndex >= 0 ? tabs[currentIndex] : ""
    property color barColor: Theme.surface0
    property color selectedColor: Theme.accentMuted
    property color hoverColor: Theme.surface2
    property color textColor: Theme.text
    property color selectedTextColor: Theme.textBright
    property bool hovered: tabHover.hovered
    property bool reorderable: true

    signal tabMoved(int fromIndex, int toIndex)
    signal tabsReordered(var newTabs)

    // Drag-and-drop state
    property int draggingIndex: -1
    property int dropTargetIndex: -1
    property real draggedWidth: 0

    // Extra easing constant we reuse everywhere
    readonly property int springDur: 260
    readonly property int easeDur: 140

    function updateDropTarget(currentCenterX) {
        var count = tabs.length;
        var bestIndex = draggingIndex;
        var minDist = 999999;
        for (var i = 0; i < count; ++i) {
            var item = tabRow.itemAt(i);
            if (item) {
                var itemCenter = item.x + item.width / 2;
                var dist = Math.abs(currentCenterX - itemCenter);
                if (dist < minDist) {
                    minDist = dist;
                    bestIndex = i;
                }
            }
        }
        dropTargetIndex = bestIndex;
    }

    implicitHeight: 32
    implicitWidth: tabRow.implicitWidth

    HoverHandler { id: tabHover }

    // ---------------------------------------------------------------
    // Resting underline — animates its width when popup opens
    // so it visually "becomes" the popup bar
    // ---------------------------------------------------------------
    Rectangle {
        id: underline
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Theme.radiusSmall
        height: 3
        width: root.hovered ? root.width : 200
        color: Theme.border
        opacity: root.hovered ? 0 : 1

        Behavior on width   { NumberAnimation { duration: root.springDur; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }
        Behavior on opacity { NumberAnimation { duration: root.easeDur } }
    }

    // ---------------------------------------------------------------
    // Popup container
    // ---------------------------------------------------------------
    Item {
        id: popup
        anchors.fill: parent
        transformOrigin: Item.Top
        opacity: root.hovered ? 1 : 0
        scale: root.hovered ? 1.0 : 0.85
        y: root.hovered ? 0 : -10

        Behavior on opacity { NumberAnimation { duration: root.easeDur } }
        Behavior on scale   { NumberAnimation { duration: root.springDur; easing.type: Easing.OutBack; easing.overshoot: 1.7 } }
        Behavior on y       { NumberAnimation { duration: root.springDur; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

        // Background
        Rectangle {
            id: bg
            anchors.fill: parent
            color: root.barColor
            radius: Theme.radius
            border.color: Theme.border
            border.width: 1
            visible: false // rendered by MultiEffect
        }

        // Shadow that "grows in" with the popup
        MultiEffect {
            source: bg
            anchors.fill: bg
            shadowEnabled: true
            shadowColor: "#90000000"
            shadowVerticalOffset: root.hovered ? 6 : 0
            shadowHorizontalOffset: 0
            shadowBlur: root.hovered ? 0.7 : 0.0
            shadowScale: 1.0
            shadowOpacity: 1.0
            autoPaddingEnabled: true

            Behavior on shadowBlur            { NumberAnimation { duration: root.springDur; easing.type: Easing.OutCubic } }
            Behavior on shadowVerticalOffset  { NumberAnimation { duration: root.springDur; easing.type: Easing.OutCubic } }
        }

        // Crisp border on top of the blurred shadow
        Rectangle {
            anchors.fill: bg
            color: "transparent"
            radius: Theme.radius
            border.color: Theme.border
            border.width: 1
        }

        // -----------------------------------------------------------
        // Sliding "pill" that highlights the selected tab.
        // We keep one pill and animate its x / width — buttery glide.
        // -----------------------------------------------------------
        Rectangle {
            id: selectionPill
            visible: root.hovered
            color: root.selectedColor
            radius: Theme.radiusSmall
            y: 2
            height: tabRow.height

            // Find the delegate at currentIndex to match its x/width
            readonly property Item target: tabRow.itemAt(root.currentIndex)
            x: target ? target.x + target.effectiveDisplacement : 0
            width: target ? target.width : 0

            Behavior on x     { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        }

        // -----------------------------------------------------------
        // Hover pill — follows mouse smoothly, sits behind text
        // -----------------------------------------------------------
        Rectangle {
            id: hoverPill
            visible: root.hovered && hoverTracker.hoveredTab >= 0
                     && hoverTracker.hoveredTab !== root.currentIndex
                     && root.draggingIndex < 0
            color: root.hoverColor
            radius: Theme.radiusSmall
            y: 2
            height: tabRow.height
            opacity: visible ? 1 : 0

            readonly property Item target: tabRow.itemAt(hoverTracker.hoveredTab)
            x: target ? target.x + target.effectiveDisplacement : 0
            width: target ? target.width : 0

            Behavior on x     { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: root.easeDur } }
        }

        // Tracks which tab the cursor is over (for the hover pill)
        QtObject {
            id: hoverTracker
            property int hoveredTab: -1
        }

        // -----------------------------------------------------------
        // Row of tabs
        // -----------------------------------------------------------
        Row {
            id: tabRow
            anchors.fill: parent
            anchors.margins: 2
            spacing: 2
            clip: false

            function itemAt(idx) {
                return tabRepeater.itemAt(idx)
            }

            Repeater {
                id: tabRepeater
                model: root.tabs
                delegate: Item {
                    id: tab
                    required property int index
                    required property string modelData

                    width: Math.max(76, tabLabel.implicitWidth + 24)
                    height: tabRow.height

                    readonly property bool isDragging: root.draggingIndex === tab.index
                    property real dragDeltaX: 0

                    // Displacement when neighbor tab is dragged over this tab
                    readonly property real displacement: {
                        if (root.draggingIndex < 0 || isDragging)
                            return 0;
                        if (root.dropTargetIndex > root.draggingIndex && tab.index > root.draggingIndex && tab.index <= root.dropTargetIndex)
                            return -(root.draggedWidth + tabRow.spacing);
                        if (root.dropTargetIndex < root.draggingIndex && tab.index < root.draggingIndex && tab.index >= root.dropTargetIndex)
                            return +(root.draggedWidth + tabRow.spacing);
                        return 0;
                    }

                    readonly property real effectiveDisplacement: isDragging ? dragDeltaX : displacement

                    z: isDragging ? 100 : (root.currentIndex === tab.index ? 3 : 1)

                    transform: Translate {
                        x: tab.effectiveDisplacement
                        Behavior on x {
                            enabled: !tab.isDragging
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.4
                            }
                        }
                    }

                    // Stagger via a per-tab timer driven by hovered
                    Timer {
                        id: stagger
                        interval: 25 + tab.index * 30
                        repeat: false
                        onTriggered: tab.showNow = true
                    }
                    property bool showNow: false

                    Connections {
                        target: root
                        function onHoveredChanged() {
                            if (root.hovered) {
                                stagger.restart()
                            } else {
                                stagger.stop()
                                tab.showNow = false
                            }
                        }
                    }

                    opacity: root.hovered && tab.showNow ? 1 : 0
                    scale: root.hovered && tab.showNow ? 1 : 0.6
                    y: root.hovered && tab.showNow ? 0 : 8

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.easeDur
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: root.springDur
                            easing.type: Easing.OutBack
                            easing.overshoot: 2.0
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: root.springDur
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.5
                        }
                    }

                    // ----------------------------------------
                    // Press "squish" & drag elevation
                    // ----------------------------------------
                    Item {
                        id: squish
                        anchors.fill: parent
                        scale: tab.isDragging ? 1.10 : (tabMouse.pressed ? 0.92 : 1.0)
                        rotation: tab.isDragging ? (tab.dragDeltaX > 0 ? 2 : -2) : 0

                        Behavior on scale {
                            NumberAnimation { duration: 110; easing.type: Easing.OutBack; easing.overshoot: 1.8 }
                        }
                        Behavior on rotation {
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }

                        Text {
                            id: tabLabel
                            anchors.centerIn: parent
                            text: tab.modelData
                            color: root.currentIndex === tab.index
                                   ? root.selectedTextColor
                                   : root.textColor
                            font.bold: root.currentIndex === tab.index
                            font.pixelSize: 12

                            Behavior on color { ColorAnimation { duration: 140 } }

                            // Subtle pop when the selected index changes
                            scale: root.currentIndex === tab.index ? 1.08 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2.5 }
                            }
                        }
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: root.reorderable ? (tab.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor) : Qt.PointingHandCursor

                        property real pressStartX: 0
                        property bool dragCandidate: false

                        onEntered: {
                            if (root.draggingIndex < 0)
                                hoverTracker.hoveredTab = tab.index
                        }
                        onExited: {
                            if (hoverTracker.hoveredTab === tab.index && root.draggingIndex < 0)
                                hoverTracker.hoveredTab = -1
                        }

                        onPressed: function(mouse) {
                            pressStartX = mouse.x;
                            dragCandidate = true;
                            tab.dragDeltaX = 0;
                        }

                        onPositionChanged: function(mouse) {
                            if (dragCandidate && root.reorderable) {
                                var delta = mouse.x - pressStartX;
                                if (!tab.isDragging && Math.abs(delta) > 6) {
                                    root.draggingIndex = tab.index;
                                    root.draggedWidth = tab.width;
                                    root.dropTargetIndex = tab.index;
                                }
                                if (tab.isDragging) {
                                    tab.dragDeltaX += delta;
                                    var currentCenter = tab.x + tab.width / 2 + tab.dragDeltaX;
                                    root.updateDropTarget(currentCenter);
                                }
                            }
                        }

                        onReleased: {
                            if (tab.isDragging) {
                                var fromIdx = root.draggingIndex;
                                var toIdx = root.dropTargetIndex;
                                tab.dragDeltaX = 0;
                                root.draggingIndex = -1;
                                root.dropTargetIndex = -1;
                                dragCandidate = false;

                                if (fromIdx >= 0 && toIdx >= 0 && fromIdx !== toIdx) {
                                    var currentName = root.tabs[root.currentIndex];
                                    var newTabs = root.tabs.slice();
                                    var moved = newTabs.splice(fromIdx, 1)[0];
                                    newTabs.splice(toIdx, 0, moved);
                                    root.tabs = newTabs;
                                    root.currentIndex = newTabs.indexOf(currentName);
                                    root.tabMoved(fromIdx, toIdx);
                                    root.tabsReordered(newTabs);
                                }
                                wobbleAnim.restart();
                            } else {
                                dragCandidate = false;
                                tab.dragDeltaX = 0;
                                if (root.currentIndex === tab.index) {
                                    wobbleAnim.restart();
                                }
                                root.currentIndex = tab.index;
                            }
                        }

                        onCanceled: {
                            tab.dragDeltaX = 0;
                            root.draggingIndex = -1;
                            root.dropTargetIndex = -1;
                            dragCandidate = false;
                        }
                    }

                    // Reusable wobble on click / drop landing
                    JoyWobble {
                        id: wobbleAnim
                        targetItem: tab
                    }
                }
            }
        }
    }
}
