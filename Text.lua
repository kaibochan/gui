local Element = require("/apis/gui.Element")
local Cell = require("/apis/gui.Cell")

local Text = Element:new {
    __name = "Text",
    text = "",
    text_color = colors.white,

    text_lines = {""},
    scroll_offset = 0,
    auto_scroll = false,
}

function Text:new(o)
    o = o or {}
    o = Element:new(o)

    setmetatable(o, self)
    self.__index = self

    o:updateTextBuffer()

    return o
end

-- write text to an intermediate text buffer
-- breaking it up into lines to be drawn onto the cell buffer
function Text:updateTextBuffer()
    self.text_lines = {}
    local sub_text = self.text

    while #sub_text > 0 do
        local new_line_index = sub_text:find("\n")
        if not new_line_index or new_line_index > self.width then
            table.insert(self.text_lines, sub_text:sub(1, self.width))
            sub_text = sub_text:sub(self.width + 1)
        else
            table.insert(self.text_lines, sub_text:sub(1, new_line_index))
            sub_text = sub_text:sub(new_line_index + 1)
        end
    end

    if self.auto_scroll then
        self.scroll_offset = math.max(0, #self.text_lines - self.height)
    end
end

function Text:setText(new_text)
    self.text = new_text
    self:updateTextBuffer()
end

function Text:getText()
    return self.text
end

function Text:write(to_write)
    self.text = self.text .. to_write
    self:updateTextBuffer()
end

function Text:updateBuffer()
    local default_cell = Cell:new {
        bg_color = self.bg_color,
        fg_color = self.text_color,
    }
    self.buffer:fill(default_cell)

    -- self:updateTextBuffer()
    for x = 0, self.width - 1 do
        for y = 0, self.height - 1 do
            local line_index = y + self.scroll_offset + 1
            if line_index > 0 and line_index <= #self.text_lines then
                local character = self.text_lines[line_index]:sub(x + 1, x + 1)
                if #character ~= 0 then
                    self.buffer.cells[x][y].character = character
                end
            end
        end
    end
end

return Text