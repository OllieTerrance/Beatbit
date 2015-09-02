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
    self.xSpeed = (math.random() + 0.05) * 75 * (math.random(2) - 1.5)
    self.ySpeed = (math.random() + 0.05) * 75 * (math.random(2) - 1.5)
end

function enemy.update(self, dt)
    entity.update(self, dt)
    if not self.destroyTTL then
        self.x = self.x + (dt * self.xSpeed)
        self.y = self.y + (dt * self.ySpeed)
   end
end

return enemy
