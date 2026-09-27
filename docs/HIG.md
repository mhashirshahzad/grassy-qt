# Grassy Human Interface Guidelines

Grassy is a modern desktop application for creating, managing, and running Minecraft servers.

Its interface should feel like a **well-designed desktop utility**, not a developer tool, system settings application, or web dashboard.

Grassy is allowed to be information-dense where the task demands it, particularly in the server runner, while keeping ordinary management screens calm and easy to scan.

---

# 1. Design Philosophy

Grassy follows five principles.

### 1.1 Calm by Default

The main interface should be visually quiet.

Use whitespace, typography, and subtle surface differences to establish hierarchy before relying on borders, shadows, or bright colors.

The user should immediately understand:

* what servers exist
* which server is running
* what they can do next

without having to interpret a dashboard.

### 1.2 Information When It Matters

Grassy does not attempt to maintain one universal information density.

Different contexts have different requirements:

| Context        | Density               |
| -------------- | --------------------- |
| Server list    | Low                   |
| Server details | Moderate              |
| Settings       | Moderate / structured |
| Server runner  | High                  |
| Console        | Very high             |
| Dialogs        | Focused               |

The server runner is intentionally information-rich because monitoring and controlling a live server requires it.

### 1.3 Desktop First

Grassy should feel like a native desktop application.

It should support:

* keyboard navigation
* predictable focus behavior
* conventional dialogs
* sensible shortcuts
* contextual menus
* resizing
* window management
* immediate feedback

The interface should not imitate a website.

### 1.4 Technical Without Being Programmer-Oriented

Minecraft server management is technical, but Grassy should not visually resemble an IDE or terminal application.

Technical information should be exposed clearly without unnecessarily using:

* monospace typography
* neon colors
* excessive badges
* dense grids
* terminal-inspired decoration
* excessive borders

Use technical styling when the content itself is technical.

### 1.5 Personality Through Restraint

Grassy should have personality, but it should not constantly demand attention.

Playfulness should come from:

* friendly wording
* small visual details
* illustrations
* iconography
* subtle transitions
* server state changes
* occasional small surprises

Ordinary buttons and controls should remain predictable.

---

# 2. Visual Language

Grassy uses a **warm, restrained dark visual language**.

The interface should feel softer and more approachable than typical developer-oriented dark themes.

Avoid basing the visual identity on programming-oriented themes such as Tokyo Night, Dracula, or Nord.

The palette should instead be built from:

* neutral dark surfaces
* warm or slightly desaturated text
* a restrained grassy accent
* distinct semantic colors

The accent is part of Grassy's identity, not a replacement for hierarchy.

## 2.1 Color Distribution

Most of the interface should remain neutral.

A useful approximate relationship is:

**Neutrals > text > accent > semantic colors**

Large areas of saturated color should be avoided.

Accent colors should primarily indicate:

* primary actions
* active controls
* selected navigation
* focus
* important interactive states

They should not be applied indiscriminately to cards, labels, metrics, or backgrounds.

---

# 3. Surface System

Grassy uses a small number of visual layers.

### Background

The application canvas.

Quiet and visually unobtrusive.

### Surface

The primary container level.

Used for things such as:

* server cards
* toolbars
* settings groups
* panels

### Elevated Surface

Used for elements that sit above the normal interface:

* popovers
* menus
* dialogs
* temporary panels

### Recessed Surface

Used when content should visually recede into the interface.

Examples:

* terminal output
* command entry areas
* embedded technical information

Surface differences should be subtle.

Do not create a new color for every component.

---

# 4. Borders and Shadows

Borders are secondary tools for separation.

Prefer this order of visual separation:

1. whitespace
2. typography
3. surface contrast
4. divider
5. border
6. shadow

A component should not receive a border simply because it is a component.

Avoid interfaces where every element appears inside a rounded rectangle.

Shadows should be subtle and reserved for genuinely elevated elements.

---

# 5. Typography

Typography is the primary hierarchy mechanism.

Grassy uses a bundled UI font for normal application content and a monospace font for genuinely technical content.

## 5.1 UI Font

Use the UI font for:

* headings
* server names
* descriptions
* buttons
* settings
* labels
* metrics
* navigation
* dialogs

## 5.2 Monospace Font

Use the monospace font for:

* console output
* commands
* command-line arguments
* logs
* code
* configuration syntax
* other content where character alignment matters

Do not use monospace simply to make ordinary information look technical.

For example:

```text
CPU       38%
Memory    2.4 GB
Players   12
Latency   24 ms
```

should normally use the UI font.

---

# 6. Type Hierarchy

Grassy uses a restrained type scale.

### Window Title

Large and prominent.

Used for major application or dialog titles.

### Section Heading

Used to divide major areas of the interface.

### Server Name / Primary Heading

The most prominent text inside a server-related surface.

### Body

Normal application information and descriptions.

### Caption

Secondary information, metadata, timestamps, and explanations.

### Technical

Technical content such as logs and commands.

Typography should establish hierarchy through:

* size
* weight
* spacing
* contrast

rather than excessive color variation.

---

# 7. Spacing

Grassy follows a consistent spacing rhythm based primarily around 4px increments.

Common values:

* 4px — tightly related elements
* 8px — normal control spacing
* 12px — component padding
* 16px — standard separation
* 24px — section separation
* 32px — major separation

Spacing should communicate relationships.

Elements that belong together should be close.

Unrelated groups should have noticeably more separation.

Do not add spacing simply to satisfy a grid.

---

# 8. Corner Radius

Grassy uses moderate rounding.

Typical values:

* Small controls: 6–8px
* Cards: 8–10px
* Inputs: 7–9px
* Dialogs: 12px
* Popovers
