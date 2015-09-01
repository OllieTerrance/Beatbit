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

return entity
