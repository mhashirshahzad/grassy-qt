# Grassy System Architecture

This document describes the architectural layout, core subsystems, data flow, and runtime lifecycle of **Grassy Qt**.

---

## 1. High-Level Overview

Grassy follows a clean **Model-View-Controller (MVC)** hybrid architecture:

- **Frontend (View & UI Controllers)**: Written in **QML (QtQuick 2.15 / QtQuick Controls 2)**. Handles rendering, user interactions, layout responsiveness, animations, and visual state.
- **Backend (Business Logic, OS & Process Control)**: Written in **C++20** using **Qt 6**. Handles filesystem I/O, process management (`QProcess`), system telemetry (/proc), network operations, and data models.
- **Build System & Asset Pipeline**: Managed via **Xmake** and custom **Lua** generators that compile QML and assets into Qt resources (`src/qml.qrc`).

```
┌─────────────────────────────────────────────────────────────┐
│                       QML Frontend                          │
│                                                             │
│   Main.qml        ServerCard.qml       ServerTerminal.qml   │
│   ServerWindow    SettingsPopups       Theme (Singleton)    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                 Signals / Slots / Invokables
                 Context Properties & Registered Types
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                       C++ Backend                           │
│                                                             │
│   ServerRunner          ServerModel       ServerFilterModel │
│   (QProcess / Telemetry) (List Model)      (Proxy Filter)    │
│                                                             │
│   Utils (Network & Paths)       ServerConfig (EULA / Props) │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    OS / Filesystem
      ┌────────────────────┼────────────────────┐
      ▼                    ▼                    ▼
Minecraft Processes   server.properties     ~/.config/grassy
```

---

## 2. Component Subsystems

### 2.1 Core Utilities (`src/core/`)

- **`Utils` ([`src/core/utils.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/core/utils.hpp), [`src/core/utils.cpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/core/utils.cpp))**:
  - Exported to QML as a root context property named `utils`.
  - **Java Runtime Detection**: Verifies if Java is available on the host machine (`isJavaInstalled()`).
  - **Network Resolution**:
    - Queries active network interfaces for local IP (`localIp()`).
    - Performs an asynchronous HTTP GET via `QNetworkAccessManager` to `https://api.ipify.org` to detect public IP (`publicIp()`, `refreshPublicIp()`).
  - **Configuration Directory**: Resolves and persists the root server directory in `~/.config/grassy/settings.txt` using standard platform paths.
  - **Native File Dialogs**: Wraps `QFileDialog::getExistingDirectory` for cross-platform folder selection (`chooseDirectory()`).
  - **Clipboard Helper**: Integrates with `QGuiApplication::clipboard()` for copy actions.

- **`ServerConfig` ([`src/core/serverconfig.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/core/serverconfig.hpp))**:
  - Automatically checks and ensures `eula=true` in `eula.txt` before a server is launched (`ensureEulaAccepted()`).

---

### 2.2 Models & Data Management (`src/models/`)

- **`ServerModel` ([`src/models/servermodel.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/models/servermodel.hpp), [`src/models/servermodel.cpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/models/servermodel.cpp))**:
  - Inherits from `QAbstractListModel`.
  - Scans the configured server storage directory for child folders containing `server.properties` or server jars.
  - Exposes server items with model roles:
    - `NameRole` (`name`): Server display name (folder name or custom override).
    - `MotdRole` (`motd`): Message of the day parsed from `server.properties`.
    - `FolderRole` (`folder`): Absolute filesystem path to the server directory.
  - Provides invokable CRUD and configuration methods:
    - `refresh()`: Re-scans disk for added or removed servers.
    - `renameServer(folder, name)`: Renames server directory safely.
    - `deleteServer(folder)`: Recursively removes server directory after confirmation.
    - `serverProperties(folder)`: Reads raw contents of `server.properties`.
    - `saveServerProperties(folder, contents)`: Writes modified properties back to disk.
    - `setServerProperty(folder, key, value)`: Atomically updates an individual property.
    - `createStartScript(folder, minRam, maxRam)`: Generates an executable `start.sh` script with optimal JVM flags.

- **`ServerFilterModel` ([`src/models/serverfiltermodel.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/models/serverfiltermodel.hpp))**:
  - Inherits from `QSortFilterProxyModel`.
  - Wraps `ServerModel` to provide sub-string and fuzzy filtering for search inputs without mutating the underlying data source.
  - Exported to QML root context as `serverModel`.

---

### 2.3 Process Execution & Telemetry (`src/runner/`)

- **`ServerRunner` ([`src/runner/serverrunner.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/runner/serverrunner.hpp), [`src/runner/serverrunner.cpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/runner/serverrunner.cpp))**:
  - Registered as a QML type (`Grassy.ServerRunner 1.0`).
  - Instantiated per server window to isolate runner instances.
  - Manages the lifecycle of the Minecraft Java server process via an internal `QProcess`.
  - **Process Execution Flow**:
    1. Validates working directory and runs `ensureEulaAccepted()`.
    2. Prefers launching `./start.sh` if present; falls back to locating the primary `.jar` and executing `java -Xms2G -Xmx4G -jar <server>.jar nogui`.
    3. Connects standard output/error signals (`readyReadStandardOutput`, `readyReadStandardError`).
  - **Console Stream & ANSI Parsing**:
    - Converts raw terminal escape sequences and Minecraft color codes into sanitized, Tokyo Night colored HTML spans (`consoleHtml`).
    - Dispatches commands asynchronously directly to process `stdin` via `sendCommand(text)`.
    - Supports graceful shutdown (`stop()`, writing `"stop\n"`) and `SIGINT` interruption (`interrupt()`).
  - **Resource Monitoring**:
    - Uses a `QTimer` polling every 1000ms.
    - On Linux, reads `/proc/<pid>/stat` and `/proc/<pid>/statm` to compute real-time CPU percentage and Resident Set Size (RSS) memory consumption (`cpuUsage`, `memoryUsageKb`).
    - Reports available host CPU core count (`QThread::idealThreadCount()`).

---

### 2.4 UI Hierarchy & QML Modules (`qml/`)

The QML directory is organized into modular namespaces declared via `qmldir`:

```
qml/
├── components/           # Reusable UI controls
│   ├── ThemedButton.qml  # Primary animated button
│   ├── IconButton.qml    # SVG icon button with wiggle micro-interaction
│   ├── CustomTextField.qml # Search-capable styled text entry
│   ├── ServerCard.qml    # Server list item presentation
│   ├── JavaStatusBar.qml # Bottom dock status for runtime environment
│   └── settings/         # Specific server.properties editors (Gameplay, Network, etc.)
├── popups/               # Modals & Dialogs
│   ├── CustomPopup.qml   # Base animated dialog container
│   ├── ServerSettingsPopup.qml # Tabbed server.properties editor
│   ├── GrassySettingsPopup.qml # Global settings, IP viewer, folder chooser
│   ├── RenameServerPopup.qml   # Server renaming modal
│   └── DeleteServerPopup.qml   # Destructive deletion confirmation
├── terminal/             # Console interface
│   └── ServerTerminal.qml# RichText terminal view and command dispatch
├── windows/              # Detached secondary windows
│   └── ServerWindow.qml  # Dedicated runner view for active servers
├── theme/                # Global design system
│   └── Theme.qml         # Colors, surface tokens, fonts singleton
└── Main.qml              # Application entry shell
```

---

## 3. Communication & Threading Model

1. **Qt Event Loop**: Grassy runs on the main GUI thread. Intensive filesystem scans in `ServerModel` and asynchronous network requests in `Utils` are executed via non-blocking Qt APIs.
2. **Subprocess Isolation**: Server processes run as completely isolated external child processes managed by `QProcess`. Even if a server crashes, runs out of memory, or encounters a Java exception, Grassy remains completely stable and responsive.
3. **Window Decoupling**: Each `ServerWindow` instantiates its own `ServerRunner`. Closing the main window keeps runner windows alive if intended, or handles safe cleanup through `ServerRunner::shutdown()`.

---

## 4. Build System & Resource Generation

Grassy uses [Xmake](https://xmake.io) for compilation and dependency management:

- **Resource Embedding**:
  - QML files, SVG icons, and TTF fonts are packaged into the application binary via Qt's resource compiler (`rcc`).
  - `scripts/generate_qml_qrc.lua` automatically crawls the `qml/` directory and builds `src/qml.qrc` before compilation.
- **Icon Pipeline**:
  - `scripts/install_icons.lua` downloads Material Design icons from upstream repositories and normalizes SVG fill colors to match the theme.
- **Live Reload Task**:
  - `xmake live-reload` watches the codebase and automatically recompiles and restarts the application on change.
