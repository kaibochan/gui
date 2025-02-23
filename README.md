# CC-GUI

CC-GUI is a graphical user interface library built for [CC: Tweaked](https://tweaked.cc/).

## Features

CC-GUI currently supports a limited number of UI elements, but the library is easily extensible.

### Events

Support for:
- [mouse_click](https://tweaked.cc/event/mouse_click.html)
- [monitor_touch](https://tweaked.cc/event/monitor_touch.html)
- [timer](https://tweaked.cc/event/timer.html)

#### Usage

CC-GUI makes use of events by checking to see if a given element contains a member function (callback) by the same name as the event.  
Attaching a callback function:
```lua
    function element:monitor_touch(e)
    -- or
    element.monitor_touch = function(self, e)
```
Notice that callback functions always include `self` as the first parameter and the event data as the second.  
Example event data:
```lua
    event_data = {os.pullEvent("monitor_touch")}
    e = {
        name    = event_data[1],
        display = event_data[2],
        x       = event_data[3],
        y       = event_data[4],
    }
```

## Installation

Installing CC-GUI is as easy as copying it onto your CC computer.
It should be placed within the directory `/apis/gui`.

