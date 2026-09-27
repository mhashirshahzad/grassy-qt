# Grassy Human Interface Guidelines (HIG)

Welcome to the Human Interface Guidelines for **Grassy**, a modern desktop Minecraft server runner and manager built with Qt/QML and C++.

This guide establishes the visual, interaction, and architectural principles for designing and implementing interfaces in Grassy. Whether you are adding a new setting card, creating a dialog, or polishing animations, follow these rules to maintain a cohesive, delightful, and reliable experience.

---

## 1. Design Philosophy

Grassy combines technical utility with a warm, modern desktop experience:

1. **Native & Responsive**: Designed as a first-class desktop utility with keyboard shortcuts, quick focus management, and immediate feedback.
2. **Tokyo Night Aesthetic**: Deep midnight tones paired with soft pastel accents and high-contrast readable typography.
3. **Playful Micro-Interactions**: Subtle, organic animations (like the icon hover wiggle `:3` and gentle scaling) that give the UI personality without hindering speed.
4. **Safety by Default**: Destructive operations (server deletion, stopping live servers) always require explicit confirmation or deliberate intent, preventing accidental data loss.
5. **No Ambiguity in Units**: Units of measure (RAM in GB, network latency, player counts) must always be explicit, validated, and intuitive.

---

## 2. Color System & Surfaces

Grassy uses a strict color token system declared in [`qml/theme/Theme.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/theme/Theme.qml). **Never hardcode hex color literals in component files.** Always reference `Theme.<token>`.

### Surface Elevation & Layering

Surfaces stack from back to front, getting subtly lighter as elevation increases:

| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `Theme.background` | `#1a1b26` | Root window background, base canvas. |
| `Theme.surface0` | `#16161e` | Recessed areas: terminal console viewport, sunken panels. |
| `Theme.surface1` / `Theme.surface` | `#24283b` | Primary UI surface: server cards, title bar, footer bar. |
| `Theme.surface2` | `#292e42` | Nested containers: input field backgrounds, setting rows, secondary tags. |
| `Theme.surface3` | `#3b4261` | Elevated elements: progress bar tracks, active hover backgrounds, IP chips. |

### Typography & Text Hierarchy

| Token | Hex Value | Role & Usage |
| :--- | :--- | :--- |
| `Theme.textBright` | `#e6eaff` | Primary headings, active dialog titles, highlighted metrics. |
| `Theme.text` | `#c0caf5` | Standard body text, card titles, input text, terminal output. |
| `Theme.subtext0` / `Theme.subtext` | `#a9b1d6` | Subtitles, field descriptions, placeholder text, secondary labels. |
| `Theme.subtext1` | `#7982a9` | Muted auxiliary text, timestamps. |
| `Theme.subtext2` | `#565f89` | Inactive status indicators, unselected toggle tracks. |
| `Theme.disabledText`| `#565f89` | Labels and icons on disabled controls. |

### Accent & Semantic Feedback

| Category | Normal Token (`Hex`) | Hover Token (`Hex`) | Pressed / Muted Token (`Hex`) | Meaning / Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Accent** | `Theme.accent` (`#7aa2f7`) | `Theme.accentHover` (`#89b4fa`) | `Theme.accentPressed` (`#6183bb`) | Primary buttons, active switch fills, active focus borders. |
| **Success** | `Theme.success` (`#9ece6a`) | `Theme.successHover` (`#b9f27c`) | `Theme.successMuted` (`#3b4261`) | Running servers, Java detected, positive metrics, copy confirmed. |
| **Warning** | `Theme.warning` (`#e0af68`) | `Theme.warningHover` (`#ffcb6b`) | `Theme.warningMuted` (`#3b4261`) | High RAM/CPU load (>75%), unsaved changes alert, non-critical warnings. |
| **Failure / Destructive** | `Theme.failure` (`#f7768e`) | `Theme.failureHover` (`#ff899d`) | `Theme.failureMuted` (`#3b4261`) | Critical load (>90%), delete actions, stop server button, Java missing. |
| **Info** | `Theme.info` (`#7dcfff`) | `Theme.infoHover` (`#a4e8ff`) | `Theme.infoMuted` (`#3b4261`) | Network notices, informative tooltips. |

### Borders, Overlays & Scrims

- **Borders**: Default border is `Theme.border` (`#3b4261`), hovering uses `Theme.borderHover` (`#565f89`), and active focus uses `Theme.borderFocus` (`Theme.accent`).
- **Dividers**: 1px horizontal or vertical rules using `Theme.overlay` (`#565f89`) or `Theme.border`.
- **Scrim / Backdrop**: Modals dim the background using `Theme.scrim` (`#16161ecc`).

---

## 3. Typography & Sizing

Grassy ships with two bundled font families loaded dynamically in [`qml/theme/Theme.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/theme/Theme.qml):
- **UI Font**: `Theme.fontFamily` (`Ubuntu-Regular`, fallback `sans-serif`)
- **Monospace Font**: `Theme.monoFamily` (`UbuntuMono-Regular`, fallback `monospace`)

### Type Scale

| Scale Role | Pixel Size | Weight | Font Family | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Title / Heading 1** | `24px` | Bold (`700`) | `Theme.fontFamily` | Main popup & window titles. |
| **Heading 2** | `20px` | Bold (`700`) | `Theme.fontFamily` | Section headers within popups, card headings. |
| **Card Title / Heading 3** | `18px` | Bold (`700`) | `Theme.fontFamily` | Server names on cards. |
| **Body / Button** | `14px` | Regular / Bold | `Theme.fontFamily` | Button labels, primary form labels, body text. |
| **Caption / Subtext** | `12px` | Regular (`400`) | `Theme.fontFamily` | Descriptions, search input text, status bar items. |
| **Terminal / Telemetry** | `13px` | Regular (`400`) | `Theme.monoFamily` | Console stream, CPU/RAM stats, IP badges. |

---

## 4. Spacing, Geometry & Radii

All components adhere to a baseline **4px / 8px grid**:

- **Margins & Gutters**:
  - Window content margin: `12px`
  - Popup inner padding: `20px`
  - Card internal padding: `12px`
  - Control spacing in rows/columns: `8px` or `12px`
  - Section vertical spacing: `14px`

- **Corner Radii (`radius`)**:
  - Popups / Dialogs: `12px`
  - Cards (`ServerCard`, `ServerSettingCard`): `8px`
  - Text fields (`CustomTextField`): `8px`
  - Buttons (`ThemedButton`, `ServerChoiceControl`): `7px`
  - Console viewport (`ServerTerminal`): `6px`
  - Progress bars & chips: `3px` to `5px`
  - Pill switches (`ServerToggleControl`): `height / 2` (`15px`)
  - Status dots: `height / 2` (`4px`)

---

## 5. Component Standards

### 5.1 Buttons

#### ThemedButton ([`ThemedButton.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/components/ThemedButton.qml))
- **Primary Action**: Bold label, padded (`10px` vertical, `14px` horizontal).
- **Scale Animation**: Scales to `1.03` on hover with `Easing.OutBack` over `140ms`.
- **Color Transition**: Transitions background over `140ms`.
- **States**:
  - Normal: `buttonColor` (defaults to `Theme.accent`)
  - Hover: `buttonHoverColor` (`Theme.accentHover`)
  - Pressed: `buttonPressedColor` (`Theme.accentPressed`)
  - Disabled: `opacity: 0.5`, text uses `Theme.disabledText`
- **Destructive/Secondary**: Set `buttonColor` to `Theme.failureMuted` or `Theme.surface3` accordingly.

#### IconButton ([`IconButton.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/components/IconButton.qml))
- Used for compact toolbar and card actions (`edit`, `delete`, `settings`, `folder`, `refresh`, `copy`).
- Standard sizes: `24x24px` for toolbars and cards, `16x16px` for inline indicators.
- **Hover Micro-Interaction**:
  - Scales up to `1.25` (`Easing.OutBack`, `100ms`).
  - Playful wiggle rotation sequence (`-8°` -> `+8°` -> `-5°` -> `0°`).
  - Restores to `scale: 1.0` and `rotation: 0°` smoothly with `Easing.OutCubic` over `120ms`.
- **Color Overlay**:
  - Default: `Theme.text`
  - Hover: `Theme.accent` (or `Theme.failure` when `destructive: true`)
  - Disabled: `Theme.disabledText` with `opacity: 0.4`
- **Tooltips**: All icon buttons **must** have an informative `ToolTip` bound to `ToolTip.visible: hovered`.

### 5.2 Form Inputs

#### CustomTextField ([`CustomTextField.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/components/CustomTextField.qml))
- Background: `Theme.surface2`, radius `8px`.
- Border: `1px` `Theme.subtext` when idle; `2px` `Theme.accent` when `activeFocus: true`.
- Built-in search icon (`magnify.svg`) on the left when `showSearchIcon: true`.
- Text selection highlighted in `Theme.accent` with `Theme.background` text color.

#### ServerToggleControl ([`ServerToggleControl.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/components/ServerToggleControl.qml))
- Fixed dimension: `52x30px` pill.
- Knob: `22x22px` circle smoothly animating on `x` position with `Easing.OutCubic` (`140ms`).
- Inactive track: `Theme.surface3` with `Theme.text` knob.
- Active track: `Theme.accent` with `Theme.background` knob.

#### ServerChoiceControl ([`ServerChoiceControl.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/components/ServerChoiceControl.qml))
- Dropdown selector for enumerated values (e.g. gamemode, difficulty).
- Coordinates must be mapped relative to `Overlay.overlay` to prevent clipping inside scroll views.
- Up/Down indicator toggles between `▲` and `▼`.
- Maximum popup height clamped to prevent overflow past window edges.

### 5.3 Popups & Modals

#### CustomPopup ([`CustomPopup.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/popups/CustomPopup.qml))
- Modal backdrop dimmed with `Theme.scrim`.
- Close policy: `CloseOnEscape | Popup.CloseOnPressOutside`.
- Transitions:
  - Enter: Scales from `0.92` to `1.0` (`180ms`, `Easing.OutCubic`) with fade-in (`140ms`).
  - Exit: Scales from `1.0` to `0.96` (`120ms`, `Easing.InCubic`) with fade-out (`100ms`).
- Header: Clear title, concise one-line explanation, top-right close icon button.
- Footer action order:
  - Right-aligned.
  - Secondary/Dismissive action first: **Cancel** (`Theme.surface3`).
  - Primary/Affirmative action second: **Save changes** / **Confirm** (`Theme.accent` or `Theme.failure`).

---

## 6. Terminal & Runner Guidelines

The live server console view in [`qml/terminal/ServerTerminal.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/terminal/ServerTerminal.qml) and [`qml/windows/ServerWindow.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/windows/ServerWindow.qml) must adhere to these rules:

1. **Rich Text ANSI Colors**: Terminal output supports rich text (`consoleHtml`). Standard ANSI escape codes from Minecraft (e.g. `§a`, `§c`, or ANSI sequences) are converted cleanly to HTML hex spans matching the Tokyo Night palette.
2. **Auto-Scroll Behavior**:
   - The view scrolls to bottom automatically as new text arrives via `Qt.callLater(root.scrollToBottom)`.
   - Text selection with the mouse must be enabled (`selectByMouse: true`).
3. **Command Entry**:
   - The command input field receives active focus on load.
   - Pressing `Enter` dispatches the command and immediately clears the input.
   - `Ctrl+C` in the command field triggers a server process interrupt (`ServerRunner::interrupt()`).
4. **Live Telemetry & Resource Gauges**:
   - CPU and RAM bars update every 1 second.
   - Progress bar colors are dynamic:
     - `< 75%`: `Theme.success` (Green)
     - `75% - 89%`: `Theme.warning` (Orange)
     - `≥ 90%`: `Theme.failure` (Red)
   - When the process is stopped or offline, gauges show `--` and use `Theme.disabled`.

---

## 7. Interaction Patterns & UX Rules

### Memory Configuration
- **Memory units must always be presented in GB** (e.g., `2 GB`, `4 GB`).
- Do not make the user type raw Java flags (like `-Xmx4096M` or `4G`) manually without validation.
- Validated values are cleanly formatted when generating `start.sh`.

### Copy to Clipboard Feedback
When copying IP addresses or server properties:
1. The copy button swaps icon from `copy.svg` to `check.svg`.
2. Tooltip updates to `"Copied!"`.
3. An internal timer (`1200ms`) automatically reverts the button state.

### Server Lifecycle & Safety
- Starting a server spawns an independent, focused secondary window [`ServerWindow.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/windows/ServerWindow.qml).
- The main server card visually reflects the live running state with a green pulse dot and dynamic button label ("Running").
- Destructive actions (deleting server folder, renaming active directory) **must be disabled** while the server process is alive.

### Search & Filtering
- Search fields filter items in real-time on keystroke using fuzzy/substring matching.
- Search text fields must include a clear/magnify icon and standard placeholder text.
