term.clear()

local currentPath = "/"..shell.dir()
local selection = 1

local function drawPlusButton()
    local w, _ = term.getSize()
    term.setCursorPos(w - 2, 1)
    term.write("[")
    term.setTextColor(colors.green)
    term.write("+")
    term.setTextColor(colors.white)
    term.write("]")
end

local function getFiles(path)
    local files = fs.list(path)
    
    table.sort(files, function(a, b)
        local aIsDir = fs.isDir(fs.combine(path, a))
        local bIsDir = fs.isDir(fs.combine(path, b))
        if aIsDir ~= bIsDir then
            return aIsDir
        else
            return a:lower() < b:lower()
        end
    end)
    return files
end

local function draw()
    
    term.clear()
    term.setCursorPos(1, 1)
    print("Explorer - "..currentPath)
    drawPlusButton()
    local files = getFiles(currentPath)
    
    for i, file in ipairs(files) do
        term.setCursorPos(1, i + 2)
        if i == selection then
            term.setTextColor(colors.yellow)
            term.write("> ")
            term.setTextColor(colors.white)
        else
            term.write("  ")
        end
        if fs.isDir(fs.combine(currentPath, file)) then
            term.write("[")
            term.setTextColor(colors.green)
            term.write(file)
            term.setTextColor(colors.white)
            term.write("]")
        else
            term.write(file)
        end
        
    end
    
end

local function open()
    local files = getFiles(currentPath)
    local selected = files[selection]
    local fullPath = fs.combine(currentPath, selected)
    
    if fs.isDir(fullPath) then
        currentPath = "/"..fullPath
        selection = 1
    else
        shell.run("/rom/programs/edit.lua", "\""..fullPath.."\"")
    end
end

local function drawCreateMenu()
    local w, h = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(w/2-6, h/2 - 2)
    write("             ")
    term.setTextColor(colors.red)
    write("x")
    term.setTextColor(colors.white)
    term.setCursorPos(w/2-6, h/2 - 1)
    write("  ")
    if selection == 1 then
        term.setBackgroundColor(colors.lightGray)
        write("New File  ")
        term.setBackgroundColor(colors.gray)
    else
        write("New File  ")
    end
    write("  ")
    term.setCursorPos(w/2-6, h/2)
    write("  ")
    if selection == 2 then
        term.setBackgroundColor(colors.lightGray)
        write("New Folder")
        term.setBackgroundColor(colors.gray)
    else
        write("New Folder")
    end
    write("  ")
    term.setCursorPos(w/2-6, h/2 + 1)
    write("              ")
    term.setBackgroundColor(colors.black)
end

local function showCreateMenu()
    selection = 1
    
    local function createFile()
        write("File Name: ")
        local name = read()
        if fs.exists(fs.combine(currentPath, name)) then
            while true do
                write("File already exists. Do you want to replace it? [Y/N]: ")
                local a = read()
                if a:lower() == "y" then
                    break
                elseif b:lower() == "n" then
                    return
                end
            end
        end
        local file = fs.open(fs.combine(currentPath, name))
        file.close()
        selection = 1
    end
    
    local function createFolder()
        write("Folder Name: ")
        local name = read()
        fs.makeDir(fs.combine(currentPath, name))
        selection = 1
    end
    
    while true do
        drawCreateMenu()
        local event, p1, p2, p3 = os.pullEvent()
        
        if event == "key" then
            local key = p1
            if key == keys.down then
                selection = math.min(2, selection + 1)
            elseif key == keys.up then
                selection = math.max(1, selection - 1)
            elseif key == keys.enter then
                term.clear()
                term.setCursorPos(1, 1)
                if selection == 1 then
                    createFile()
                elseif selection == 2 then
                    write("Folder Name: ")
                    local name = read()
                    fs.makeDir(fs.combine(currentPath, name))
                end
                break
            end
        elseif event == "mouse_click" then
            local button, x, y = p1, p2, p3
            local w, h = term.getSize()
            if button == 1 then
                if y == math.floor(h/2 - 2) and x == math.floor(w/2 + 7) then
                    break
                elseif y == math.floor(h/2 - 1) and x >= math.floor(w/2-4) and x <= math.floor(w/2+5) then
                    if selection ~= 1 then
                        selection = 1
                    else
                        term.clear()
                        term.setCursorPos(1, 1)
                        createFile()
                        break
                    end
                elseif y == math.floor(h/2) and x >= math.floor(w/2-4) and x <= math.floor(w/2+5) then
                    if selection ~= 2 then
                        selection = 2
                    else
                        term.clear()
                        term.setCursorPos(1, 1)
                        createFolder()
                        break
                    end
                end
            end
        end
    end
end


while true do
    draw()
    local event, p1, p2, p3 = os.pullEvent()
    local files = fs.list(currentPath)
    
    if event == "key" then
        local key = p1
        if key == keys.up then
            selection = math.max(1, selection - 1)
        elseif key == keys.down then
            selection = math.min(#files, selection + 1)
        elseif key == keys.enter then
            open()
        elseif key == keys.backspace and currentPath ~= "/" then
            currentPath = "/"..fs.getDir(currentPath)
            selection = 1
        end
    elseif event == "mouse_click" then
        local button, x, y = p1, p2, p3
        local w, _ = term.getSize()
        
        if y == 1 and x >= w - 2 then
            showCreateMenu()
        else
            local index = y - 2
            if index >= 1 and index <= #files then
                if selection == index then
                    open()
                else
                    selection = index
                end
                selection = index
            end
        end
    end
end
