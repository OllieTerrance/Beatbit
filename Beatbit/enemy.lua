entity = require("entity")

local enemy = {}
enemy.__index = enemy

setmetatable(enemy, {
    __index = entity,
    __call = function(cls, pX, pY)
        local self = setmetatable({}, cls)
        self:new(pX, pY)
        return self
    end
})

function enemy.new(self, pX, pY)
    entity.new(self, "line", {192, 192, 192})
    local sX = math.random(0, love.window.getWidth())
    local sY = math.random(0, love.window.getHeight())
    while math.abs(sX - pX) < 50 and math.abs(sY - pY) < 50 do -- too close to player
        sX = math.random(0, love.window.getWidth())
        sY = math.random(0, love.window.getHeight())
    end
    self.x = sX
    self.y = sY
    self.size = math.random(20, 60)
    self.xSpeed = math.random(-50, 50)
    self.ySpeed = math.random(-50, 50)
end

function enemy.update(self, dt)
    self.x = self.x + (dt * self.xSpeed)
    self.y = self.y + (dt * self.ySpeed)
    return self.x > - (self.size / 2) and self.x < love.window.getWidth() + (self.size / 2) and
           self.y > - (self.size / 2) and self.y < love.window.getHeight() + (self.size / 2)
end

return enemy
