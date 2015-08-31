size = 10
speed = 500

return {
    new = function()
        return {
            x = 0,
            y = 0,
            update = function(self, dt)
                if love.keyboard.isDown("up") then
                    self.y = self.y - (dt * speed)
                end
                if love.keyboard.isDown("down") then
                    self.y = self.y + (dt * speed)
                end
                if love.keyboard.isDown("left") then
                    self.x = self.x - (dt * speed)
                end
                if love.keyboard.isDown("right") then
                    self.x = self.x + (dt * speed)
                end
                self.x = math.max(0, math.min(love.window.getWidth() - size, self.x))
                self.y = math.max(0, math.min(love.window.getHeight() - size, self.y))
            end,
            draw = function(self)
                love.graphics.setColor(160, 192, 255)
                love.graphics.rectangle("fill", self.x, self.y, size, size)
            end
        }
    end
}
