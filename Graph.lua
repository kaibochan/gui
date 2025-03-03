local Element = require("/apis/gui.Element")
local Cell = require("/apis/gui.Cell")
local DataSet = require("/apis/gui.DataSet")

local Graph = Element:new {
    data_sets = {},

    u_min = 0,
    u_max = 1,
    v_min = 0,
    v_max = 1,
    draw_axes = false,
    type = {
        bar = "bar",
        line = "line",
        scatter = "scatter"
    }
}

function Graph:new(o)
    o = o or {}
    o = Element:new(o)

    o.type = o.type or Graph.type.bar
    o.data_sets = o.data_sets or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function Graph:attachDataSet(data_set)
    table.insert(self.data_sets, data_set)
end

function Graph:pollDataSets()
    for _, data_set in ipairs(self.data_sets) do
        data_set:poll()
    end
end

function Graph:updateBuffer()
    Element.updateBuffer(self)

    local u_span = (self.u_max - self.u_min)
    local v_span = (self.v_max - self.v_min)

    local function normU(u)
        return (u - self.u_min) / u_span
    end
    local function normV(v)
        return (v - self.v_min) / v_span
    end

    local function round(val)
        return math.floor(val + 0.5)
    end

    local x_u0 = round(normU(0) * self.width)
    local y_v0 = round((1 - normV(0)) * self.height)

    if self.draw_axes then
        local axis_color = colors.gray
        local axis_cell = Cell:new { bg_color = axis_color}

        self.buffer:line(x_u0, 0, x_u0, self.height - 1, axis_cell)
        self.buffer:line(0, y_v0, self.width - 1, y_v0, axis_cell)

        -- if x_u0 >= 0 and x_u0 < self.width then
        --     for y = 0, self.height - 1 do
        --         self.buffer.cells[x_u0][y].bg_color = colors.lightGray
        --     end
        -- end

        -- if y_v0 >= 0 and y_v0 < self.height then
        --     for x = 0, self.width - 1 do
        --         self.buffer.cells[x][y_v0].bg_color = colors.lightGray
        --     end
        -- end
    end
    
    local delta_u = self.width / u_span
    local delta_v = self.height / v_span

    -- local cols = {
    --     colors.red,
    --     colors.orange,
    --     colors.lime,
    --     colors.cyan,
    --     colors.purple,
    -- }

    for _, data_set in ipairs(self.data_sets) do
        local cell = Cell:new { bg_color = data_set.data_color }

        for i, point in ipairs(data_set.data) do
            local x_u = round(normU(point.u) * self.width)
            local y_v = round((1 - normV(point.v)) * self.height)

            if self.type == Graph.type.scatter then
                self.buffer:point(x_u, y_v, cell)
            elseif self.type == Graph.type.bar then
                local max_x = math.min((normU(point.u) * self.width) + delta_u - 0.5, self.width - 1)
                local min_y = math.max(math.min(y_v, y_v0), 0)
                local max_y = math.min(math.max(y_v, y_v0), self.height - 1)

                self.buffer:fillRect(x_u, min_y, max_x, max_y, cell)
            elseif self.type == Graph.type.line then
                if data_set.data[i + 1] then
                    local x_u_next = round(normU(data_set.data[i + 1].u) * self.width)
                    local y_v_next = round((1 - normV(data_set.data[i + 1].v)) * self.height)

                    self.buffer:line(x_u, y_v, x_u_next, y_v_next, cell) 
                end
            end
        end
    end
end

return Graph