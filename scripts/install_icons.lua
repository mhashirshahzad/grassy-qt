local root = os.projectdir()
local destination = path.join(root, "qml", "icons")

local icons = {
    cog = "https://raw.githubusercontent.com/Templarian/MaterialDesign/master/svg/cog.svg",
    magnify = "https://raw.githubusercontent.com/Templarian/MaterialDesign/master/svg/magnify.svg",
    refresh = "https://raw.githubusercontent.com/Templarian/MaterialDesign/master/svg/refresh.svg",
    plus = "https://raw.githubusercontent.com/Templarian/MaterialDesign/master/svg/plus.svg"
}

os.mkdir(destination)

for name, url in pairs(icons) do
    local output = path.join(destination, name .. ".svg")
    print("Downloading " .. name .. ".svg")
    os.vrunv("curl", {
        "--fail",
        "--location",
        "--silent",
        "--show-error",
        "--output", output,
        url
    })

    local contents = io.readfile(output)
    contents = contents:gsub('fill="#000000"', 'fill="#cdd6f4"')
    contents = contents:gsub("<path ", '<path fill="#cdd6f4" ')
    io.writefile(output, contents)
end
