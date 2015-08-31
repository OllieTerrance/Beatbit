menu = require("menu")
player = require("player")
enemy = require("enemy")
json = require("lib.JSON")
io.stdout:setvbuf("no")

bgColour = 0
mode = "menu"

function loadTracks()
    tracks = {}
    dir = love.filesystem.getDirectoryItems("tracks")
    for i, file in ipairs(dir) do
        if love.filesystem.isDirectory("tracks/" .. file)
        and love.filesystem.isFile("tracks/" .. file .. "/track.json") then
            tracks[file] = json:decode(love.filesystem.read("tracks/" .. file .. "/track.json"))
            tracks[file]["dir"] = file
        end
    end
    menuTracks = menu.new()
    for name, track in next, tracks do
        menuTracks:add({
            label = track.artist .. " -- " .. track.title,
            action = function()
                gameTrack = track
                startTrack()
            end
        })
    end
    menuTracks:add({
        label = "Reload",
        action = function()
            loadTracks()
            menuTracks.selected = #menuTracks.items - 1
        end
    })
    menuTracks:add({
        label = "Quit",
        action = love.event.quit
    })
end

function startTrack()
    local track = gameTrack
    music = love.audio.newSource("tracks/" .. track.dir .. "/" .. track.music)
    player1 = player.new()
    enemies = {}
    prevBeat = 0
    mode = "game"
    music:play()
end

function stopTrack()
    music:stop()
    love.graphics.setBackgroundColor(0, 0, 0)
end

function collided(obj1, obj2)
    return obj1.x < obj2.x + obj2.size and obj1.y < obj2.y + obj2.size and
           obj2.x < obj1.x + obj1.size and obj2.y < obj1.y + obj1.size
end

function love.load()
    loadTracks()
end

function love.update(dt)
    if mode == "menu" then
        menuTracks:update(dt)
    elseif mode == "game" then
        local track = gameTrack
        local pos = music:tell() - track.start
        if pos < 0 then return end -- waiting for first beat
        local beat = math.floor(pos / (60 / track.bpm))
        if beat > prevBeat then -- start of next beat
            table.insert(enemies, enemy.new())
            prevBeat = beat
        end
        local prog = pos % (60 / track.bpm) -- amount of time into the current beat
        bgColour = 320 * math.max(0, 0.1 - prog)
        player1:update(dt)
        for i = #enemies, 1, -1 do -- iterate in reverse
            local enemy = enemies[i]
            if not enemy:update(dt) then -- moved outside window
                table.remove(enemies, i)
            end
            if collided(player1, enemy) then
                stopTrack()
                mode = "menu"
            end
        end
    end
end

function love.draw()
    love.graphics.printf(love.timer.getFPS(), 770, 10, 20, "right")
    if mode == "menu" then
        menuTracks:draw(10, 10)
    elseif mode == "game" then
        love.graphics.setBackgroundColor(bgColour, bgColour, bgColour)
        player1:draw()
        for i, enemy in ipairs(enemies) do
            enemy:draw()
        end
    end
end

function love.keypressed(key)
    if mode == "menu" then
        if key == "escape" then
            love.event.quit()
        else
            menuTracks:keypressed(key)
        end
    elseif mode == "game" then
        if key == "escape" then
            stopTrack()
            mode = "menu"
        end
    end
end
