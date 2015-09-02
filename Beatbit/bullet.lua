entity = require("entity")

local bullet = {}
bullet.__index = bullet

setmetatable(bullet, {
    __index = entity,
    __call = function(cls, sX, sY, sBearing)
        local self = setmetatable({}, cls)
        self:new(sX, sY, sBearing)
        return self
    end
})

function bullet.new(self, sX, sY, sBearing)
    entity.new(self, "fill", {192, 224, 255})
    self.x = sX
    self.y = sY
    self.size = 10
    self.speed = 400
    self.bearing = sBearing
end

function bullet.update(self, dt)
    entity.update(self, dt)
    if self.bearing == "n" or self.bearing == "s" then
        self.y = self.y + ((self.bearing == "s" and 1 or -1) * dt * self.speed)
    else
        self.x = self.x + ((self.bearing == "e" and 1 or -1) * dt * self.speed)
    end
end

return bullet
