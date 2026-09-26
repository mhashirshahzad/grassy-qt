pragma Singleton
import QtQuick 2.15

QtObject {
    // ─────────────────────────────────────────────
    // Base
    // ─────────────────────────────────────────────

    readonly property color background: "#0d0b14"

    // ─────────────────────────────────────────────
    // Surfaces
    // ─────────────────────────────────────────────

    readonly property color surface0: "#12101a"
    readonly property color surface1: "#181522"
    readonly property color surface2: "#211d2d"
    readonly property color surface3: "#2a2538"

    // Main UI surface
    readonly property color surface: surface1

    // ─────────────────────────────────────────────
    // Overlays
    // ─────────────────────────────────────────────

    readonly property color overlay0: "#383247"
    readonly property color overlay1: "#443d55"
    readonly property color overlay2: "#514963"
    readonly property color overlay3: "#605772"

    readonly property color overlay: overlay0

    // ─────────────────────────────────────────────
    // Text
    // ─────────────────────────────────────────────

    readonly property color text: "#eeeaf7"
    readonly property color textBright: "#ffffff"

    readonly property color subtext0: "#b8b1c9"
    readonly property color subtext1: "#968da9"
    readonly property color subtext2: "#746b86"

    readonly property color subtext: subtext0

    // ─────────────────────────────────────────────
    // Accent
    // ─────────────────────────────────────────────

    readonly property color accent: "#9d7cff"
    readonly property color accentHover: "#b095ff"
    readonly property color accentPressed: "#805fe0"
    readonly property color accentMuted: "#493b72"

    // ─────────────────────────────────────────────
    // Semantic
    // ─────────────────────────────────────────────

    readonly property color success: "#7ee787"
    readonly property color successHover: "#9af29f"
    readonly property color successMuted: "#294a32"

    readonly property color warning: "#f2c86b"
    readonly property color warningHover: "#f8d98b"
    readonly property color warningMuted: "#4b3d20"

    readonly property color failure: "#ff6b8a"
    readonly property color failureHover: "#ff8fa5"
    readonly property color failureMuted: "#4d2632"

    readonly property color info: "#6cb6ff"
    readonly property color infoHover: "#8bc5ff"
    readonly property color infoMuted: "#263e56"

    // ─────────────────────────────────────────────
    // UI States
    // ─────────────────────────────────────────────

    readonly property color border: "#302a3e"
    readonly property color borderHover: "#514760"
    readonly property color borderFocus: accent

    readonly property color selection: "#352b55"
    readonly property color selectionHover: "#423567"

    readonly property color disabled: "#4b4557"
    readonly property color disabledText: "#625b6e"

    // ─────────────────────────────────────────────
    // Special
    // ─────────────────────────────────────────────

    readonly property color shadow: "#000000"
    readonly property color scrim: "#000000"

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
