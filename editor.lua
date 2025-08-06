local currentPath = "/"..shell.dir()

local function getFiles()
    local files = fs.list(currentPath)
    
    table.sort(files, function(a, b)
        local aIsDir = fs.isDir(fs.combine(currentPath, a))
        local bIsDir = fs.isDir(fs.combine(currentPath, b))
        
        if aIsDir ~= bIsDir then
            return aIsDir    
        else
            return a:lower() < b:lower()
        end
    end)
    
    return files
end

local mainFrame = {}
local createFrame = {}
local rightClickFrame = {}

local function open()
    local fullPath = fs.combine(currentPath, getFiles()[mainFrame.selection])
    if fs.isDir(fullPath) then
        currentPath = "/"..fullPath
    else
        shell.run("/rom/programs/edit.lua", "\""..fullPath.."\"")
        term.setCursorBlink(false)
    end
end

mainFrame.draw = function()
    local w, _ = term.getSize()
    term.clear()
    term.setCursorPos(1, 1)
    write("Explorer - "..currentPath)
    if not currentPath:find("^/rom") then
        term.setCursorPos(w-2, 1)
        write("[")
        term.setTextColor(colors.green)
        write("+")
        term.setTextColor(colors.white)
        write("]")
    end
    for i, file in pairs(getFiles()) do
        term.setCursorPos(1, i+2)
        if mainFrame.selection == i then
            term.setTextColor(colors.yellow)
            write("> ")
            term.setTextColor(colors.white)
        else
            write("  ")
        end
        if fs.isDir(fs.combine(currentPath, file)) then
            write("[")
            term.setTextColor(colors.green)
            write(file)
            term.setTextColor(colors.white)
            write("]")
        else
            write(file)
        end
    end
end

createFrame.draw = function()
    local w, h = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(w/2-6, h/2-1)
    term.setTextColor(colors.red)
    write("             x")
    term.setTextColor(colors.white)
    term.setCursorPos(w/2-6, h/2)
    write("  ")
    if createFrame.selection == 1 then
        term.setBackgroundColor(colors.lightGray)
        write("New File  ")
        term.setBackgroundColor(colors.gray)
    else
        write("New File  ")
    end
    write("  ")
    term.setCursorPos(w/2-6, h/2+1)
    write("  ")
    if createFrame.selection == 2 then
        term.setBackgroundColor(colors.lightGray)
        write("New Folder")
        term.setBackgroundColor(colors.gray)
    else
        write("New Folder")
    end
    write("  ")
    term.setCursorPos(w/2-6, h/2+2)
    write("              ")
    term.setBackgroundColor(colors.black)
end

rightClickFrame.draw = function()
    local w, h = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(w/2-5, h/2-1)
    term.setTextColor(colors.red)
    write("         x")
    term.setTextColor(colors.white)
    term.setCursorPos(w/2-5, h/2)
    write("  ")
    if rightClickFrame.selection == 1 then
        term.setBackgroundColor(colors.lightGray)
        write("Rename")
        term.setBackgroundColor(colors.gray)
    else
        write("Rename")
    end
    write("  ")
    term.setCursorPos(w/2-5, h/2+1)
    write("  ")
    if rightClickFrame.selection == 2 then
        term.setBackgroundColor(colors.lightGray)
        write("Delete")
        term.setBackgroundColor(colors.gray)
    else
        write("Delete")
    end
    write("  ")
    term.setCursorPos(w/2-5, h/2+2)
    write("          ")
    term.setBackgroundColor(colors.black)
end

mainFrame.handle = function()
    mainFrame.selection = 1
    mainFrame.draw(term.getSize())
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        if event == "key" then
            local key = p1
            if key == keys.up then
                mainFrame.selection = math.max(1, mainFrame.selection - 1)
                mainFrame.draw()
            elseif key == keys.down then
                mainFrame.selection = math.min(#fs.list(currentPath), mainFrame.selection + 1)
                mainFrame.draw()
            elseif key == keys.enter then
                open()
                mainFrame.draw()
            elseif key == keys.backspace and currentPath ~= "/" then
                currentPath = "/"..fs.getDir(currentPath)
                mainFrame.draw()
            end
        elseif event == "mouse_click" then
            local button, x, y = p1, p2, p3
            local w, _ = term.getSize()
            if button == 1 then
                if y == 1 and x >= w - 2 then
                    if not currentPath:find("^/rom") then
                        createFrame.handle()
                        mainFrame.draw()
                    end
                else
                    local index = y - 2
                    local files = getFiles()
                    if index >= 1 and index <= #files then
                        if mainFrame.selection == index then
                            open()
                        else
                            mainFrame.selection = index
                        end
                        mainFrame.draw()
                    end
                end
            elseif button == 2 then
                local index = y - 2
                local files = getFiles()
                if index >= 1 and index <= #files and mainFrame.selection == index and not currentPath:find("^/rom") and not (currentPath == "/" and files[index] == "rom") then
                    rightClickFrame.handle()
                    mainFrame.draw()
                end
            end
        end
    end
end

createFrame.handle = function()
    createFrame.selection = 1
    createFrame.draw()
    
    local function createFile()
        term.clear()
        term.setCursorPos(1, 1)
        write("File Name: ")
        local name = read()
        if fs.exists(fs.combine(currentPath, name)) then
            while true do
                write("File already exists. Do you want to replace it? [Y/N]: ")
                local a = read()
                if a:lower() == "y" then
                    break
                elseif a:lower() == "n" then
                    return
                end
            end
        end
        local file = fs.open(fs.combine(currentPath, name), "w+")
        file.close()
        mainFrame.selection = 1
    end
    
    local function createFolder()
        term.clear()
        term.setCursorPos(1, 1)
        write("Folder Name: ")
        local name = read()
        fs.makeDir(fs.combine(currentPath, name))
    end
    
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        if event == "key" then
            local key = p1
            if key == keys.up then
                createFrame.selection = math.max(1, createFrame.selection - 1)
                createFrame.draw()
            elseif key == keys.down then
                createFrame.selection = math.min(2, createFrame.selection + 1)
                createFrame.draw()
            elseif key == keys.enter then
                if createFrame.selection == 1 then
                    createFile()
                elseif createFrame.selection == 2 then
                    createFolder()
                end
                break
            elseif key == keys.backspace then
                break
            end
        elseif event == "mouse_click" then
            local button, x, y = p1, p2, p3
            local w, h = term.getSize()
            if button == 1 then
                if y == math.floor(h/2 - 1) and x == math.floor(w/2 + 7) then
                    break
                elseif y == math.floor(h/2) and x >= math.floor(w/2-4) and x <= math.floor(w/2+5) then
                    if createFrame.selection ~= 1 then
                        createFrame.selection = 1
                        createFrame.draw()
                    else
                        createFile()
                        break
                    end
                elseif y == math.floor(h/2+1) and x >= math.floor(w/2-4) and x <= math.floor(w/2+5) then
                    if createFrame.selection ~= 2 then
                        createFrame.selection = 2
                        createFrame.draw()
                    else
                        createFolder()
                        break
                    end
                end
            end
        end
    end
end

rightClickFrame.handle = function()
    rightClickFrame.selection = 1
    rightClickFrame.draw()
    
    local function rename()
        local files = getFiles()
        local path = fs.combine(currentPath, files[mainFrame.selection])
        term.clear()
        term.setCursorPos(1, 1)
        write("New Name: ")
        local name = read()
        if fs.exists(fs.combine(currentPath, name)) then
            print(name, "already exists.")
            print("Press any key to continue.")
            os.pullEvent("key")
            return
        end
        fs.move(path, fs.combine(currentPath, name))
    end
    
    local function delete()
        local files = getFiles()
        local path = fs.combine(currentPath, files[mainFrame.selection])
        term.clear()
        term.setCursorPos(1, 1)
        while true do
            write("Are you sure you want to delete "..files[mainFrame.selection].."? [Y/N]: ")
            local a = read()
            if a:lower() == "y" then
                break
            elseif a:lower() == "n" then
                return
            end
        end
        fs.delete(path)
    end
    
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        if event == "key" then
            local key = p1
            if key == keys.up then
                rightClickFrame.selection = math.max(1, rightClickFrame.selection - 1)
                rightClickFrame.draw()
            elseif key == keys.down then
                rightClickFrame.selection = math.min(2, rightClickFrame.selection + 1)
                rightClickFrame.draw()
            elseif key == keys.enter then
                if rightClickFrame.selection == 1 then
                    rename()
                    break
                elseif rightClickFrame.selection == 2 then
                    delete()
                    break
                end
                break
            elseif key == keys.backspace then
                break
            end
        elseif event == "mouse_click" then
            local button, x, y = p1, p2, p3
            local w, h = term.getSize()
            if button == 1 then
                if y == math.floor(h/2-1) and x == math.floor(w/2+4) then
                    break
                elseif y == math.floor(h/2) and x >= math.floor(w/2-3) and x <= math.floor(w/2+2) then
                    if rightClickFrame.selection ~= 1 then
                        rightClickFrame.selection = 1
                        rightClickFrame.draw()
                    else
                        rename()
                        break
                    end
                elseif y == math.floor(h/2+1) and x >= math.floor(w/2-3) and x <= math.floor(w/2+2) then
                    if rightClickFrame.selection ~= 2 then
                        rightClickFrame.selection = 2
                        rightClickFrame.draw()
                    else
                        delete()
                        break
                    end
                end
            end
        end
    end
end

mainFrame.handle()
