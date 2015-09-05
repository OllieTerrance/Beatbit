entity = require("entity")
bullet = require("bullet")

local player = {}
player.__index = player

setmetatable(player, {
    __index = entity,
    __call = function(cls, joy, player)
        local self = setmetatable({}, cls)
        self:new(joy, player)
        return self
    end
})

function player.new(self, joy, colour)
    entity.new(self, "fill", colour)
    self.joy = joy
    self.x = math.random(0, love.window.getWidth())
    self.y = math.random(0, love.window.getHeight())
    self.size = 20
    self.speed = 400
    self.score = 0
    self.deaths = 0
end

function player.update(self, dt, newBeat)
    entity.update(self, dt)
    if not self.destroyTTL then
        if self.joy == true then -- keyboard
            if love.keyboard.isDown("up") then
                self.y = self.y - (dt * self.speed)
            end
            if love.keyboard.isDown("down") then
                self.y = self.y + (dt * self.speed)
            end
            if love.keyboard.isDown("left") then
                self.x = self.x - (dt * self.speed)
            end
            if love.keyboard.isDown("right") then
                self.x = self.x + (dt * self.speed)
            end
        else
            local sensitivity = 0.3 -- higher = larger offset needed
            if self.joy:getGamepadAxis("righty") < - sensitivity then
                self.y = self.y - (dt * self.speed)
            elseif self.joy:getGamepadAxis("righty") > sensitivity then
                self.y = self.y + (dt * self.speed)
            end
            if self.joy:getGamepadAxis("rightx") < - sensitivity then
                self.x = self.x - (dt * self.speed)
            elseif self.joy:getGamepadAxis("rightx") > sensitivity then
                self.x = self.x + (dt * self.speed)
            end
        end
        self.x = math.max(self.size / 2, math.min(love.window.getWidth() - (self.size / 2), self.x))
        self.y = math.max(self.size / 2, math.min(love.window.getHeight() - (self.size / 2), self.y))
        if newBeat and not (dt == 0) then -- don't create bullets on pauses
            if self.joy == true then -- keyboard
                if love.keyboard.isDown("w") then
                    return bullet(self.x, self.y, "n", self)
                elseif love.keyboard.isDown("s") then
                    return bullet(self.x, self.y, "s", self)
                elseif love.keyboard.isDown("a") then
                    return bullet(self.x, self.y, "w", self)
                elseif love.keyboard.isDown("d") then
                    return bullet(self.x, self.y, "e", self)
                end
            else
                local hat = self.joy:getHat(1)
                if hat == "u" then
                    return bullet(self.x, self.y, "n", self)
                elseif hat == "d" then
                    return bullet(self.x, self.y, "s", self)
                elseif hat == "l" then
                    return bullet(self.x, self.y, "w", self)
                elseif hat == "r" then
                    return bullet(self.x, self.y, "e", self)
                end
            end
        end
    end
end

return player
