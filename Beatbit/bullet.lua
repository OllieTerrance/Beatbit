entity = require("entity")

local bullet = {}
bullet.__index = bullet

setmetatable(bullet, {
    __index = entity,
    __call = function(cls, sX, sY, sBearing, plr)
        local self = setmetatable({}, cls)
        self:new(sX, sY, sBearing, plr)
        return self
    end
})

function bullet.new(self, sX, sY, sBearing, plr)
    entity.new(self, "fill", plr.colour)
    self.x = sX
    self.y = sY
    self.size = 10
    self.speed = 400
    self.bearing = sBearing
    self.player = plr
end

function bullet.update(self, dt)
    entity.update(self, dt)
    if not self.destroyTTL then
        if self.bearing == "n" or self.bearing == "s" then
            self.y = self.y + ((self.bearing == "s" and 1 or -1) * dt * self.speed)
        else
            self.x = self.x + ((self.bearing == "e" and 1 or -1) * dt * self.speed)
        end
    end
end

return bullet
