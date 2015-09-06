local menu = {}
menu.__index = menu

local soundTick = love.audio.newSource("sound/tick.wav", "static")
local soundSelect = love.audio.newSource("sound/select.wav", "static")
local soundDeny = love.audio.newSource("sound/deny.wav", "static")

setmetatable(menu, {
    __call = function(cls, width, escape)
        local self = setmetatable({}, cls)
        self:new(width, escape)
        return self
    end
})

function menu.new(self, width, escape)
    self.items = {}
    self.selected = 1
    self.animOffset = 0
    self.width = width or 300
    self.escape = escape
end

function menu.add(self, item)
    table.insert(self.items, item)
end

function menu.update(self, dt)
    self.animOffset = self.animOffset / (1 + (dt * 50))
end

function menu.draw(self, x, y, active)
    local height = 20
    love.graphics.setColor(255, 255, 255, active and 128 or 64)
    love.graphics.rectangle("fill", x, y + (height * (self.selected - 1)) + (self.animOffset * height), self.width, height)
    for i, item in ipairs(self.items) do
        love.graphics.setColor(255, 255, 255, self.selected == i and (active and 255 or 192) or 128)
        love.graphics.print(item.label, x + 5, y + (height * (i - 1)) + 3)
    end
end

function menu.keypressed(self, key)
    if #self.items == 0 and (key == "up" or key == "down" or key == "right" or key == "return" or key == " ") then
        soundDeny:play()
    elseif key == "up" then
        self.animOffset = self.animOffset + (self.selected > 1 and 1 or (1 - #self.items))
        self.selected = ((self.selected - 2) % #self.items) + 1
        soundTick:play()
    elseif key == "down" then
        self.animOffset = self.animOffset - (self.selected < #self.items and 1 or (1 - #self.items))
        self.selected = (self.selected % #self.items) + 1
        soundTick:play()
    elseif key == "right" or key == "return" or key == " " then
        if self.items[self.selected].action then
            self.items[self.selected].action()
            soundSelect:play()
        end
    elseif self.escape and (key == "left" or key == "backspace" or key == "escape") then
        self.selected = 1
        soundSelect:play()
        self.escape()
    end
end

return menu
