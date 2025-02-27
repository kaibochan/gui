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

function Buffer:point(x, y, cell)
    if self:inBounds(x, y) then
        self.cells[x][y]:copy(cell)
    end
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
            self:point(x, y, cell)
        end
    end
end

function Buffer:line(x_1, y_1, x_2, y_2, cell)
    local points = {
        { x = x_1, y = y_1 },
        { x = x_2, y = y_2 },
    }
    local i_start, i_end

    if x_1 <= x_2 then
        i_start = 1
        i_end = 2
    else
        i_start = 2
        i_end = 1
    end

    local delta_x = points[i_end].x - points[i_start].x
    local delta_y = points[i_end].y - points[i_start].y

    local loss = function(x, y)
        return math.abs(x * delta_y - y * delta_x
            + (y_1 * delta_x - x_1 * delta_y))
    end

    local x = points[i_start].x
    local y = points[i_start].y

    while x ~= points[i_end].x or y ~= points[i_end].y do
        self:point(x, y, cell)

        local adj_cells
        if delta_y > 0 then
            adj_cells = {
                { x = x + 1, y = y     },
                { x = x + 1, y = y + 1 },
                { x = x    , y = y + 1 },
            }
        else
            adj_cells = {
                { x = x    , y = y - 1 },
                { x = x + 1, y = y - 1 },
                { x = x + 1, y = y     },
            }    
        end

        local i_min_loss = 1
        local min_loss = loss(adj_cells[1].x, adj_cells[1].y)
        for i, cell in ipairs(adj_cells) do
            local current_loss = loss(cell.x, cell.y)

            if current_loss < min_loss then
                
                    i_min_loss = i
                min_loss = current_loss
            end
        end
        
        x = adj_cells[i_min_loss].x
        y = adj_cells[i_min_loss].y
    end
end

function Buffer:inBounds(x, y)
    return (x >= 0 and x < self.width and y >= 0 and y < self.height)
end

function Buffer:clear()
    self:fill(Cell)
end

return Buffer