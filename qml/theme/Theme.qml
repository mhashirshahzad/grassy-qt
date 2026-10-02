pragma Singleton
import QtQuick 2.15
import Qt.labs.settings 1.0

QtObject {
    id: root

    readonly property SystemPalette systemPalette: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    readonly property var themes: ({
        "Tokyo Night": {
            background: "#1a1b26",
            surface0: "#16161e", surface1: "#24283b", surface2: "#292e42", surface3: "#3b4261",
            overlay0: "#565f89", overlay1: "#737aa2", overlay2: "#7982a9", overlay3: "#a9b1d6",
            text: "#c0caf5", textBright: "#e6eaff",
            subtext0: "#a9b1d6", subtext1: "#7982a9", subtext2: "#565f89",
            accent: "#7aa2f7", accentHover: "#89b4fa", accentPressed: "#6183bb", accentMuted: "#3b4261",
            success: "#9ece6a", successHover: "#b9f27c", successMuted: "#3b4261",
            warning: "#e0af68", warningHover: "#ffcb6b", warningMuted: "#3b4261",
            failure: "#f7768e", failureHover: "#ff899d", failureMuted: "#3b4261",
            info: "#7dcfff", infoHover: "#a4e8ff", infoMuted: "#3b4261",
            border: "#3b4261", borderHover: "#565f89", selection: "#33467c", selectionHover: "#3b4261",
            disabled: "#3b4261", disabledText: "#565f89", shadow: "#16161e", scrim: "#16161ecc"
        },
        "Nord": {
            background: "#2e3440",
            surface0: "#242933", surface1: "#3b4252", surface2: "#434c5e", surface3: "#4c566a",
            overlay0: "#616e88", overlay1: "#81a1c1", overlay2: "#8fbcbb", overlay3: "#d8dee9",
            text: "#d8dee9", textBright: "#eceff4",
            subtext0: "#bfc7d5", subtext1: "#aeb8c8", subtext2: "#616e88",
            accent: "#88c0d0", accentHover: "#8fbcbb", accentPressed: "#5e81ac", accentMuted: "#4c566a",
            success: "#a3be8c", successHover: "#b7d69b", successMuted: "#4c566a",
            warning: "#ebcb8b", warningHover: "#f0d79b", warningMuted: "#4c566a",
            failure: "#bf616a", failureHover: "#d08770", failureMuted: "#4c566a",
            info: "#81a1c1", infoHover: "#8fbcbb", infoMuted: "#4c566a",
            border: "#4c566a", borderHover: "#616e88", selection: "#5e81ac", selectionHover: "#81a1c1",
            disabled: "#4c566a", disabledText: "#616e88", shadow: "#242933", scrim: "#242933cc"
        },
        "System": systemColors
    })
    readonly property var themeNames: Object.keys(themes)

    readonly property var systemColors: ({
        background: systemPalette.window,
        surface0: systemPalette.base,
        surface1: systemPalette.window,
        surface2: systemPalette.alternateBase,
        surface3: systemPalette.mid,
        overlay0: systemPalette.mid,
        overlay1: systemPalette.button,
        overlay2: systemPalette.light,
        overlay3: systemPalette.highlightedText,
        text: systemPalette.text,
        textBright: systemPalette.windowText,
        subtext0: systemPalette.mid,
        subtext1: systemPalette.mid,
        subtext2: systemPalette.dark,
        accent: systemPalette.highlight,
        accentHover: systemPalette.highlight,
        accentPressed: systemPalette.dark,
        accentMuted: systemPalette.mid,
        success: systemPalette.highlight,
        successHover: systemPalette.highlight,
        successMuted: systemPalette.mid,
        warning: systemPalette.highlight,
        warningHover: systemPalette.highlight,
        warningMuted: systemPalette.mid,
        failure: systemPalette.highlight,
        failureHover: systemPalette.highlight,
        failureMuted: systemPalette.mid,
        info: systemPalette.highlight,
        infoHover: systemPalette.highlight,
        infoMuted: systemPalette.mid,
        border: systemPalette.mid,
        borderHover: systemPalette.button,
        selection: systemPalette.highlight,
        selectionHover: systemPalette.highlight,
        disabled: systemPalette.mid,
        disabledText: systemPalette.mid,
        shadow: systemPalette.dark,
        scrim: Qt.rgba(0, 0, 0, 0.45)
    })

    readonly property Settings settings: Settings {
        id: settings
        property string selectedTheme: "Tokyo Night"
    }

    readonly property string selectedTheme: themes[settings.selectedTheme]
        ? settings.selectedTheme : themeNames[0]
    readonly property var palette: themes[selectedTheme]

    function setTheme(name) {
        if (themes[name])
            settings.selectedTheme = name
    }

    readonly property color background: palette.background
    readonly property color surface0: palette.surface0
    readonly property color surface1: palette.surface1
    readonly property color surface2: palette.surface2
    readonly property color surface3: palette.surface3
    readonly property color surface: palette.surface1
    readonly property color overlay0: palette.overlay0
    readonly property color overlay1: palette.overlay1
    readonly property color overlay2: palette.overlay2
    readonly property color overlay3: palette.overlay3
    readonly property color overlay: palette.overlay0
    readonly property color text: palette.text
    readonly property color textBright: palette.textBright
    readonly property color subtext0: palette.subtext0
    readonly property color subtext1: palette.subtext1
    readonly property color subtext2: palette.subtext2
    readonly property color subtext: palette.subtext0
    readonly property color accent: palette.accent
    readonly property color accentHover: palette.accentHover
    readonly property color accentPressed: palette.accentPressed
    readonly property color accentMuted: palette.accentMuted
    readonly property color success: palette.success
    readonly property color successHover: palette.successHover
    readonly property color successMuted: palette.successMuted
    readonly property color warning: palette.warning
    readonly property color warningHover: palette.warningHover
    readonly property color warningMuted: palette.warningMuted
    readonly property color failure: palette.failure
    readonly property color failureHover: palette.failureHover
    readonly property color failureMuted: palette.failureMuted
    readonly property color info: palette.info
    readonly property color infoHover: palette.infoHover
    readonly property color infoMuted: palette.infoMuted
    readonly property color border: palette.border
    readonly property color borderHover: palette.borderHover
    readonly property color borderFocus: palette.accent
    readonly property color selection: palette.selection
    readonly property color selectionHover: palette.selectionHover
    readonly property color disabled: palette.disabled
    readonly property color disabledText: palette.disabledText
    readonly property color shadow: palette.shadow
    readonly property color scrim: palette.scrim
    readonly property color transparent: "#00000000"

    readonly property FontLoader ubuntu: FontLoader {
        source: "qrc:/fonts/Ubuntu/Ubuntu-Regular.ttf"
    }
    readonly property FontLoader monoFont: FontLoader {
        source: "qrc:/fonts/Ubuntu/UbuntuMono-Regular.ttf"
    }
    readonly property string monoFamily: monoFont.name
    readonly property string fontFamily: ubuntu.name
}
