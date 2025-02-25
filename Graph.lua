local Element = require("/apis/gui.Element")

local Graph = Element:new {
    data_source = nil,
    data_color = colors.red,
    data = {},

    u_min = 0,
    u_max = 1,
    v_min = 0,
    v_max = 1,
    draw_axes = false,
}

function Graph:new(o)
    o = o or {}
    o = Element:new(o)

    setmetatable(o, self)
    self.__index = self

    return o
end

function Graph:pullData()
    local data_file = fs.open(self.data_source, "r")
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
    local function inBounds(x, y)
        return (x >= 0 and x < self.width and y >= 0 and y < self.height)
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

        if inBounds(x_u, y_v) then
            for x = x_u, (normU(point.u) * self.width) + delta_u - 0.5 do
                local y_step = (y_v < y_v0) and 1 or -1
                for y = y_v, y_v0, y_step do
                    if inBounds(x, y) then
                        self.buffer.cells[x][y].bg_color = cols[((i - 1) % #cols) + 1]
                    end
                end
            end

            self.buffer.cells[x_u][y_v].bg_color = colors.black
            self.buffer.cells[x_u][y_v].character = string.sub(i, 1, 1)
        end
    end
end

return Graph