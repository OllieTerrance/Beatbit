bullet = require("bullet")

return {
    new = function()
        return {
            x = math.random(0, love.window.getWidth()),
            y = math.random(0, love.window.getHeight()),
            size = 10,
            speed = 500,
            update = function(self, dt, newBeat)
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
                self.x = math.max(0, math.min(love.window.getWidth() - self.size, self.x))
                self.y = math.max(0, math.min(love.window.getHeight() - self.size, self.y))
                if newBeat then
                    if love.keyboard.isDown("w") then
                        return bullet:new(self.x, self.y, "n")
                    elseif love.keyboard.isDown("s") then
                        return bullet:new(self.x, self.y, "s")
                    elseif love.keyboard.isDown("a") then
                        return bullet:new(self.x, self.y, "w")
                    elseif love.keyboard.isDown("d") then
                        return bullet:new(self.x, self.y, "e")
                    end
                end
            end,
            draw = function(self)
                love.graphics.setColor(160, 192, 255)
                love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
            end
        }
    end
}
