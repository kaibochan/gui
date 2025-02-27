local Cell = require("/apis/gui.Cell")

-- Read only prototype to reduce nil checking in Buffer.cells
-- local CellRow = {
--     new = function()
--         local cell_row = {}

--         setmetatable(cell_row, {
--             __index = Cell
--         })

--         return cell_row
--     end
-- }
-- setmetatable(CellRow, {
--     __newindex = function (t, k, v)
--         return
--     end,
-- })

local Buffer = {
    __name = "Buffer",
    width = 1,
    height = 1,
    cells = {},
}

function Buffer:new(o)
    o = o or {}

    o.cells = o.cells or {}

    setmetatable(o, self)
    self.__index = self

    o:initializeCells()

    return o
end

function Buffer:initializeCells()
    local cell

    -- for x = 0, self.width - 1 do
    --     table.insert(self.cells, x, CellRow.new())
    --     for y = 0, self.height - 1 do
    --         rawset(self.cells[x], y, cell)
    --         print(self.cells[x][y])
    --     end
    -- end

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

function Buffer:point(x, y)
    
end

function Buffer:fill(cell)
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            self.cells[x][y]:copy(cell)
        end
    end
end

function Buffer:fillRect(x_1, y_1, x_2, y_2, cell)
    for x = x_1, x_2 do
        for y = y_1, y_2 do
            if self:inBounds(x, y) then
                self.cells[x][y]:copy(cell)
            end
        end
    end
end

function Buffer:line(x_1, y_1, x_2, y_2, cell)

end

function Buffer:inBounds(x, y)
    return (x >= 0 and x < self.width and y >= 0 and y < self.height)
end

function Buffer:clear()
    self:fill(Cell)
end

return Buffer