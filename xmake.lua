add_rules("mode.debug", "mode.release")
add_rules("plugin.compile_commands.autoupdate", {outputdir = ".", lsp = "clangd"})

set_project("grassy")
set_version("0.1.0")
set_defaultmode("debug")

set_languages("c++20")

local mingw_qt = "/opt/mingw/qt-sdk/6.11.2/mingw_64"
local mingw_runtime = "/usr/x86_64-w64-mingw32/bin"
local is_mingw = is_plat("mingw")

if is_plat("linux") then
    set_config("qt", "/usr/lib/qt6")
elseif is_plat("mingw") then
    set_toolchains("mingw")
    add_syslinks("psapi")
end

rule("grassy.mingw_run")
    if is_mingw then
        on_run(function (target)
            local target_file = target:targetfile()
            local dist_file = path.join(
                path.directory(path.directory(path.directory(target_file))),
                "dist",
                path.filename(target_file)
            )
            if os.isfile(dist_file) then
                target_file = dist_file
            end
            os.execv("wine", {path.absolute(target_file)}, {
                curdir = path.directory(target_file),
                detach = true
            })
        end)
    end

local function grassy_common()
    add_rules("qt.quickapp")
    add_frameworks("QtNetwork", "QtQuickControls2", "QtWidgets")
    add_files("src/**.hpp")
    add_files("src/**.cpp")
    add_files("src/qml.qrc")
    add_defines("QT_QML_DEBUG", { mode = "debug" })

end

target("grassy")
    grassy_common()
    add_rules("grassy.mingw_run")
    before_build(function()
        os.execv("xmake", {"lua", "scripts/generate_qml_qrc.lua"})
    end)

task("linux")
    set_menu({
        usage = "xmake linux",
        description = "Configure and build the native Linux target",
    })
    on_run(function()
        local configure = {
            "f", "-v", "-c", "-p", "linux",
            "--qt=/usr/lib/qt6",
            "-a", "x86_64",
        }
        local status = os.execv("xmake", configure)
        if status ~= 0 then
            raise("Linux configuration failed")
        end

        status = os.execv("xmake", {"build", "-v", "grassy"})
        if status ~= 0 then
            raise("Linux build failed")
        end
    end)

task("mingw")
    set_menu({
        usage = "xmake mingw",
        description = "Configure, build, and stage the Windows MinGW target",
    })
    on_run(function()
        local mode = get_config("mode") or "debug"
        local build_dir = path.join("build", "mingw", "x86_64", mode)
        local dist_dir = path.join(build_dir, "dist")

        local configure = {
            "f", "-v", "-c", "-p", "mingw",
            "-m", mode,
            "--mingw=/usr",
            "--qt=" .. mingw_qt,
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

        os.rm(dist_dir)
        os.mkdir(dist_dir)

        local function copy_files(source_dir, pattern, destination)
            for _, file in ipairs(os.files(path.join(source_dir, pattern))) do
                local relative_file = path.relative(file, source_dir)
                local destination_file = path.join(destination, relative_file)
                os.mkdir(path.directory(destination_file))
                os.cp(file, destination_file)
            end
        end

        copy_files(build_dir, "grassy.exe", dist_dir)
        copy_files(".", "qt.conf", dist_dir)
        copy_files(path.join(mingw_qt, "bin"), "Qt6*.dll", dist_dir)
        copy_files(mingw_runtime, "libgcc_s_seh-1.dll", dist_dir)
        copy_files(mingw_runtime, "libstdc++-6.dll", dist_dir)
        copy_files(mingw_runtime, "libwinpthread-1.dll", dist_dir)
        copy_files(path.join(mingw_qt, "qml"), "**", path.join(dist_dir, "qml"))
        copy_files(
            path.join(mingw_qt, "plugins", "platforms"),
            "*.dll",
            path.join(dist_dir, "plugins", "platforms")
        )
    end)

task("live-reload")
    set_menu({
        usage = "xmake live-reload",
        description = "Rebuild and restart when project files change",
    })
    on_run(function()
        os.exec("xmake watch --run")
    end)
