entity = require("entity")
bullet = require("bullet")

local player = {}
player.__index = player

setmetatable(player, {
    __index = entity,
    __call = function(cls, x, y)
        local self = setmetatable({}, cls)
        self:new(x, y)
        return self
    end
})

function player.new(self, x, y)
    entity.new(self, "fill", {128, 192, 255})
    self.x = x or math.random(0, love.window.getWidth())
    self.y = y or math.random(0, love.window.getHeight())
    self.size = 20
    self.speed = 400
    self.score = 0
    self.deaths = 0
end

function player.update(self, dt, newBeat)
    entity.update(self, dt)
    if not self.destroyTTL then
        if love.keyboard.isDown("up") then
            self.y = self.y - (dt * self.speed)
        end
        if love.keyboard.isDown("down") then
            self.y = self.y + (dt * self.speed)
        end
        if love.keyboard.isDown("left") then
            self.x = self.x - (dt * self.speed)
        end
        if love.keyboard.isDown("right") then
            self.x = self.x + (dt * self.speed)
        end
        self.x = math.max(self.size / 2, math.min(love.window.getWidth() - (self.size / 2), self.x))
        self.y = math.max(self.size / 2, math.min(love.window.getHeight() - (self.size / 2), self.y))
        if newBeat and not (dt == 0) then -- don't create bullets on pauses
            if love.keyboard.isDown("w") then
                return bullet(self.x, self.y, "n", self)
            elseif love.keyboard.isDown("s") then
                return bullet(self.x, self.y, "s", self)
            elseif love.keyboard.isDown("a") then
                return bullet(self.x, self.y, "w", self)
            elseif love.keyboard.isDown("d") then
                return bullet(self.x, self.y, "e", self)
            end
        end
    end
end

return player
