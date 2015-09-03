local entity = {}
entity.__index = entity

setmetatable(entity, {
    __call = function(cls)
        local self = setmetatable({}, cls)
        self:new()
        return self
    end
})

function entity.new(self, drawMode, colour)
    self.drawMode = drawMode
    self.colour = colour
end

function entity.visible(self)
    return self.x > - (self.size / 2) and self.x < love.window.getWidth() + (self.size / 2) and
           self.y > - (self.size / 2) and self.y < love.window.getHeight() + (self.size / 2)
end

function entity.overlaps(self, other)
    return (not self.destroyTTL) and (not other.destroyTTL) and
           self.x - (self.size / 2) < other.x + (other.size / 2) and self.y - (self.size / 2) < other.y + (other.size / 2) and
           other.x - (other.size / 2) < self.x + (self.size / 2) and other.y - (other.size / 2) < self.y + (self.size / 2)
end

function entity.update(self, dt)
    if self.destroyTTL then
        self.destroyTTL = self.destroyTTL - math.abs(dt) -- don't play animation backwards
    end
end

function entity.destroy(self)
    self.destroyTTL = 1
    self.destroyPoints = {}
    for i = 1, 10 do
        table.insert(self.destroyPoints, {math.random() * math.pi * 2, math.random(3, 5)})
    end
end

function entity.draw(self)
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
        love.graphics.setColor(unpack(self.colour))
        love.graphics.rectangle(self.drawMode, self.x - (self.size / 2), self.y - (self.size / 2), self.size, self.size)
    end
end

return entity
