return {
    new = function()
        return {
            items = {},
            selected = 1,
            animOffset = 0,
            add = function(self, item)
                table.insert(self.items, item)
            end,
            update = function(self, dt)
                self.animOffset = self.animOffset / (1 + (dt * 50))
            end,
            draw = function(self, x, y)
                local height = 20
                local width = 300
                love.graphics.rectangle("fill", x, y + (height * (self.selected - 1)) + (self.animOffset * height), width, height)
                for i, item in ipairs(self.items) do
                    love.graphics.setColor(255, 255, 255, self.selected == i and 255 or 128)
                    love.graphics.print(item.label, x + 5, y + (height * (i - 1)) + 3)
                end
                love.graphics.setColor(255, 255, 255, 128)
            end,
            keypressed = function(self, key)
                if key == "up" then
                    self.animOffset = self.animOffset + (self.selected > 1 and 1 or (1 - #self.items))
                    self.selected = ((self.selected - 2) % #self.items) + 1
                elseif key == "down" then
                    self.animOffset = self.animOffset - (self.selected < #self.items and 1 or (1 - #self.items))
                    self.selected = (self.selected % #self.items) + 1
                elseif key == "return" then
                    if self.items[self.selected].action then
                        self.items[self.selected]:action()
                    end
                end
            end
        }
    end
}
