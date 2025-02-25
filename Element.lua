local Buffer = require("/apis/gui.Buffer")
local Cell = require("/apis/gui.Cell")

local Element = {
    __name = "Element",
    x = 0,
    y = 0,
    width = 1,
    height = 1,
    bg_color = colors.black,
    bg_transparent = false,

    buffer = Buffer,
    children = {},
}

function Element:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    o.buffer = Buffer:new {
        width = o.width,
        height = o.height,
    }
    o.children = {}

    return o
end

function Element:getSize()
    return self.width, self.height
end

function Element:setWidth(new_width)
    self.width = new_width
end

function Element:setHeight(new_height)
    self.height = new_height
end

function Element:getPos()
    return self.x, self.y
end

function Element:setPosX(new_x)
    self.x = new_x
end

function Element:setPosY(new_y)
    self.y = new_y
end

function Element:getBGColor()
    return self.bg_color
end

function Element:setBGColor(new_bg_color)
    self.bg_color = new_bg_color
end

function Element:addElement(element)
    table.insert(self.children, element)
end

function Element:updateBuffer()
    local default_cell = Cell:new { bg_color = self.bg_color }
    self.buffer:fill(default_cell)
end

return Element