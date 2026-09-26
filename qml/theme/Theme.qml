pragma Singleton
import QtQuick 2.15

QtObject {
    // ─────────────────────────────────────────────
    // Base
    // ─────────────────────────────────────────────

    readonly property color background: "#1a1b26"

    // ─────────────────────────────────────────────
    // Surfaces
    // ─────────────────────────────────────────────

    readonly property color surface0: "#16161e"
    readonly property color surface1: "#24283b"
    readonly property color surface2: "#292e42"
    readonly property color surface3: "#3b4261"

    // Main UI surface
    readonly property color surface: surface1

    // ─────────────────────────────────────────────
    // Overlays
    // ─────────────────────────────────────────────

    readonly property color overlay0: "#565f89"
    readonly property color overlay1: "#737aa2"
    readonly property color overlay2: "#7982a9"
    readonly property color overlay3: "#a9b1d6"

    readonly property color overlay: overlay0

    // ─────────────────────────────────────────────
    // Text
    // ─────────────────────────────────────────────

    readonly property color text: "#c0caf5"
    readonly property color textBright: "#e6eaff"

    readonly property color subtext0: "#a9b1d6"
    readonly property color subtext1: "#7982a9"
    readonly property color subtext2: "#565f89"

    readonly property color subtext: subtext0

    // ─────────────────────────────────────────────
    // Accent
    // ─────────────────────────────────────────────

    readonly property color accent: "#7aa2f7"
    readonly property color accentHover: "#89b4fa"
    readonly property color accentPressed: "#6183bb"
    readonly property color accentMuted: "#3b4261"

    // ─────────────────────────────────────────────
    // Semantic
    // ─────────────────────────────────────────────

    readonly property color success: "#9ece6a"
    readonly property color successHover: "#b9f27c"
    readonly property color successMuted: "#3b4261"

    readonly property color warning: "#e0af68"
    readonly property color warningHover: "#ffcb6b"
    readonly property color warningMuted: "#3b4261"

    readonly property color failure: "#f7768e"
    readonly property color failureHover: "#ff899d"
    readonly property color failureMuted: "#3b4261"

    readonly property color info: "#7dcfff"
    readonly property color infoHover: "#a4e8ff"
    readonly property color infoMuted: "#3b4261"

    // ─────────────────────────────────────────────
    // UI States
    // ─────────────────────────────────────────────

    readonly property color border: "#3b4261"
    readonly property color borderHover: "#565f89"
    readonly property color borderFocus: accent

    readonly property color selection: "#33467c"
    readonly property color selectionHover: "#3b4261"

    readonly property color disabled: "#3b4261"
    readonly property color disabledText: "#565f89"

    // ─────────────────────────────────────────────
    // Special
    // ─────────────────────────────────────────────

    readonly property color shadow: "#16161e"
    readonly property color scrim: "#16161ecc"

    readonly property color transparent: "#00000000"


    readonly property FontLoader ubuntu : FontLoader {
        source: "qrc:/fonts/Ubuntu/Ubuntu-Regular.ttf"
    }
    readonly property FontLoader monoFont: FontLoader {
        source: "qrc:/fonts/Ubuntu/UbuntuMono-Regular.ttf"
    }

    readonly property string monoFamily: monoFont.name
    readonly property string fontFamily: ubuntu.name
}
