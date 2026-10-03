add_rules("mode.debug", "mode.release")
add_rules("plugin.compile_commands.autoupdate", {outputdir = ".", lsp = "clangd"})

set_project("grassy")
set_version("0.1.0")
set_defaultmode("debug")

set_languages("c++20")

if is_plat("linux") then
    set_config("qt", "/usr/lib/qt6")
elseif is_plat("windows") then
    set_toolchains("mingw")
    add_syslinks("psapi")
end

local function grassy_common()
    add_rules("qt.quickapp")
    if is_plat("mingw") then
        add_packages(
            "qt6core",
            "qt6gui",
            "qt6qml",
            "qt6quick",
            "qt6network",
            "qt6widgets"
        )
        add_links("Qt6QuickControls2")
    end
    add_frameworks("QtNetwork")
    add_frameworks("QtQuickControls2")
    add_frameworks("QtWidgets")
    add_files("src/**.hpp")
    add_files("src/**.cpp")
    add_files("src/qml.qrc")
    add_defines("QT_QML_DEBUG", { mode = "debug" })

end

target("grassy")
    grassy_common()
    before_build(function()
        os.execv("xmake", {"lua", "scripts/generate_qml_qrc.lua"})
    end)

task("mingw")
    set_menu({
        usage = "xmake mingw",
        description = "Configure and build the Windows MinGW target",
    })
    on_run(function()
        local configure = {
            "f", "-v", "-c", "-p", "mingw",
            "--mingw=/usr",
            "--qt=/opt/mingw/qt-sdk/6.11.2/mingw_64",
            "--qt_host=/usr/lib/qt6",
            "-a", "x86_64",
        }
        local status = os.execv("xmake", configure)
        if status ~= 0 then
            raise("MinGW configuration failed")
        end

        status = os.execv("xmake", {"build", "-v", "grassy"})
        if status ~= 0 then
            raise("MinGW build failed")
        end
    end)

task("live-reload")
    set_menu({
        usage = "xmake live-reload",
        description = "Rebuild and restart when project files change",
    })
    on_run(function()
        os.exec("xmake watch --run")
    end)
