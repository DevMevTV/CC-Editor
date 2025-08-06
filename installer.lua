fs.makeDir("/bin")

local currentFile = nil

if fs.exists("/startup") and not fs.isDir("/startup") then
    local file = fs.open("/startup", "r")
    currentFile = file.readAll()
    file.close()
    fs.delete("/startup")
end

fs.makeDir("/startup")

if currentFile then
    local file = fs.open("/startup/startup.lua", "w+")
    file.write(currentFile)
    print("Moved /startup to /startup/startup.lua")
    file.close()
end

if fs.exists("/startup/editor.lua") then
    fs.delete("/startup/editor.lua")
end

shell.run("wget", "https://raw.githubusercontent.com/DevMevTV/CC-Editor/refs/heads/main/startup.lua", "/startup/editor.lua")

fs.makeDir("/bin")

if fs.exists("/bin/editor.lua") then
    fs.delete("/bin/editor.lua")
end

shell.run("wget", "https://raw.githubusercontent.com/DevMevTV/CC-Editor/refs/heads/main/editor.lua", "/bin/editor.lua")

shell.setAlias("editor", "/bin/editor.lua")

term.setTextColor(colors.green)
print("Successfully installed Editor")
term.setTextColor(colors.white)