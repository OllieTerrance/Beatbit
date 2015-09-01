return {
    new = function()
        return {
            x = math.random(0, love.window.getWidth()),
            y = math.random(0, love.window.getHeight()),
            size = math.random(20, 60),
            xSpeed = math.random(-50, 50),
            ySpeed = math.random(-50, 50),
            update = function(self, dt)
                self.x = self.x + (dt * self.xSpeed)
                self.y = self.y + (dt * self.ySpeed)
                return self.x > - (self.size / 2) and self.x < love.window.getWidth() + (self.size / 2) and
                       self.y > - (self.size / 2) and self.y < love.window.getHeight() + (self.size / 2)
            end,
            draw = function(self)
                love.graphics.setColor(160, 192, 255)
                love.graphics.rectangle("line", self.x - (self.size / 2), self.y - (self.size / 2), self.size, self.size)
            end
        }
    end
}
