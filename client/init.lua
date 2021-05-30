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
end
addEventHandler("onClientResourceStart", resourceRoot, init)

-- *******************************************************************

function dxTest()
    local renderer = Renderer:getInstance()
    local screenWidth, screenHeight = renderer.screenWidth, renderer.screenHeight

    local windowSize = (screenWidth / 3)
    window = DxWindow:new((screenWidth / 2) - (windowSize / 2), (screenHeight / 2) - (windowSize / 2), windowSize, windowSize, false, nil, "Test Window", 35, true, true)
    window:setDraggable(true)

    item = DxRect:new(25, 25, 100, 100, false, window)
    item:setDraggableChildren(true)

    item2 = DxRect:new(75, 75, 50, 50, false, item)
    item2:setDraggableChildren(true)
    item2.style:setColor("background", 66, 66, 66)

    item3 = DxRect:new(50, 50, 50, 50, false, item2)
    item3.style:setColor("background", 99, 99, 99)

    label = DxLabel:new(0, 0, 100, 50, false, item, "My first label", nil, "center", "center")

    image = DxImage:new(windowSize / 2 - 61 / 2, (windowSize / 2) - (82 / 2) - window.titlebar.height, 61, 82, false, window, "images/kfc.png")

    window:setTitlebarHeight(50)

    window:setSize(300, 300)
end
-- *******************************************************************

bindKey("F2", "down", function()
    showCursor(not isCursorShowing())
end)