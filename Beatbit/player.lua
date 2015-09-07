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
        local move = dt * self.speed
        if self.joy == true then -- keyboard
            if love.keyboard.isDown("up") then
                self.y = self.y - move
            end
            if love.keyboard.isDown("down") then
                self.y = self.y + move
            end
            if love.keyboard.isDown("left") then
                self.x = self.x - move
            end
            if love.keyboard.isDown("right") then
                self.x = self.x + move
            end
        else
            local deadZone = 0.2 -- higher = larger offset needed
            local x = self.joy:getGamepadAxis("rightx")
            local y = self.joy:getGamepadAxis("righty")
            if math.abs(y) > deadZone then
                self.y = self.y + (move * (y - (deadZone * (y > 0 and 1 or -1)) * (1 + deadZone))) -- normalise [deadZone, 1] to [0, 1]
            end
            if math.abs(x) > deadZone then
                self.x = self.x + (move * (x - (deadZone * (x > 0 and 1 or -1)) * (1 + deadZone))) -- normalise [deadZone, 1] to [0, 1]
            end
        end
        self.x = math.max(self.size / 2, math.min(love.window.getWidth() - (self.size / 2), self.x))
        self.y = math.max(self.size / 2, math.min(love.window.getHeight() - (self.size / 2), self.y))
        if newBeat and not (dt == 0) then -- don't create bullets on pauses
            if self.joy == true then -- keyboard
                if love.keyboard.isDown("w") then
                    return bullet(self.x, self.y, "u", self)
                elseif love.keyboard.isDown("s") then
                    return bullet(self.x, self.y, "d", self)
                elseif love.keyboard.isDown("a") then
                    return bullet(self.x, self.y, "l", self)
                elseif love.keyboard.isDown("d") then
                    return bullet(self.x, self.y, "r", self)
                end
            else
                local hat = string.sub(self.joy:getHat(1), -1) -- last char of direction (prefer up/down on diagonals)
                if not (hat == "c") then
                    return bullet(self.x, self.y, hat, self)
                end
            end
        end
    end
end

return player
