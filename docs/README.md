# Grassy Documentation

Welcome to the Grassy documentation suite. Grassy is a fast, modern Minecraft server manager and runner built with **C++20** and **Qt/QML**.

---

## Documentation Index

- [**Human Interface Guidelines (HIG)**](HIG.md)  
  *Visual standards, typography, Tokyo Night color tokens, component specifications, micro-animations, and UX patterns.*

- [**System Architecture**](ARCHITECTURE.md)  
  *High-level MVC layout, C++ core models and runners, QML component hierarchy, threading model, and build pipeline.*

- [**Contributing Guide**](CONTRIBUTING.md)  
  *Development setup, QML and C++ coding standards, icon asset pipeline, and pull request guidelines.*

---

## Quick Reference

| Resource | Location | Description |
| :--- | :--- | :--- |
| **Theme Singleton** | [`qml/theme/Theme.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/theme/Theme.qml) | Color tokens, surface elevations, bundled fonts. |
| **Server Runner** | [`src/runner/serverrunner.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/runner/serverrunner.hpp) | `QProcess` wrapper, ANSI rich text parser, CPU/RAM telemetry. |
| **Server Model** | [`src/models/servermodel.hpp`](file:///home/mr-pineapple/Projects/grassy-qt/src/models/servermodel.hpp) | Filesystem directory scanner, `server.properties` CRUD. |
| **Main Window** | [`qml/Main.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/Main.qml) | Primary desktop view with custom titlebar and card list. |
| **Server Window** | [`qml/windows/ServerWindow.qml`](file:///home/mr-pineapple/Projects/grassy-qt/qml/windows/ServerWindow.qml) | Detached runner view with telemetry and live terminal. |
