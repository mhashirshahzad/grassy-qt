# Contributing to Grassy

Thank you for your interest in contributing to Grassy! This guide provides the coding conventions, design principles, and development workflows to help you build clean, performant, and consistent features.

---

## 1. Development Setup

### Prerequisites

Ensure you have the following installed on your system:
- **C++ Compiler**: Supporting C++20 (GCC 11+, Clang 13+)
- **Qt 6**: `QtNetwork`, `QtQuickControls2`, `QtWidgets` (development packages)
- **Xmake**: Build system (`curl -fsSL https://xmake.io/shget.text | bash`)
- **Java**: JRE/JDK 17+ or 21+ for running Minecraft servers

### Building & Running

1. **Configure and build**:
   ```sh
   xmake
   xmake run
   ```

2. **Live Reload / Watch Mode**:
   ```sh
   xmake live-reload
   ```
   *Note: Because QML is packaged into `src/qml.qrc`, changes restart the application to reload the resource package.*

3. **Optimized Release Build**:
   ```sh
   xmake f -m release
   xmake build
   ```

---

## 2. QML Coding Conventions

Grassy emphasizes readable, modular, and performant QML code.

### 2.1 File & Item Structure

Organize properties and child elements in this consistent order:

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme" 1.0

Item {
    id: root

    // 1. Required and public properties
    required property string serverName
    property bool isActive: false

    // 2. Signals
    signal actionTriggered(string details)

    // 3. Geometry & Layout properties
    implicitWidth: 200
    implicitHeight: 40

    // 4. Visual properties (colors, borders, radius)
    // Always use Theme tokens! Never hardcode hex values!

    // 5. Child items & Layouts
    RowLayout {
        anchors.fill: parent
        // ...
    }

    // 6. States and Transitions

    // 7. JavaScript helper functions
    function computeStatus() {
        // ...
    }
}
```

### 2.2 Key Rules

- **Use Theme Tokens**: **Never** write `#ffffff` or `#1a1b26` directly in components. Always use `Theme.background`, `Theme.surface`, `Theme.accent`, etc. (See [`docs/HIG.md`](file:///home/mr-pineapple/Projects/grassy-qt/docs/HIG.md)).
- **Type Your Properties**: Avoid generic `property var` whenever a concrete type (`string`, `int`, `double`, `bool`, `color`, `url`) is known.
- **Use `required property` for Model Delegates**: When writing list/grid delegates, declare required properties so Qt Quick verifies model bindings at compile time.
- **Avoid Tight Coupling**: Components in `qml/components/` should not assume the existence of global objects outside their properties or signals. Pass dependencies or use signals for interaction.
- **Smooth Animations**:
  - Keep animations brief (`100ms` - `180ms`).
  - Use `Easing.OutCubic` for natural deceleration and `Easing.OutBack` for playful micro-bounces.

---

## 3. C++ Coding Conventions

The C++ backend lives in `src/` and interfaces with Qt Quick.

### 3.1 Standards & Modern C++
- Use **C++20** features appropriately (designated initializers, `std::string_view` where applicable, ranges, concepts).
- Use `#pragma once` for header guards.
- Prefer `const` references (`const QString &`) for parameter passing of Qt types.
- Follow Qt naming conventions: `camelCase` for methods/variables, `PascalCase` for classes/enums, and `m_` prefix for private member variables (e.g. `m_process`, `m_serverName`).

### 3.2 Qt Idioms & Memory Safety
- **QObject Ownership**: Always specify a `parent` `QObject` for heap allocations, or manage lifetimes with `std::unique_ptr`.
- **Properties & Signals**:
  - Provide a `NOTIFY` signal for QML properties that can mutate.
  - Mark immutable properties as `CONSTANT`.
  - Use `Q_INVOKABLE` only when a method needs to be called directly from QML.
- **Modern Connect Syntax**: Always use member function pointers or lambdas:
  ```cpp
  connect(m_process, &QProcess::readyReadStandardOutput, this, &ServerRunner::readOutput);
  ```
- **Process & Async Safety**: Do not block the GUI thread with synchronous calls (`waitForStarted()`, `waitForFinished()`). Rely on asynchronous Qt signals (`started()`, `finished()`, `readyReadStandardOutput()`).

---

## 4. Iconography & Assets

- Icons are stored as SVGs in `qml/icons/`.
- We use [Material Design Icons](https://pictogrammers.com/library/mdi/) as our base icon set.
- To add or update icons:
  1. Add the icon definition to `scripts/install_icons.lua`.
  2. Run the script via:
     ```sh
     xmake lua scripts/install_icons.lua
     ```
  3. The script downloads the SVG and normalizes the fill color.
  4. The resource file `src/qml.qrc` will be updated automatically during the next build via `scripts/generate_qml_qrc.lua`.

---

## 5. Submitting Changes

1. **Verify Builds**: Ensure the project compiles cleanly in both debug and release configurations without warnings.
2. **Adhere to the HIG**: Test UI additions against [`docs/HIG.md`](file:///home/mr-pineapple/Projects/grassy-qt/docs/HIG.md) for padding, typography, hover animations, and color accuracy.
3. **Keep Commits Clean**: Write concise, descriptive commit messages outlining what was added, fixed, or improved.
