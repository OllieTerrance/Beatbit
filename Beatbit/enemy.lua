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
    self.size = math.random(20, 80)
    local x, y
    local tooClose = true
    while tooClose do
        tooClose = false
        x = math.random(0, love.window.getWidth())
        y = math.random(0, love.window.getHeight())
        for i, plr in ipairs(players) do
            if math.abs(x - plr.x) < self.size + 10 and math.abs(y - plr.y) < self.size + 10 then
                tooClose = true
                break
            end
        end
    end
    self.x = x
    self.y = y
    self.xSpeed = (math.random() + 0.05) * 50 * (math.random(2) - 1.5)
    self.ySpeed = (math.random() + 0.05) * 50 * (math.random(2) - 1.5)
end

function enemy.update(self, dt)
    entity.update(self, dt)
    if not self.destroyTTL then
        self.x = self.x + (dt * self.xSpeed)
        self.y = self.y + (dt * self.ySpeed)
   end
end

return enemy
