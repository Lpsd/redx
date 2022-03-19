-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

function isDx(dx)
    return instanceof(dx, Dx) or instanceof(dx, Dx, true)
end

function getDxByName(name)
    local t = {}

    for i = 1, #DxInstances do
        local dx = DxInstances[i]

        if (dx.name == name) then
            t[#t+1] = dx
        end
    end

    return t
 end

function getAbsoluteCursorPosition()
    if (not isCursorShowing()) then
        return 0, 0
    end

    local x, y = getCursorPosition()

    return (x * SCREEN_WIDTH), (y * SCREEN_HEIGHT)
end

function isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then
        return false
    end

    local cx, cy = getAbsoluteCursorPosition()

    return ((cx >= x and cx <= x + width) and (cy >= y and cy <= y + height))
end
