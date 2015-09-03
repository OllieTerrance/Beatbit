json = require("lib.JSON")
menu = require("menu")
game = require("game")
io.stdout:setvbuf("no")

local soundDeny = love.audio.newSource("sound/deny.wav", "static")

local mode = "menu-main"
local menuMain = menu(100)
menuMain:add({
    label = "Single player",
    action = function()
        mode = "menu-play"
    end
})
menuMain:add({
    label = "Reload tracks",
    action = function()
        loadTracks()
    end
})
menuMain:add({
    label = "Quit",
    action = love.event.quit
})

function loadTracks()
    tracks = {}
    local dir = love.filesystem.getDirectoryItems("tracks")
    for i, file in ipairs(dir) do
        if love.filesystem.isDirectory("tracks/" .. file)
        and love.filesystem.isFile("tracks/" .. file .. "/track.json") then
            tracks[file] = json:decode(love.filesystem.read("tracks/" .. file .. "/track.json"))
            tracks[file]["dir"] = file
        end
    end
    menuTracks = menu()
    for name, track in next, tracks do
        menuTracks:add({
            label = track.artist .. " -- " .. track.title,
            action = function()
                curGame = game(track)
                mode = "game"
            end
        })
    end
end

function love.load()
    loadTracks()
end

function love.update(dt)
    if curGame and curGame.stopped then
        curGame = nil
        mode = "menu-main"
    end
    if mode == "menu-main" then
        menuMain:update(dt)
    elseif mode == "menu-play" then
        menuTracks:update(dt)
    elseif mode == "game" then
        curGame:update(dt)
    end
end

function love.draw()
    love.graphics.setColor(128, 128, 128)
    love.graphics.printf(love.timer.getFPS(), love.window.getWidth() - 30, 10, 20, "right")
    if string.sub(mode, 0, 4) == "menu" then
        love.graphics.setColor(64, 64, 64)
        love.graphics.printf("Beatbit", love.window.getWidth() - 30, love.window.getHeight() - 25, 20, "right")
        love.graphics.setColor(128, 128, 128)
        menuMain:draw(10, 10, mode == "menu-main")
    end
    if mode == "menu-play" then
        if next(menuTracks.items) == nil then
            love.graphics.print("No tracks detected!", 120, 14)
        else
            menuTracks:draw(120, 10, true)
        end
    elseif mode == "game" then
        curGame:draw()
    end
end

function love.keypressed(key)
    if mode == "menu-main" then
        if key == "escape" then
            love.event.quit()
        else
            menuMain:keypressed(key)
        end
    elseif mode == "menu-play" then
        if key == "escape" or key == "left" then
            mode = "menu-main"
            menuTracks.selected = 1
        elseif next(menuTracks.items) == nil then
            if key == "up" or key == "down" or key == "right" or key == "return" then
                soundDeny:play()
            end
        else
            menuTracks:keypressed(key)
        end
    elseif mode == "game" then
        curGame:keypressed(key)
    end
end
