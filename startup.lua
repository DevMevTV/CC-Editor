local function getText(url)
    local response = http.get(url)
    return response.readAll()
end

local editorText = getText("https://raw.githubusercontent.com/DevMevTV/CC-Editor/refs/heads/main/editor.lua")
local startupText = getText("https://raw.githubusercontent.com/DevMevTV/CC-Editor/refs/heads/main/startup.lua")

local file = fs.open("/bin/editor.lua", "rw")
if file.readAll() ~= editorText then
    file.write(editorText)
    term.setTextColor(colors.green)
    print("Editor Script Updated")
    term.setTextColor(colors.white)
end
file.close()

local file = fs.open("/startup/editor.lua", "rw")
if file.readAll() ~= startupText then
    file.write(startupText)
    term.setTextColor(colors.green)
    print("Editor Startup Script Updated")
    term.setTextColor(colors.white)
end
file.close()

shell.setAlias("editor", "/bin/editor.lua")