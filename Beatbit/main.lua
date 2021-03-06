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
            local track = json:decode(love.filesystem.read("tracks/" .. file .. "/track.json"))
            local ok = true
            for j, field in ipairs({{"title", "string"}, {"music", "string"}, {"length", "number"}, {"bpm", "number"}}) do -- required fields
                if not (type(track[field[1]]) == field[2]) then
                    ok = false
                    print("Load failure [" .. file .. "]: missing or invalid " .. field[1])
                end
            end
            if not (type(track.music) == "string") or not love.filesystem.isFile("tracks/" .. file .. "/" .. track.music) then
                ok = false
                print("Load failure [" .. file .. "]: missing or unreadable music at " .. track.music)
            end
            for j, field in ipairs({{"artist", "string", ""}, {"start", "number", 0}, {"speed", "number", 1}, {"melody", "table", {map = {0}}},
                                    {"rhythm", "table", {map = {0}}}, {"changes", "table", {}}}) do -- optional fields
                if not track[field[1]] or not (type(track[field[1]]) == field[2]) then
                    if track[field[1]] then
                        print("Load note [" .. file .. "]: invalid " .. field[1] .. ", using default " .. field[3])
                    end
                    track[field[1]] = field[3]
                end
            end
            if #track.changes > 0 then
                track.changeAts = {} -- (to-be) sorted list of change beat times
                track.changeMap = {} -- mapping from change time to index in changes
                for j, change in ipairs(track.changes) do
                    local changeOk = true
                    if not (type(change.at) == "number") then
                        changeOk = false
                        print("Load warning [" .. file .. "]: (change #" .. j .. ") missing at, skipped")
                    else
                        for k, changeField in ipairs({{"bpm", "number"}, {"speed", "number"}, {"melody", "table"}, {"rhythm", "table"}}) do
                            if change[changeField[1]] and not (type(change[changeField[1]]) == changeField[2]) then
                                change[changeField[1]] = nil
                                print("Load warning [" .. file .. "]: (change #" .. j .. ") invalid " .. changeField[1] .. ", dropped field")
                            end
                        end
                    end
                    if changeOk then
                        table.insert(track.changeAts, change.at)
                        track.changeMap[change.at] = j
                    end
                end
                table.sort(track.changeAts)
            end
            if ok then
                track.dir = file
                tracks[file] = track
            end
        end
    end
    menuPlay = menu(300, function()
        setup.mode = "menu-main"
    end)
    for name, track in next, tracks do
        menuPlay:add({
            label = (track.artist and (track.artist .. " -- ") or "") .. track.title,
            action = function()
                setup.selectTrack(track)
            end
        })
    end
end

menuWinSize = menu(100, function()
    setup.mode = "menu-main"
end)
menuWinSize:add({
    label = "Full screen",
    action = function()
        local width, height = love.window.getDesktopDimensions()
        love.window.setMode(width, height, { -- must set vsync each time, not remembered from love.conf
            fullscreen = true,
            fullscreentype = "desktop",
            vsync = false
        })
        setup.mode = "menu-main"
    end
})
for i, mode in ipairs(love.window.getFullscreenModes()) do -- common resolutions
    if mode.width >= 640 and mode.height >= 480 then
        menuWinSize:add({
            label = mode.width .. "x" .. mode.height,
            action = function()
                love.window.setMode(mode.width, mode.height, {
                    fullscreen = false,
                    vsync = false
                })
                setup.mode = "menu-main"
            end
        })
    end
end

menuMain = menu(100)
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
    label = "Window size",
    action = function()
        if love.window.getFullscreen() then
            menuWinSize.selected = 1
        else
            for i, item in ipairs(menuWinSize.items) do
                if item.label == love.window.getWidth() .. "x" .. love.window.getHeight() then
                    menuWinSize.selected = i
                    break
                end
            end
        end
        setup.mode = "menu-winsize"
    end
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
        elseif setup.mode == "menu-winsize" then
            menuWinSize:update(dt)
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
                love.graphics.print("No tracks loaded!", 120, 14)
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
        elseif setup.mode == "menu-winsize" then
            menuWinSize:draw(120, 10, true)
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
        elseif not kbdPlayer and (key == "return" or key == " ") then
            table.insert(setup.players, true) -- instead of a Joystick table
        elseif not (key == "right") then
            menuPlayers:keypressed(key)
        end
    elseif setup.mode == "menu-winsize" then
        menuWinSize:keypressed(key)
    elseif setup.mode == "game" then
        setup.game:keypressed(key)
    end
end

function love.gamepadpressed(joystick, button)
    if setup.mode == "menu-main" then
        menuMain:gamepadpressed(joystick, button)
    elseif setup.mode == "menu-play" then
        menuPlay:gamepadpressed(joystick, button)
    elseif setup.mode == "menu-players" then
        id = joystick:getID()
        if button == "a" then
            for i, joy in ipairs(setup.players) do
                if not (joy == true) and joy:getID() == id then
                    menuPlayers:gamepadpressed(joystick, button)
                    return
                end
            end
            table.insert(setup.players, joystick)
        elseif button == "b" or button == "dpleft" then
            for i, joy in ipairs(setup.players) do
                if not (joy == true) and joy:getID() == id then
                    table.remove(setup.players, i)
                    return
                end
            end
            menuPlayers:gamepadpressed(joystick, button)
        elseif not (button == "dpright") then
            menuPlayers:gamepadpressed(joystick, button)
        end
    elseif setup.mode == "menu-winsize" then
        menuWinSize:gamepadpressed(joystick, button)
    elseif setup.mode == "game" then
        setup.game:gamepadpressed(key)
    end
end
