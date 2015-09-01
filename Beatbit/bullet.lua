return {
    new = function(self, sX, sY, sBearing)
        return {
            x = sX,
            y = sY,
            size = 2,
            speed = 250,
            bearing = sBearing,
            update = function(self, dt)
                if self.bearing == "n" or self.bearing == "s" then
                    self.y = self.y + ((self.bearing == "s" and 1 or -1) * dt * self.speed)
                else
                    self.x = self.x + ((self.bearing == "e" and 1 or -1) * dt * self.speed)
                end
                return self.x > (0 - self.size) and self.x < love.window.getWidth() and
                       self.y > (0 - self.size) and self.y < love.window.getHeight()
            end,
            draw = function(self)
                love.graphics.setColor(192, 224, 255)
                love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
            end
        }
    end
}
