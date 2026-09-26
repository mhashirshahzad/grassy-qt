local root = os.projectdir()
local qml_root = path.join(root, "qml")
local qrc_file = path.join(root, "src", "qml.qrc")

local function xml_escape(value)
    return value:gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
        :gsub('"', "&quot;")
        :gsub("'", "&apos;")
end

local entries = {}

local function add_files(pattern)
    for _, file in ipairs(os.files(path.join(qml_root, pattern))) do
        local alias = path.relative(file, qml_root):gsub("\\", "/")
        local source = path.relative(file, path.join(root, "src")):gsub("\\", "/")

        table.insert(entries, string.format(
            '        <file alias="%s">%s</file>',
            xml_escape(alias),
            xml_escape(source)
        ))
    end
end

-- QML
add_files("**.qml")

-- Icons
add_files("**.svg")

-- Fonts
add_files("**.ttf")
add_files("**.otf")

-- QML modules
for _, module_file in ipairs(os.files(path.join(qml_root, "**/qmldir"))) do
    local alias = path.relative(module_file, qml_root):gsub("\\", "/")
    local source = path.relative(module_file, path.join(root, "src")):gsub("\\", "/")

    table.insert(entries, 1, string.format(
        '        <file alias="%s">%s</file>',
        xml_escape(alias),
        xml_escape(source)
    ))
end

table.sort(entries)

io.writefile(qrc_file, table.concat({
    "<RCC>",
    '    <qresource prefix="/">',
    table.concat(entries, "\n"),
    "    </qresource>",
    "</RCC>",
    ""
}, "\n"))
