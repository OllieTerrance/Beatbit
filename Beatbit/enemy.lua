entity = require("entity")

local enemy = {}
enemy.__index = enemy

setmetatable(enemy, {
    __index = entity,
    __call = function(cls, players)
        local self = setmetatable({}, cls)
        self:new(players)
        return self
    end
})

function enemy.new(self, players)
    entity.new(self, "line", {192, 192, 192})
    self.size = math.random(20, 60)
    local sX, sY
    local tooClose = true
    while tooClose do
        tooClose = false
        sX = math.random(0, love.window.getWidth())
        sY = math.random(0, love.window.getHeight())
        for i, plr in ipairs(players) do
            if math.abs(sX - plr.x) < self.size + 10 and math.abs(sY - plr.y) < self.size + 10 then
                tooClose = true
                break
            end
        end
    end
    self.x = sX
    self.y = sY
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
