-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

function isDx(dx)
    return instanceof(dx, Dx) or instanceof(dx, Dx, true)
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
