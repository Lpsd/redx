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

function dxDebug(...)
    if (true) then
        return iprint("[DX Library]", ...)
    end
    return false
end

function enum(tbl, prefix)
	if (type(tbl) ~= "table" or #tbl == 0 or (prefix and type(prefix) ~= "string")) then
		return
	end
	
	for i, v in ipairs(tbl) do
		local index = (prefix and prefix .. '_' or '') .. v
		
		if (not _G[index]) then
			_G[index] = i
		end
	end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
