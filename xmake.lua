add_rules("mode.debug", "mode.release")

set_project("grassy")
set_version("0.1.0")

set_languages("c++20")

target("grassy")
    add_rules("qt.quickapp")
    add_files("src/**.cpp")
    add_files("src/qml.qrc")
