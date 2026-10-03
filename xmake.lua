add_rules("mode.debug", "mode.release")

set_project("grassy")
set_version("0.1.0")
set_defaultmode("debug")

set_languages("c++20")

rule("qml.qrc.generator")
set_extensions(".qml", ".svg", ".ini")
on_buildcmd_file(function(_, batchcmds, sourcefile, opt)
	batchcmds:show_progress(opt.progress, "${color.build.object}generating.qrc %s", sourcefile)
	batchcmds:vrunv("xmake", { "lua", "scripts/generate_qml_qrc.lua" })
end)

-- Shared settings for both targets
local function grassy_common(t)
	t:add_rules("qt.quickapp")
	t:add_frameworks("QtNetwork")
	t:add_frameworks("QtQuickControls2")
	t:add_frameworks("QtWidgets")
	t:add_files("qml/**.qml", { rule = "qml.qrc.generator" })
	t:add_files("qml/**.svg", { rule = "qml.qrc.generator" })
	t:add_files("qml/**.ini", { rule = "qml.qrc.generator" })
	t:add_files("src/**.hpp")
	t:add_files("src/**.cpp")
	t:add_files("src/qml.qrc")
	t:add_defines("QT_QML_DEBUG", { mode = "debug" })
end

-- Native Linux target (default)
target("grassy")
grassy_common(target)
if is_plat("linux") then
	set_config("qt", "/usr/lib/qt6")
end

-- Windows cross-compile target
target("windows")
grassy_common(target)
set_toolchains("mingw", { sdk = "/usr/x86_64-w64-mingw32" })
set_config("qt", "/usr/x86_64-w64-mingw32")
set_config("qt_host", "/usr")

task("live-reload")
set_menu({
	usage = "xmake live-reload",
	description = "Rebuild and restart when project files change",
})

on_run(function()
	os.exec("xmake watch --run")
end)
