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
for _, qml_file in ipairs(os.files(path.join(qml_root, "**.qml"))) do
    local alias = path.relative(qml_file, qml_root):gsub("\\", "/")
    local source = path.relative(qml_file, path.join(root, "src")):gsub("\\", "/")
    table.insert(entries, string.format(
        '        <file alias="%s">%s</file>',
        xml_escape(alias),
        xml_escape(source)
    ))
end
for _, icon_file in ipairs(os.files(path.join(qml_root, "**.svg"))) do
    local alias = path.relative(icon_file, root):gsub("\\", "/")
    local source = path.relative(icon_file, path.join(root, "src")):gsub("\\", "/")
    table.insert(entries, string.format(
        '        <file alias="%s">%s</file>',
        xml_escape(alias),
        xml_escape(source)
    ))
end
table.sort(entries)
table.insert(entries, 1, '        <file alias="qmldir">../qml/qmldir</file>')

io.writefile(qrc_file, table.concat({
    "<RCC>",
    '    <qresource prefix="/">',
    table.concat(entries, "\n"),
    "    </qresource>",
    "</RCC>",
    ""
}, "\n"))
