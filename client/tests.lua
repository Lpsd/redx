-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

local testsEnabled = true

local tests = {
    ["splitRectExample"] = true,
    ["splitRectExampleCanvas"] = true,
    ["dragPropagationExample"] = true,
    ["animationLoopExample"] = true,
    ["buttonExample"] = true,
}

local funcs = {}

function funcs.splitRectExample()
    -- Temporarily set property
    local oldValue = DxProperties.Rect.click_order
    DxProperties.Rect.click_order = true

    -- Create a "main" parent rect, draggable as well as all children
    local rect = Rect:new(50, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)
    rect:setProperty("drag_children", true)

    -- Split main rect in half by 2 rects
    local rect2 = Rect:new(0, 0, 100, 200, tocolor(66, 66, 66), rect, "rect2")
    local rect3 = Rect:new(100, 0, 100, 200, tocolor(99, 99, 99), rect, "rect3")

    -- Add smaller rect as parent of right half, but set to center of left half
    local rect4 = Rect:new(0, 0, 50, 50, tocolor(122, 122, 122), rect3, "rect4")
    rect4:setCentered(rect2)

    -- Add an even smaller rect to the last one, center it & force in bounds
    local rect5 = Rect:new(0, 0, 25, 25, tocolor(166, 166, 166), rect4, "rect5")
    rect5:setCentered()
    rect5:setProperty("force_in_bounds", true)

    -- Reset property
    DxProperties.Rect.click_order = oldValue
end

function funcs.splitRectExampleCanvas()
    -- Temporarily set property
    local oldValue = DxProperties.Rect.click_order
    DxProperties.Rect.click_order = true

    -- Create a "main" parent rect, draggable as well as all children
    local rect = Rect:new(300, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)
    rect:setProperty("drag_children", true)

    -- Create a canvas to store the children
    local canvas = Canvas:new(0, 0, 200, 200, nil, rect, "canvas")

    -- Split main rect in half by 2 rects
    local rect2 = Rect:new(0, 0, 100, 200, tocolor(66, 66, 66), canvas, "rect2")
    local rect3 = Rect:new(100, 0, 100, 200, tocolor(99, 99, 99), canvas, "rect3")

    -- Add smaller rect as parent of right half, but set to center of left half
    local rect4 = Rect:new(0, 0, 50, 50, tocolor(122, 122, 122), rect3, "rect4")
    rect4:setCentered(rect2)

    -- Add an even smaller rect to the last one, center it & force in bounds
    local rect5 = Rect:new(0, 0, 25, 25, tocolor(166, 166, 166), rect4, "rect5")
    rect5:setCentered()
    rect5:setProperty("force_in_bounds", true)

    -- Reset property
    DxProperties.Rect.click_order = oldValue
end

function funcs.dragPropagationExample()
    -- Temporarily set properties globally
    local props = DxProperties.Rect
    local oldValues = {
        click_order = props.click_order,
        force_in_bounds = props.force_in_bounds,
        click_propagate = props.click_propagate,
        drag_propagate = props.drag_propagate
    }

    DxProperties.Rect.click_order = true
    DxProperties.Rect.force_in_bounds = true
    DxProperties.Rect.click_propagate = true
    DxProperties.Rect.drag_propagate = true

    -- Create a "main" parent rect, draggable as well as all children
    local rect = Rect:new(550, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)
    rect:setProperty("drag_children", true)

    -- Create some rectangles, children of each other, all centered
    local rect2 = Rect:new(0, 0, 150, 150, tocolor(66, 66, 66), rect, "rect2")
    rect2:setCentered()

    local rect3 = Rect:new(0, 0, 100, 100, tocolor(99, 99, 99), rect2, "rect3")
    rect3:setCentered()

    local rect4 = Rect:new(0, 0, 50, 50, tocolor(122, 122, 122), rect3, "rect4")
    rect4:setCentered()

    local rect5 = Rect:new(0, 0, 25, 25, tocolor(166, 166, 166), rect4, "rect5")
    rect5:setCentered()

    -- Freeze the final rectangle in the center of its parent (dragging will not affect position)
    rect5:setFrozen("x", true)
    rect5:setFrozen("y", true)

    -- Reset properties
    DxProperties.Rect.click_order = oldValues.click_order
    DxProperties.Rect.force_in_bounds = oldValues.force_in_bounds
    DxProperties.Rect.click_propagate = oldValues.click_propagate
    DxProperties.Rect.drag_propagate = oldValues.drag_propagate
end

function funcs.animationLoopExample()
    -- Temporarily set property
    local oldValue = DxProperties.Rect.click_order
    DxProperties.Rect.click_order = true

    -- Create a "main" parent rect
    local rect = Rect:new(800, 50, 200, 200, tocolor(33, 33, 33), false, "rect")
    rect:setProperty("drag", true)

    -- Create a small rectangle to animate inside the main rect
    local rect2 = Rect:new(0, 0, 50, 50, tocolor(66, 66, 66), rect, "rect2")

    -- Create our position animations (set as looped)
    local animX = Animation:new("x", 0, 150, 1000, "InQuad", true)
    local animY = Animation:new("y", 0, 150, 1000, "OutQuad", true)

    -- Create some color animations (also looped) with a custom function to update color on any instance it is attached to
    -- Note: animations only support automatically updating properties which consist of a single number value (e.g x, y, width, height)
    -- We need to interpolate r, g and b here, so pass a table of numbers to interpolate and manually update the color value.
    local animColorRedToBlue = Animation:new("color", {255, 0, 0}, {0, 0, 255}, 1000, "InOutBounce", true, function(dxInstance, interpolated)
        dxInstance.styles.background.normal = { interpolated[1], interpolated[2], interpolated[3], 255 }
    end)

    local animColorBlueToRed = Animation:new("color", {0, 0, 255}, {255, 0, 0}, 1000, "InOutBounce", true, function(dxInstance, interpolated)
        dxInstance.styles.background.normal = { interpolated[1], interpolated[2], interpolated[3], 255 }
    end)

    -- Toggle all animations every second, creating a delay between them
    setTimer(function()
        animX:toggle()
        animY:toggle()
        animColorRedToBlue:toggle()
        animColorBlueToRed:toggle()
    end, 1000, 0)

    -- Add position animations to rect2, starting automatically
    rect2:addAnimation(animX, true)
    rect2:addAnimation(animY, true)

    -- Add our color animations, one starting automatically, the other paused (until toggled by the timer above)
    rect2:addAnimation(animColorRedToBlue, true)
    rect2:addAnimation(animColorBlueToRed, false)

    -- Reset property
    DxProperties.Rect.click_order = oldValue
end

function funcs.buttonExample()
    local button = Button:new(50, 300, 200, 75, tocolor(66, 66, 66), false, "button")
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
