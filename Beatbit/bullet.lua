bullet = {}
bullet_mt = {__index = bullet}

function bullet.new(sX, sY, sBearing)
    local inst = {
        x = sX,
        y = sY,
        size = 10,
        speed = 400,
        bearing = sBearing
    }
    setmetatable(inst, bullet_mt)
    return inst
end

function bullet.update(self, dt)
    if self.bearing == "n" or self.bearing == "s" then
        self.y = self.y + ((self.bearing == "s" and 1 or -1) * dt * self.speed)
    else
        self.x = self.x + ((self.bearing == "e" and 1 or -1) * dt * self.speed)
    end
    return self.x > - (self.size / 2) and self.x < love.window.getWidth() + (self.size / 2) and
           self.y > - (self.size / 2) and self.y < love.window.getHeight() + (self.size / 2)
end

function bullet.draw(self)
    love.graphics.setColor(192, 224, 255)
    love.graphics.rectangle("fill", self.x - (self.size / 2), self.y - (self.size / 2), self.size, self.size)
end

return bullet
