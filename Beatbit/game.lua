player = require("player")
enemy = require("enemy")

local soundBuzz = love.audio.newSource("sound/buzz.wav", "static")
local soundHit = love.audio.newSource("sound/hit.wav", "static")

local colours = {{128, 192, 255}, {255, 128, 128}, {255, 255, 128}, {128, 255, 192}, {192, 192, 192}}

local game = {}
game.__index = game

setmetatable(game, {
    __call = function(cls, track, players)
        local self = setmetatable({}, cls)
        self:new(track, players)
        return self
    end
})

function game.new(self, track, players)
    self.track = track
    self.music = love.audio.newSource("tracks/" .. self.track.dir .. "/" .. self.track.music)
    self.players = {}
    for i, joy in ipairs(players) do
        table.insert(self.players, player(joy, colours[((i - 1) % #colours) + 1]))
    end
    self.enemies = {}
    self.bullets = {}
    self.beat = 0
    self.bgColour = 0
    self.menuPause = menu(100, function()
        self.pause = false
        self.music:play()
    end)
    self.menuPause:add({
        label = "Continue",
        action = function()
            self.pause = false
            self.music:play()
        end
    })
    self.menuPause:add({
        label = "Restart",
        action = function()
            for i, plr in ipairs(self.players) do
                plr.x = math.random(plr.size / 2, love.window.getWidth() - (plr.size / 2))
                plr.y = math.random(plr.size / 2, love.window.getHeight() - (plr.size / 2))
                plr.score = 0
                plr.deaths = 0
            end
            self.enemies = {}
            self.bullets = {}
            self.beat = 0
            self.bgColour = 0
            self.music:rewind()
            self.pause = false
            self.music:play()
        end
    })
    self.menuPause:add({
        label = "Quit",
        action = function()
            love.graphics.setBackgroundColor(0, 0, 0)
            self.stopped = true
        end
    })
    self.music:play()
end

function game.update(self, dt)
    if self.pause then
        self.menuPause:update(dt)
        return
    end
    local pos = self.music:tell() - self.track.start
    if pos < 0 then -- waiting for first beat
        return
    end
    local prog = pos % (60 / self.track.bpm) -- amount of time into the current beat
    local beat = math.floor(pos / (60 / self.track.bpm))
    local newBeat = (beat > self.beat)
    self.beat = math.max(beat, self.beat) -- avoid occasional backward steps in time
    local speed = self.track.bpm / 120
    for i, speedVars in ipairs(self.track.speeds) do
        low, high, mod = unpack(speedVars)
        if beat >= low and beat < high then
            speed = speed * mod
            break
        end
    end
    for i = #self.enemies, 1, -1 do -- update all enemies
        local enemy = self.enemies[i]
        enemy:update(dt * speed)
        if enemy.destroyTTL and enemy.destroyTTL < 0 then -- destroy animation finished
            table.remove(self.enemies, i)
        elseif enemy:visible() then
            for i, plr in ipairs(self.players) do
                if plr:overlaps(enemy) then -- player hit an enemy
                    plr:destroy()
                    for j, bullet in ipairs(self.bullets) do
                        if bullet.player == plr and not bullet.destroyTTL then -- don't restart existing animations
                            bullet:destroy()
                        end
                    end
                    soundHit:play()
                    return
                end
            end
        else -- moved outside window
            table.remove(self.enemies, i)
        end
    end
    for i, plr in ipairs(self.players) do
        if plr.destroyTTL then -- player respawning
            if plr.destroyTTL < 0 then
                plr.destroyTTL = nil
                plr.deaths = plr.deaths + 1
                return
            else
                plr:update(dt * speed)
            end
        end
    end
    for i = #self.bullets, 1, -1 do -- update all bullets
        local bullet = self.bullets[i]
        bullet:update(dt * speed)
        if bullet.destroyTTL and bullet.destroyTTL < 0 then -- destroy animation finished
            table.remove(self.bullets, i)
        elseif bullet:visible() then
            for j = #self.enemies, 1, -1 do
                local enemy = self.enemies[j]
                if not enemy.destroyTTL and bullet:overlaps(enemy) then -- bullet hit an enemy
                    table.remove(self.bullets, i)
                    enemy:destroy()
                    bullet.player.score = bullet.player.score + 1
                    soundBuzz:play()
                end
            end
        else -- moved outside window
            table.remove(self.bullets, i)
        end
    end
    if beat >= self.track.length then -- end of song
        if not self.ended then
            for i, enemy in ipairs(self.enemies) do
                enemy:destroy()
            end
            for i, bullet in ipairs(self.bullets) do
                bullet:destroy()
            end
            self.ended = true
        end
        return
    elseif newBeat then -- start of next beat, spawn an enemy
        table.insert(self.enemies, enemy(self.players))
    end
    for i, plr in ipairs(self.players) do
        local bullet = plr:update(dt * speed, newBeat) -- player update returns a new bullet if created
        if bullet then
            table.insert(self.bullets, bullet)
        end
    end
    self.bgColour = 320 * math.max(0, 0.1 - prog)
end

function game.draw(self)
    love.graphics.setBackgroundColor(self.bgColour, self.bgColour, self.bgColour)
    love.graphics.setColor(128, 128, 128)
    love.graphics.print(math.min(self.beat, self.track.length), 10, 10)
    love.graphics.print("Scores", 10, love.window.getHeight() - 30 - (15 * #self.players))
    love.graphics.printf("Deaths", love.window.getWidth() - 80, love.window.getHeight() - 30 - (15 * #self.players), 70, "right")
    for i, plr in ipairs(self.players) do
        plr:draw()
        love.graphics.print(plr.score, 10, love.window.getHeight() - 25 - (15 * (#self.players - i)))
        love.graphics.printf(plr.deaths, love.window.getWidth() - 30, love.window.getHeight() - 25 - (15 * (#self.players - i)), 20, "right")
    end
    for i, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
    for i, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
    if self.pause then
        love.graphics.setColor(0, 0, 0, 128)
        love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
        self.menuPause:draw(10, 10)
    end
end

function game.keypressed(self, key)
    if self.pause then
        self.menuPause:keypressed(key)
    elseif self.ended and (key == "escape" or key == "return") then
        self.music:stop()
        love.graphics.setBackgroundColor(0, 0, 0)
        self.stopped = true
    elseif key == "escape" then
        self.pause = true
        self.music:pause()
    end
end

function game.gamepadpressed(self, joystick, button)
    if self.pause then
        self.menuPause:gamepadpressed(button)
    elseif self.ended and button == "back" then
        self.music:stop()
        love.graphics.setBackgroundColor(0, 0, 0)
        self.stopped = true
    elseif button == "start" then
        self.pause = true
        self.music:pause()
    end
end

return game
