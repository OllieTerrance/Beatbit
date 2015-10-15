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

function game.setChange(self, change)
    self.bpm = change.bpm or self.bpm
    self.speed = (change.speed and ((self.bpm * change.speed) / 60) or self.speed)
    if change.pattern then
        self.pattern = {
            beats = (change.pattern and change.pattern or {0}),
            loop = (change.loop and change.loop or (math.floor(change.pattern[#change.pattern]) + 1)), -- default to next integer beat after last note
            ptr = 1,
            count = 0,
            last = false
        }
    end
end

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
    self:setChange(track.changes[1])
    self.speed = self.speed or (self.bpm / 60)
    self.changeAt = 1
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
            self.speed = nil
            self:setChange(track.changes[1])
            self.speed = self.speed or (self.bpm / 60)
            self.bgColour = 0
            self.music:rewind()
            self.pause = false
            self.menuPause.selected = 1
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
    local changeAt = 1
    for i, at in ipairs(self.track.changeAts) do
        if at <= self.beat then
            changeAt = self.track.changeMap[at]
        else -- gone too far, stop looking (and take previous value)
            break
        end
    end
    if not (changeAt == self.changeAt) then
        self:setChange(self.track.changes[changeAt])
        self.changeAt = changeAt
    end
    local newBeat = self.beat + ((dt * self.bpm) / 60)
    self.beat = math.max(newBeat, self.beat) -- avoid occasional backward steps in time
    local onBeat = false
    if #self.pattern.beats then
        local patternCount = math.floor(self.beat / self.pattern.loop)
        if patternCount > self.pattern.count then -- new iteration of pattern, stop blocking
            self.pattern.count = patternCount
            self.pattern.last = false
        end
        if not self.pattern.last and (self.beat % self.pattern.loop) > self.pattern.beats[self.pattern.ptr] then -- hit next beat in pattern
            onBeat = true
            self.pattern.ptr = (self.pattern.ptr % #self.pattern.beats) + 1
            if self.pattern.ptr == 1 then -- last beat in pattern, block until next iteration
                self.pattern.last = true
            end
        end
    end
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        enemy:update(dt * self.speed)
        if enemy.destroyTTL and enemy.destroyTTL < 0 then -- destroy animation finished
            table.remove(self.enemies, i)
        elseif enemy:visible() then
            for i, plr in ipairs(self.players) do
                if not plr.respawnTTL and plr:overlaps(enemy) then -- player hit an enemy
                    plr:destroy()
                    plr.deaths = plr.deaths + 1
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
        if plr.destroyTTL then -- player destroy animation playing
            if plr.destroyTTL < 0 then
                plr.destroyTTL = nil
                return
            else
                plr:update(dt * self.speed)
            end
        end
    end
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:update(dt * self.speed)
        if bullet.destroyTTL and bullet.destroyTTL < 0 then -- destroy animation finished
            table.remove(self.bullets, i)
        elseif bullet:visible() then
            for j = #self.enemies, 1, -1 do
                local enemy = self.enemies[j]
                if not enemy.destroyTTL and bullet:overlaps(enemy) then -- bullet hit an enemy
                    table.remove(self.bullets, i)
                    enemy:destroy()
                    bullet.player.hits = bullet.player.hits + 1
                    bullet.player.score = bullet.player.score + 50 - math.floor(enemy.size / 2) -- size 20 = score 50, size 100 = score 10
                    soundBuzz:play()
                end
            end
        else -- moved outside window
            table.remove(self.bullets, i)
        end
    end
    if self.beat >= self.track.length then -- end of song
        if not self.ended then
            for i, plr in ipairs(self.players) do
                plr:destroy()
                plr.respawnTTL = nil
            end
            for i, enemy in ipairs(self.enemies) do
                enemy:destroy()
            end
            for i, bullet in ipairs(self.bullets) do
                bullet:destroy()
            end
            self.ended = true
        end
        return
    elseif onBeat then -- start of next beat, spawn an enemy
        table.insert(self.enemies, enemy(self.players))
    end
    for i, plr in ipairs(self.players) do
        local bullet = plr:update(dt * self.speed, onBeat) -- player update returns a new bullet if created
        if bullet then
            plr.shots = plr.shots + 1
            table.insert(self.bullets, bullet)
        end
    end
    self.bgColour = 320 * math.max(0, 0.1 - (self.beat % 1))
end

function game.draw(self)
    love.graphics.setBackgroundColor(self.bgColour, self.bgColour, self.bgColour)
    love.graphics.setColor(128, 128, 128)
    for i, plr in ipairs(self.players) do
        if not self.ended or plr.destroyTTL then -- don't draw at game over after destroy
            plr:draw()
        end
    end
    for i, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
    for i, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
    love.graphics.setColor(128, 128, 128)
    if self.ended then
        love.graphics.print("Scores", 10, 10)
        love.graphics.print("Deaths", 60, 10)
        love.graphics.print("Accuracy", 115, 10)
        for i, plr in ipairs(self.players) do
            love.graphics.setColor(plr.colour)
            love.graphics.print(plr.score, 10, 12 + (15 * i))
            love.graphics.print(plr.deaths, 60, 12 + (15 * i))
            local accuracy = (100 * (plr.hits / plr.shots)) + 0.5
            love.graphics.print(math.floor(accuracy) .. "% (" .. plr.hits .. " / " .. plr.shots .. ")", 115, 12 + (15 * i))
        end
    else
        love.graphics.print(math.floor(math.min(self.beat, self.track.length)), 10, 10)
        love.graphics.print("Scores", 10, love.window.getHeight() - 30 - (15 * #self.players))
        love.graphics.printf("Deaths", love.window.getWidth() - 80, love.window.getHeight() - 30 - (15 * #self.players), 70, "right")
        for i, plr in ipairs(self.players) do
            local colour = plr.colour
            if plr.respawnTTL then
                colour = {}
                for i, val in ipairs(plr.colour) do
                    table.insert(colour, val / 3)
                end
            end
            love.graphics.setColor(colour)
            love.graphics.print(plr.score, 10, love.window.getHeight() - 25 - (15 * (#self.players - i)))
            love.graphics.printf(plr.deaths, love.window.getWidth() - 30, love.window.getHeight() - 25 - (15 * (#self.players - i)), 20, "right")
        end
        if self.pause then
            love.graphics.setColor(0, 0, 0, 128)
            love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
            self.menuPause:draw(10, 10)
        end
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
    elseif key == "=" then
        local add = self.pattern.loop
        for i, at in ipairs(self.track.changeAts) do
            if self.beat < at and (self.beat + 4) >= at then -- don't skip across changes
                add = at - self.beat
                self.beat = at
                break
            end
        end
        self.music:seek(self.music:tell() + ((60 / self.bpm) * add))
        if add == self.pattern.loop then
            self.beat = self.beat + add
        end
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
