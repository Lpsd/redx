-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

DxCore = false

-- *******************************************************************

function init()
    -- Initialize the core
    DxCore = Core:getInstance()

    -- Loads the default properties
    loadDefaultProperties()

    local tick = getTickCount()

    -- Testing
    dxTest()

    iprint("Test took " .. tostring(getTickCount() - tick) .. "ms")
end
addEventHandler("onClientResourceStart", resourceRoot, init)

-- *******************************************************************

function dxTest()
    window = DxWindow:new(500, 300, 400, 400, false, nil, "Test Window")
    window:setDraggable(true)
    window:setDraggableChildren(true)

    item = DxRect:new(25, 25, 100, 100, false, window)
    item:setDraggableChildren(true)

    item2 = DxRect:new(75, 75, 50, 50, false, item)
    item2:setDraggableChildren(true)
    item2.style:setColor("background", 66, 66, 66)

    item3 = DxRect:new(50, 50, 50, 50, false, item2)
    item3.style:setColor("background", 99, 99, 99)
end
-- *******************************************************************

bindKey("F2", "down", function()
    showCursor(not isCursorShowing())
end)