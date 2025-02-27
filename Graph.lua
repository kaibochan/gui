local Element = require("/apis/gui.Element")
local Cell = require("/apis/gui.Cell")
local Utils = require("/apis/gui.Utils")

local Graph = Element:new {
    data_source = nil,
    data_color = colors.red,
    data = {},

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

    setmetatable(o, self)
    self.__index = self

    return o
end

function Graph:pullData()
    local data_file = fs.open(self.data_source, "r")
    print(self.data_source)
    self.data = textutils.unserialise(data_file.readAll())
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
        if x_u0 >= 0 and x_u0 < self.width then
            for y = 0, self.height - 1 do
                self.buffer.cells[x_u0][y].bg_color = colors.lightGray
            end
        end

        if y_v0 >= 0 and y_v0 < self.height then
            for x = 0, self.width - 1 do
                self.buffer.cells[x][y_v0].bg_color = colors.lightGray
            end
        end
    end
    
    local delta_u = self.width / u_span
    local delta_v = self.height / v_span

    local cols = {
        colors.red,
        colors.orange,
        colors.lime,
        colors.cyan,
        colors.purple,
    }

    for i, point in ipairs(self.data) do
        local x_u = round(normU(point.u) * self.width)
        local y_v = round((1 - normV(point.v)) * self.height)

        if self.type == Graph.type.scatter then
            if self.buffer:inBounds(x_u, y_v) then
                self.buffer.cells[x_u][y_v].bg_color = colors.black
                self.buffer.cells[x_u][y_v].character = string.sub(i, 1, 1)
            end
        elseif self.type == Graph.type.bar then
            local max_x = math.min((normU(point.u) * self.width) + delta_u - 0.5, self.width - 1)
            local min_y = math.max(math.min(y_v, y_v0), 0)
            local max_y = math.min(math.max(y_v, y_v0), self.height - 1)
            local cell = Cell:new { bg_color = cols[((i - 1) % #cols) + 1] }

            self.buffer:fillRect(x_u, min_y, max_x, max_y, cell)
            
        end
    end
end

return Graph