add_rules("mode.debug", "mode.release")

set_project("grassy")
set_version("0.1.0")

set_languages("c++20")
set_config("qt", "/usr/lib/qt6")

rule("qml.qrc.generator")
    set_extensions(".qml", ".svg")
    on_buildcmd_file(function(_, batchcmds, sourcefile, opt)
        batchcmds:show_progress(opt.progress, "${color.build.object}generating.qrc %s", sourcefile)
        batchcmds:vrunv("xmake", {"lua", "scripts/generate_qml_qrc.lua"})
    end)

target("grassy")
    add_rules("qt.quickapp")
    add_files("qml/**.qml", {rule = "qml.qrc.generator"})
    add_files("qml/**.svg", {rule = "qml.qrc.generator"})
    add_files("src/utils.hpp", "src/servermodel.hpp", {rules = "qt.moc"})
    add_files("src/**.cpp")
    add_files("src/qml.qrc")
