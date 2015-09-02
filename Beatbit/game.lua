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
    local beat = math.floor(pos / (60 / self.track.bpm))
    local newBeat = false
    if beat > self.beat then -- start of next beat
        table.insert(self.enemies, enemy(self.player.x, self.player.y))
        self.beat = beat
        newBeat = true
    end
    local prog = pos % (60 / self.track.bpm) -- amount of time into the current beat
    self.bgColour = 320 * math.max(0, 0.1 - prog)
    for i = #self.bullets, 1, -1 do -- iterate in reverse
        local bullet = self.bullets[i]
        bullet:update(dt)
        if bullet:visible() then
            for j = #self.enemies, 1, -1 do -- iterate in reverse
                local enemy = self.enemies[j]
                if not enemy.destroyTTL and bullet:overlaps(enemy) then
                    table.remove(self.bullets, i)
                    enemy:destroy()
                end
            end
        else -- moved outside window
            table.remove(self.bullets, i)
        end
    end
    local bullet = self.player:update(dt, newBeat)
    if bullet then
        table.insert(self.bullets, bullet)
    end
    for i = #self.enemies, 1, -1 do -- iterate in reverse
        local enemy = self.enemies[i]
        enemy:update(dt)
        if enemy.destroyTTL and enemy.destroyTTL < 0 then
            table.remove(self.enemies, i)
        elseif enemy:visible() then
            if not enemy.destroyTTL and self.player:overlaps(enemy) then
                self.music:stop()
                love.graphics.setBackgroundColor(0, 0, 0)
                self.stopped = true
                return
            end
        else -- moved outside window
            table.remove(self.enemies, i)
        end
    end
end

function game.draw(self)
    love.graphics.setBackgroundColor(self.bgColour, self.bgColour, self.bgColour)
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
