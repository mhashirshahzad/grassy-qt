import QtQuick 2.15
pragma Singleton

QtObject {
    readonly property var palette: typeof utils !== "undefined" && utils !== null ? utils.themePalette : ({
    })
    readonly property string selectedTheme: typeof utils !== "undefined" && utils !== null ? utils.selectedTheme : ""
    readonly property var themeNames: typeof utils !== "undefined" && utils !== null ? utils.themeNames : []
    readonly property color background: palette.background || "#1a1b26"
    readonly property color surface0: palette.surface0 || background
    readonly property color surface1: palette.surface1 || background
    readonly property color surface2: palette.surface2 || surface1
    readonly property color surface3: palette.surface3 || surface2
    readonly property color surface: surface1
    readonly property color overlay0: palette.overlay0 || surface3
    readonly property color overlay1: palette.overlay1 || overlay0
    readonly property color overlay2: palette.overlay2 || overlay1
    readonly property color overlay3: palette.overlay3 || overlay2
    readonly property color overlay: overlay0
    readonly property color text: palette.text || "#c0caf5"
    readonly property color textBright: palette.textBright || text
    readonly property color subtext0: palette.subtext0 || text
    readonly property color subtext1: palette.subtext1 || subtext0
    readonly property color subtext2: palette.subtext2 || subtext1
    readonly property color subtext: subtext0
    readonly property color accent: palette.accent || "#7aa2f7"
    readonly property color accentHover: palette.accentHover || accent
    readonly property color accentPressed: palette.accentPressed || accent
    readonly property color accentMuted: palette.accentMuted || surface3
    readonly property color success: palette.success || accent
    readonly property color successHover: palette.successHover || success
    readonly property color successMuted: palette.successMuted || accentMuted
    readonly property color warning: palette.warning || accent
    readonly property color warningHover: palette.warningHover || warning
    readonly property color warningMuted: palette.warningMuted || accentMuted
    readonly property color failure: palette.failure || accent
    readonly property color failureHover: palette.failureHover || failure
    readonly property color failureMuted: palette.failureMuted || accentMuted
    readonly property color info: palette.info || accent
    readonly property color infoHover: palette.infoHover || info
    readonly property color infoMuted: palette.infoMuted || accentMuted
    readonly property color border: palette.border || surface3
    readonly property color borderHover: palette.borderHover || border
    readonly property color borderFocus: accent
    readonly property color selection: palette.selection || accent
    readonly property color selectionHover: palette.selectionHover || selection
    readonly property color disabled: palette.disabled || surface3
    readonly property color disabledText: palette.disabledText || subtext2
    readonly property color shadow: palette.shadow || surface0
    readonly property color scrim: palette.scrim || "#73000000"
    readonly property color transparent: "#00000000"

    // Colors for text ON colored surfaces
    readonly property color onAccent: palette.onAccent || background
    readonly property color onSuccess: palette.onSuccess || background
    readonly property color onWarning: palette.onWarning || background
    readonly property color onFailure: palette.onFailure || background
    readonly property color onInfo: palette.onInfo || textBright

    // Semantic text colors for labels / messages
    readonly property color failureText: palette.failureText || failure
    readonly property color successText: palette.successText || success
    readonly property color warningText: palette.warningText || warning
    readonly property color infoText: palette.infoText || info
    readonly property color accentText: palette.accentText || accent

    // Border radiuses defined by the theme
    readonly property int radius: palette.radius !== undefined ? Number(palette.radius) : 8
    readonly property int radiusSmall: palette.radiusSmall !== undefined ? Number(palette.radiusSmall) : 4
    readonly property int radiusLarge: palette.radiusLarge !== undefined ? Number(palette.radiusLarge) : 12
    readonly property int radiusPill: palette.radiusPill !== undefined ? Number(palette.radiusPill) : 20

    readonly property FontLoader
    ubuntu: FontLoader {
        source: "qrc:/fonts/Ubuntu/Ubuntu-Regular.ttf"
    }

    readonly property FontLoader
    monoFont: FontLoader {
        source: "qrc:/fonts/Ubuntu/UbuntuMono-Regular.ttf"
    }

    readonly property string monoFamily: monoFont.name
    readonly property string fontFamily: ubuntu.name

    signal themeTransitionRequested(color oldBackground)

    function setTheme(name) {
        if (typeof utils !== "undefined" && utils !== null && name !== utils.selectedTheme) {
            themeTransitionRequested(background);
            utils.setTheme(name);
        }
    }
}
