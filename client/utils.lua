-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function getAbsoluteCursorPosition()
    local cursorX, cursorY = getCursorPosition()
    
    if (not cursorX) then
        return false
    end

	return (cursorX * SCREEN_WIDTH), (cursorY * SCREEN_HEIGHT)
end

function isDxElement(e)
    if (e) and (e.__dx) then
        return true
    end
    return false
end