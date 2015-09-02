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

function entity.draw(self)
    love.graphics.setColor(unpack(self.colour))
    love.graphics.rectangle(self.drawMode, self.x - (self.size / 2), self.y - (self.size / 2), self.size, self.size)
end

function entity.visible(self)
    return self.x > - (self.size / 2) and self.x < love.window.getWidth() + (self.size / 2) and
           self.y > - (self.size / 2) and self.y < love.window.getHeight() + (self.size / 2)
end

function entity.overlaps(self, other)
    return self.x - (self.size / 2) < other.x + (other.size / 2) and self.y - (self.size / 2) < other.y + (other.size / 2) and
           other.x - (other.size / 2) < self.x + (self.size / 2) and other.y - (other.size / 2) < self.y + (self.size / 2)
end

return entity
