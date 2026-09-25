# grassy

## Project layout

```text
src/
├── core/       Shared application utilities and logging
├── models/     Server list and filtering models
└── runner/     Java server process and console backend

qml/
├── components/ Reusable controls and server cards
├── terminal/   Server console view
├── theme/      Theme singleton and local QML module metadata
├── windows/    Secondary windows
└── Main.qml    Application window
```

## Build and run

Xmake uses debug mode by default for this project:

```sh
xmake
xmake run
```

For an optimized release build, select release mode when configuring, then
build:

```sh
xmake f -m release
xmake build
```

Switch back to the fast debug build with:

```sh
xmake f -m debug
```

To rebuild and run the application whenever project files change:

```sh
xmake live-reload
```

The `live-reload` task uses Xmake's watch mode. It rebuilds and restarts the
application when C++, QML, or resource files change. This is not true
hot-reloading: QML is embedded in `src/qml.qrc`, so changes require an
application restart.

## Fish completion

Xmake includes dynamic completion for tasks, options, targets, and project
configuration. Enable Xmake's shell integration once:

```sh
xmake update --integrate
```

Restart Fish, or source the profile installed by Xmake, to activate
completion for `xmake`.
