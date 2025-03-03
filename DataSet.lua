local DataSet = {
    data_source = nil,
    data_color = colors.red,
    data = {},
}

function DataSet:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function DataSet:poll()
    if self.data_source then
        local data_file = fs.open(self.data_source, "r")
        self.data = textutils.unserialise(data_file.readAll())
        data_file.close()
    end
end

return DataSet