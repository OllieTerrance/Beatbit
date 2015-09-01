enemy = {}
enemy_mt = {__index = enemy}

function enemy.new(pX, pY)
    local sX = math.random(0, love.window.getWidth())
    local sY = math.random(0, love.window.getHeight())
    while math.abs(sX - pX) < 50 and math.abs(sY - pY) < 50 do -- too close to player
        sX = math.random(0, love.window.getWidth())
        sY = math.random(0, love.window.getHeight())
    end
    inst = {
        x = sX,
        y = sY,
        size = math.random(20, 60),
        xSpeed = math.random(-50, 50),
        ySpeed = math.random(-50, 50)
    }
    setmetatable(inst, enemy_mt)
    return inst
end

function enemy.update(self, dt)
    self.x = self.x + (dt * self.xSpeed)
    self.y = self.y + (dt * self.ySpeed)
    return self.x > - (self.size / 2) and self.x < love.window.getWidth() + (self.size / 2) and
           self.y > - (self.size / 2) and self.y < love.window.getHeight() + (self.size / 2)
end

function enemy.draw(self)
    love.graphics.setColor(160, 192, 255)
    love.graphics.rectangle("line", self.x - (self.size / 2), self.y - (self.size / 2), self.size, self.size)
end

return enemy
