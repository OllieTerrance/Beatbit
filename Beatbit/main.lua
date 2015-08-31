menu = require("menu")
player = require("player")
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
    mode = "game"
    music:play()
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
        if pos < 0 then return end
        bgColour = 320 * math.max(0, 0.1 - pos % (60 / track.bpm))
        player1:update(dt)
    end
end

function love.draw()
    love.graphics.printf(love.timer.getFPS(), 770, 10, 20, "right")
    if mode == "menu" then
        menuTracks:draw(10, 10)
    elseif mode == "game" then
        love.graphics.setBackgroundColor(bgColour, bgColour, bgColour)
        player1:draw()
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
            music:stop()
            mode = "menu"
            love.graphics.setBackgroundColor(0, 0, 0)
        end
    end
end
