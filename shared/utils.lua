local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
    if length > 0 then
        return string.random(length - 1) .. charset[math.random(1, #charset)]
    end

    return ""
end

function math.clamp(num, min, max)
    return (num <= min) and min or (num >= max) and max or num
end

function isDxElement(e)
    if (e) and (e._dx) then
        return true
    end
    return false
end

function dxDebug(...)
    if (DEBUG) then
        return iprint("[DX Library]", ...)
    end
    return false
end

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