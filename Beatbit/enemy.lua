return {
    new = function()
        return {
            x = math.random(0, love.window.getWidth()),
            y = math.random(0, love.window.getHeight()),
            size = math.random(5, 50),
            xSpeed = math.random(-50, 50),
            ySpeed = math.random(-50, 50),
            update = function(self, dt)
                self.x = self.x + (dt * self.xSpeed)
                self.y = self.y + (dt * self.ySpeed)
                return self.x > (0 - self.size) and self.x < love.window.getWidth() and
                       self.y > (0 - self.size) and self.y < love.window.getHeight()
            end,
            draw = function(self)
                love.graphics.setColor(160, 192, 255)
                love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
            end
        }
    end
}
