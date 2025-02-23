local Cell = {
    __name = "Cell",
    bg_color = colors.black,
    fg_color = colors.white,
    character = " ",
}

function Cell:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Cell:copy(other)
    self.bg_color = other.bg_color
    self.fg_color = other.fg_color
    self.character = other.character
end

return Cell