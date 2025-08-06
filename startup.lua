local function getText(url)
    local response = http.get(url)
    return response.readAll()
end

local editorText = getText("https://raw.githubusercontent.com/DevMevTV/CC-Editor/refs/heads/main/editor.lua")
local startupText = getText("https://raw.githubusercontent.com/DevMevTV/CC-Editor/refs/heads/main/startup.lua")

local aFile = fs.open("/bin/editor.lua", "r")
if aFile.readAll() ~= editorText then
    local bFile = fs.open("/bin/editor.lua", "w+")
    bFile.write(editorText)
    term.setTextColor(colors.green)
    print("Editor Script Updated")
    term.setTextColor(colors.white)
    bFile.close()
end
aFile.close()

local aFile = fs.open("/startup/editor.lua", "r")
if aFile.readAll() ~= startupText then
    local bFile = fs.open("/startup/editor.lua", "w+")
    bFile.write(startupText)
    term.setTextColor(colors.green)
    print("Editor Startup Script Updated")
    term.setTextColor(colors.white)
    bFile.close()
end
aFile.close()

shell.setAlias("editor", "/bin/editor.lua")
