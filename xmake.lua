add_rules("mode.debug", "mode.release")

set_project("grassy")
set_version("0.1.0")
set_defaultmode("debug")

set_languages("c++20")

if is_plat("windows") then
    set_toolchains("mingw")
    set_config("qt", "/opt/Qt/6.x.x/mingw_64")
else
    set_config("qt", "/usr/lib/qt6")
end

rule("qml.qrc.generator")
    set_extensions(".qml", ".svg", ".ini")
    on_buildcmd_file(function(_, batchcmds, sourcefile, opt)
        batchcmds:show_progress(opt.progress, "${color.build.object}generating.qrc %s", sourcefile)
        batchcmds:vrunv("xmake", {"lua", "scripts/generate_qml_qrc.lua"})
    end)

target("grassy")
    add_rules("qt.quickapp")
    add_frameworks("QtNetwork")
    add_frameworks("QtQuickControls2")
    add_frameworks("QtWidgets")
    add_files("qml/**.qml", {rule = "qml.qrc.generator"})
    add_files("qml/**.svg", {rule = "qml.qrc.generator"})
    add_files("qml/**.ini", {rule = "qml.qrc.generator"})
    add_files("src/**.hpp")
    add_files("src/**.cpp")
    add_files("src/qml.qrc")
    add_defines("QT_QML_DEBUG", {mode = "debug"})

task("live-reload")
    set_menu {
        usage = "xmake live-reload",
        description = "Rebuild and restart when project files change",
    }

    on_run(function()
        os.exec("xmake watch --run")
    end)
