local Cell = require("/apis/gui.Cell")

local Buffer = {
    __name = "Buffer",
    width = 1,
    height = 1,
    cells = {},
}

function Buffer:new(o)
    o = o or {}

    -- set new object to inherit from prototype
    setmetatable(o, self)
    self.__index = self

    o.cells = {}
    o:initializeCells()

    return o
end

function Buffer:initializeCells()
    local cell

    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            cell = Cell:new()
            if not self.cells[x] then
                table.insert(self.cells, x, {[y] = cell})
            else
                table.insert(self.cells[x], y, cell)
            end
        end
    end
end

function Buffer:fill(cell)
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            self.cells[x][y]:copy(cell)
        end
    end
end

function Buffer:clear()
    self:fill(Cell)
end

return Buffer