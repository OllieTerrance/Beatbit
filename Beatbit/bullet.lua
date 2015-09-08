entity = require("entity")

local bullet = {}
bullet.__index = bullet

setmetatable(bullet, {
    __index = entity,
    __call = function(cls, x, y, direct, plr)
        local self = setmetatable({}, cls)
        self:new(x, y, direct, plr)
        return self
    end
})

function bullet.new(self, x, y, direct, plr)
    entity.new(self, "fill", plr.colour)
    self.x = x
    self.y = y
    self.size = 10
    self.speed = 200
    self.direct = direct
    self.player = plr
end

function bullet.update(self, dt)
    entity.update(self, dt)
    if not self.destroyTTL then
        if self.direct == "u" or self.direct == "d" then
            self.y = self.y + ((self.direct == "d" and 1 or -1) * dt * self.speed)
        else
            self.x = self.x + ((self.direct == "r" and 1 or -1) * dt * self.speed)
        end
    end
end

return bullet
