add_rules("mode.debug", "mode.release")

set_project("grassy")
set_version("0.1.0")

set_languages("c++20")

target("grassy")
    set_kind("binary")
    add_files("src/**.cpp")
