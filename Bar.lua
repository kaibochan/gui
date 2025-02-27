local Element = require("/apis/gui.Element")
local Utils = require("/apis/gui.Utils")

local Bar = Element:new {
    percent_filled = 0,
    fill_color = colors.green,
    orientation = {
        horizontal = "horizontal",
        vertical = "vertical",
    },
}

function Bar:new(o)
    o = o or {}
    o = Element:new(o)

    o.orientation = o.orientation or Bar.orientation.horizontal

    setmetatable(o, self)
    self.__index = self

    return o
end

function Bar:updateBuffer()
    Element.updateBuffer(self)

    local getPercentage
    if self.orientation == Bar.orientation.horizontal then
        getPercentage = function (x, y)
            return (x + 1) / self.width
        end
    elseif self.orientation == Bar.orientation.vertical then
        getPercentage = function (x, y)
            return (y + 1) / self.height
        end
    end

    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            local percentage = getPercentage(x, y)
            if percentage <= self.percent_filled then
                self.buffer.cells[x][y].bg_color = self.fill_color
            end
        end
    end
end

return Bar