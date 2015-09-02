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
    if self.destroyTTL then
        self.destroyTTL = self.destroyTTL - dt
    else
        self.x = self.x + (dt * self.xSpeed)
        self.y = self.y + (dt * self.ySpeed)
   end
end

function enemy.destroy(self)
    self.destroyTTL = 1
    self.destroyPoints = {}
    for i = 1, 10 do
        table.insert(self.destroyPoints, {math.random() * math.pi * 2, math.random(3, 5)})
    end
end

function enemy.draw(self)
    if self.destroyTTL then
        for i, point in ipairs(self.destroyPoints) do
            rad, size = unpack(point)
            local x = math.cos(rad) * self.size * (4 - (self.destroyTTL * 3)) / 2
            local y = math.sin(rad) * self.size * (4 - (self.destroyTTL * 3)) / 2
            local colour = {}
            for i = 1, 3 do
                table.insert(colour, self.colour[i] * self.destroyTTL) -- fade to black
            end
            love.graphics.setColor(unpack(colour))
            love.graphics.rectangle(self.drawMode, self.x + x - 1, self.y + y - 1, size, size)
        end
    else
        entity.draw(self)
    end
end

return enemy
