-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

local testsEnabled = true

local tests = {
    ["splitRectExample"] = true,
    ["splitRectExampleCanvas"] = true,
    ["canvasExample"] = true
}

local funcs = {}

function funcs.splitRectExample()
    -- Create a "main" parent rect, draggable as well as all children
    local rect = Rect:new(350, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)
    rect:setProperty("drag_children", true)

    -- Split main rect in half by 2 rects
    local rect2 = Rect:new(0, 0, 100, 200, tocolor(66, 66, 66), rect, "rect2")
    local rect3 = Rect:new(100, 0, 100, 200, tocolor(99, 99, 99), rect, "rect3")

    -- Add smaller rect as parent of right half, but set to center of left half
    local rect4 = Rect:new(0, 0, 50, 50, tocolor(122, 122, 122), rect3, "rect4")
    rect4:setCentered(rect2)

    -- Add an even smaller rect to the last one, and center it
    local rect5 = Rect:new(0, 0, 25, 25, tocolor(166, 166, 166), rect4, "rect5")
    rect5:setCentered()
end

function funcs.splitRectExampleCanvas()
    -- Create a "main" parent rect, draggable as well as all children
    local rect = Rect:new(600, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)
    rect:setProperty("drag_children", true)

    local canvas = Canvas:new(0, 0, 200, 200, nil, rect, "canvas")

    -- Split main rect in half by 2 rects
    local rect2 = Rect:new(0, 0, 100, 200, tocolor(66, 66, 66), canvas, "rect2")
    local rect3 = Rect:new(100, 0, 100, 200, tocolor(99, 99, 99), canvas, "rect3")

    -- Add smaller rect as parent of right half, but set to center of left half
    local rect4 = Rect:new(0, 0, 50, 50, tocolor(122, 122, 122), rect3, "rect4")
    rect4:setCentered(rect2)

    -- Add an even smaller rect to the last one, and center it
    local rect5 = Rect:new(0, 0, 25, 25, tocolor(166, 166, 166), rect4, "rect5")
    rect5:setCentered()
end

function funcs.canvasExample()
    -- Create the main canvas
    local rect = Rect:new(850, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)
    rect:setProperty("drag_children", true)

    local canvas = Canvas:new(0, 0, 200, 200, nil, rect, "canvas")
    local rect2 = Rect:new(50, 50, 50, 50, tocolor(66, 66, 66), canvas, "rect2")
end

function runTests()
    if (not testsEnabled) then
        return false
    end

    for testName, state in pairs(tests) do
        if (state) then
            local func = funcs[testName]

            if (type(func) == "function") then
                func()
            end
        end
    end
end
