local Element = require("/apis/gui.Element")
local Buffer = require("/apis/gui.Buffer")

local Display = {
    __name = "Display",
    device = nil,
    is_monitor = false,
    width = 1,
    height = 1,
    window = Element,
    elements = {},
}

function Display:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    o.window = Element:new {
        width = o.width,
        height = o.height,
    }
    o.elements = {}

    return o
end

function Display:render()

    -- draw all elements in breadth-first traversal order
    local index = 1
    self.elements = {{
        element = self.window,
        global_x = self.window.x,
        global_y = self.window.y,
    }}

    -- traversal loop
    repeat
        -- add children of current element to elements list
        for _, child in ipairs(self.elements[index].element.children) do
            table.insert(self.elements, {
                element = child,
                global_x = self.elements[index].global_x + child.x,
                global_y = self.elements[index].global_y + child.y,
            })
        end

        -- update buffer of current element before copying
        self.elements[index].element:updateBuffer()

        -- write the current element's buffer data to screen buffer
        local offset_x = self.elements[index].global_x
        local offset_y = self.elements[index].global_y
        
        for x = 0, self.elements[index].element.width - 1 do
            for y = 0, self.elements[index].element.height - 1 do
                if (x + offset_x < self.window.width and y + offset_y < self.window.height) then
                    self.window.buffer.cells[x + offset_x][y + offset_y]:copy(
                        self.elements[index].element.buffer.cells[x][y]
                    )
                end
            end
        end

        index = index + 1
    until index > #self.elements

    -- write screen buffer data to the display device
    for y = 0, self.height - 1 do
        local characters = ""
        local fg_colors = ""
        local bg_colors = ""

        for x = 0, self.width - 1 do
            characters = characters .. self.window.buffer.cells[x][y].character
            fg_colors = fg_colors .. colors.toBlit(self.window.buffer.cells[x][y].fg_color)
            bg_colors = bg_colors ..  colors.toBlit(self.window.buffer.cells[x][y].bg_color)
        end

        self.device.setCursorPos(1, y + 1)
        self.device.blit(characters, fg_colors, bg_colors)
    end
end

function Display:getSelectedElement(x, y)
    local selection = nil

    for i = #self.elements, 1, -1 do
        if (x - 1 >= self.elements[i].global_x
        and x - 1 <  self.elements[i].global_x + self.elements[i].element.width
        and y - 1 >= self.elements[i].global_y
        and y - 1 <  self.elements[i].global_y + self.elements[i].element.height) then
            selection = self.elements[i].element
            break
        end
    end

    return selection
end

return Display