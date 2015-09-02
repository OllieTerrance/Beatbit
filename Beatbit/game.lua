player = require("player")
enemy = require("enemy")

local game = {}
game.__index = game

setmetatable(game, {
    __call = function(cls, track)
        local self = setmetatable({}, cls)
        self:new(track)
        return self
    end
})

function game.new(self, track)
    self.track = track
    self.music = love.audio.newSource("tracks/" .. self.track.dir .. "/" .. self.track.music)
    self.player = player()
    self.enemies = {}
    self.bullets = {}
    self.beat = 0
    self.bgColour = 0
    self.music:play()
end

function game.update(self, dt)
    local pos = self.music:tell() - self.track.start
    if pos < 0 then -- waiting for first beat
        return
    end
    local prog = pos % (60 / self.track.bpm) -- amount of time into the current beat
    local beat = math.floor(pos / (60 / self.track.bpm))
    local newBeat = (beat > self.beat)
    self.beat = beat
    local speed = 1
    for i, speedVars in ipairs(self.track.speeds) do
        low, high, mod = unpack(speedVars)
        if beat >= low and beat < high then
            speed = mod
            break
        end
    end
    for i = #self.enemies, 1, -1 do -- update all enemies
        local enemy = self.enemies[i]
        enemy:update(dt * speed)
        if enemy.destroyTTL and enemy.destroyTTL < 0 then -- destroy animation finished
            table.remove(self.enemies, i)
        elseif enemy:visible() then
            if self.player:overlaps(enemy) then -- player hit an enemy
                self.player:destroy()
                for j, bullet in ipairs(self.bullets) do
                    if not bullet.destroyTTL then -- don't restart existing animations
                        bullet:destroy()
                    end
                end
                return
            end
        else -- moved outside window
            table.remove(self.enemies, i)
        end
    end
    if self.player.destroyTTL then -- player respawning
        if self.player.destroyTTL < 0 then
            self.player = player(self.player.x, self.player.y)
            return
        else
            self.player:update(dt * speed)
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
            self.ended = true
        end
        return
    elseif newBeat then -- start of next beat, spawn an enemy
        table.insert(self.enemies, enemy(self.player.x, self.player.y))
    end
    local bullet = self.player:update(dt * speed, newBeat) -- player update returns a new bullet if created
    if bullet then
        table.insert(self.bullets, bullet)
    end
    self.bgColour = 320 * math.max(0, 0.1 - prog)
end

function game.draw(self)
    love.graphics.setBackgroundColor(self.bgColour, self.bgColour, self.bgColour)
    love.graphics.setColor(128, 128, 128)
    love.graphics.print(self.beat, 10, 10)
    self.player:draw()
    for i, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
    for i, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

function game.keypressed(self, key)
    if key == "escape" then
        self.music:stop()
        love.graphics.setBackgroundColor(0, 0, 0)
        self.stopped = true
    end
end

return game
