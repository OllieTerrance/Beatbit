json = require("lib.JSON")
menu = require("menu")
game = require("game")
io.stdout:setvbuf("no")

mode = "menu"

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

function love.load()
    loadTracks()
end

function love.update(dt)
    if curGame and curGame.stopped then
        curGame = nil
        mode = "menu"
    end
    if mode == "menu" then
        menuTracks:update(dt)
    elseif mode == "game" then
        curGame:update(dt)
    end
end

function love.draw()
    love.graphics.printf(love.timer.getFPS(), 770, 10, 20, "right")
    if mode == "menu" then
        menuTracks:draw(10, 10)
    elseif mode == "game" then
        curGame:draw()
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
        curGame:keypressed(key)
    end
end
