json = require("lib.JSON")
menu = require("menu")
game = require("game")
io.stdout:setvbuf("no")

local soundDeny = love.audio.newSource("sound/deny.wav", "static")

local colours = {{128, 192, 255}, {255, 128, 128}, {255, 255, 128}, {128, 255, 192}, {192, 192, 192}}

function loadTracks()
    tracks = {}
    local dir = love.filesystem.getDirectoryItems("tracks")
    for i, file in ipairs(dir) do
        if love.filesystem.isDirectory("tracks/" .. file)
        and love.filesystem.isFile("tracks/" .. file .. "/track.json") then
            tracks[file] = json:decode(love.filesystem.read("tracks/" .. file .. "/track.json"))
            tracks[file].dir = file
        end
    end
    menuPlay = menu(300, function()
        setup.mode = "menu-main"
    end)
    for name, track in next, tracks do
        menuPlay:add({
            label = track.artist .. " -- " .. track.title,
            action = function()
                setup.selectTrack(track)
            end
        })
    end
end

menuMain = menu(100, love.event.quit)
menuMain:add({
    label = "Play!",
    action = function()
        setup.mode = "menu-play"
    end
})
menuMain:add({
    label = "Reload tracks",
    action = loadTracks
})
menuMain:add({
    label = "Quit",
    action = love.event.quit
})

menuPlayers = nil

setup = {mode = "menu-main"}

function setup.selectTrack(track)
    setup.track = track
    setup.players = {}
    menuPlayers = menu(60, function()
        setup.track = nil
        setup.players = nil
        setup.mode = "menu-play"
    end)
    menuPlayers:add({
        label = "Start!",
        action = function()
            setup.game = game(setup.track, setup.players)
            setup.mode = "game"
        end
    })
    setup.mode = "menu-players"
end

function love.load()
    loadTracks()
end

function love.update(dt)
    if setup.game and setup.game.stopped then
        setup.game = nil
        setup.track = nil
        setup.players = nil
        setup.mode = "menu-main"
    end
    if string.sub(setup.mode, 0, 4) == "menu" then
        menuMain:update(dt)
        if string.sub(setup.mode, 0, 9) == "menu-play" then
            menuPlay:update(dt)
            if setup.mode == "menu-players" then
                menuPlayers:update(dt)
                -- do something cool with joysticks
            end
        end
    elseif setup.mode == "game" then
        setup.game:update(dt)
    end
end

function love.draw()
    love.graphics.setColor(128, 128, 128)
    love.graphics.printf(love.timer.getFPS(), love.window.getWidth() - 30, 10, 20, "right")
    if string.sub(setup.mode, 0, 4) == "menu" then
        love.graphics.setColor(64, 64, 64)
        love.graphics.printf("Beatbit", love.window.getWidth() - 30, love.window.getHeight() - 25, 20, "right")
        love.graphics.setColor(128, 128, 128)
        menuMain:draw(10, 10, setup.mode == "menu-main")
        if string.sub(setup.mode, 0, 9) == "menu-play" then
            if next(menuPlay.items) == nil then
                love.graphics.print("No tracks detected!", 120, 14)
            else
                menuPlay:draw(120, 10, setup.mode == "menu-play")
            end
            if setup.mode == "menu-players" then
                menuPlayers:draw(430, 10, not (next(setup.players) == nil))
                if next(setup.players) == nil then
                    love.graphics.print("Keyboard: press Enter to join\nControllers ("
                            .. love.joystick.getJoystickCount() .. " detected): press primary button", 430, 34)
                else
                    for i, joy in ipairs(setup.players) do
                        love.graphics.setColor(unpack(colours[((i - 1) % #colours) + 1]))
                        local player = (joy == true and "keyboard" or ("controller [" .. joy:getName() .. "]"))
                        love.graphics.print("Player " .. i .. ": " .. player, 430, 19 + (15 * i))
                    end
                end
            end
        end
    elseif setup.mode == "game" then
        setup.game:draw()
    end
end

function love.keypressed(key)
    if setup.mode == "menu-main" then
        menuMain:keypressed(key)
    elseif setup.mode == "menu-play" then
        menuPlay:keypressed(key)
    elseif setup.mode == "menu-players" then
        local kbdPlayer = false
        for i, joy in ipairs(setup.players) do
            if joy == true then
                kbdPlayer = i
                break
            end
        end
        if kbdPlayer and (key == "left" or key == "backspace" or key == "escape") then
            table.remove(setup.players, kbdPlayer)
        elseif not kbdPlayer and (key == "right" or key == "return" or key == " ") then
            table.insert(setup.players, true) -- instead of a Joystick table
        else
            menuPlayers:keypressed(key)
        end
    elseif setup.mode == "game" then
        setup.game:keypressed(key)
    end
end

function love.gamepadpressed(joystick, button)
    if setup.mode == "menu-players" then
        id = joystick:getID()
        if button == "a" then
            for i, joy in ipairs(setup.players) do
                if not (joy == true) and joy:getID() == id then
                    menuPlayers:keypressed("return")
                    return
                end
            end
            table.insert(setup.players, joystick)
        elseif button == "b" then
            for i, joy in ipairs(setup.players) do
                if joy:getID() == id then
                    table.remove(setup.players, i)
                    return
                end
            end
        end
    end
end
