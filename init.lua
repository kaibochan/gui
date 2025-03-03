-- Package initialization and loading

local gui = {}
gui.Element = require("/apis/gui.Element")
gui.Display = require("/apis/gui.Display")
gui.Text = require("/apis/gui.Text")
gui.Bar = require("/apis/gui.Bar")
gui.Graph = require("/apis/gui.Graph")
gui.DataSet = require("/apis/gui.DataSet")
gui.Utils = require("/apis/gui.Utils")

local displays_attached = {}

function gui.initializeDisplay(display_device)
    display_width, display_height = display_device.getSize()
    
    local display = gui.Display:new {
        device = display_device,
        is_monitor = false,
        width = display_width,
        height = display_height,
    }
    table.insert(displays_attached, display)
    
    return display
end

function gui.doEvents()
    local e = gui.getEvents()

    if not e then
        return
    end

    if e.name == "monitor_touch" then
        local selected_display = nil

        for _, display in ipairs(displays_attached) do
            if peripheral.getName(display.device) == e.display then
                selected_display = display
                break
            end
        end

        -- get selected element given the x and y
        -- if the element has a callback function associated with
        -- this event, it will be called and given the event object
        local element = selected_display:getSelectedElement(e.x, e.y)
        if element[e.name] then
            element[e.name](element, e)
        end
    elseif e.name == "mouse_click" then
        local selected_display = nil

        for _, display in ipairs(displays_attached) do
            if display.device == term then
                selected_display = display
                break
            end
        end

        local element = selected_display:getSelectedElement(e.x, e.y)
        if element[e.name] then
            element[e.name](element, e)
        end
    elseif e.name == "timer" then
        for _, display in ipairs(displays_attached) do
            for _, element in ipairs(display.elements) do
                if element.element[e.name] then
                    element.element[e.name](element.element, e)
                end
            end
        end
    end
end

function gui.getEvents()
    local event_data = {os.pullEvent()}

    if event_data[1] == "timer" then
        return {
            name = event_data[1],
            id = event_data[2],
        }
    elseif event_data[1] == "monitor_resize" then
        return {
            name = event_data[1],
            display = event_data[2],
        }
    elseif event_data[1] == "monitor_touch" then
        return {
            name = event_data[1],
            display = event_data[2],
            x = event_data[3],
            y = event_data[4],
        }
    elseif event_data[1] == "mouse_click"
        or event_data[1] == "mouse_up"
        or event_data[1] == "mouse_drag" then
        return {
            name = event_data[1],
            button = event_data[2],
            x = event_data[3],
            y = event_data[4],
        }
    elseif event_data[1] == "key" then
        return {
            name = event_data[1],
            key_code = event_data[2],
            is_held = event_data[3],
        }
    elseif event_data[1] == "key_up" then
        return {
            name = event_data[1],
            key_code = event_data[2],
        }
    end
end

return gui