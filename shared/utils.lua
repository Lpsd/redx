-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

function string:split(sep)
    sep = (type(sep) == "string" and sep ~= "") and sep or " "
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in self:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

local function getLogStamp()
    return os.date("%H:%M:%S") .. " [" .. MTA_PLATFORM .. "]"
end

function iprintd(...)
    return iprint("redx@" .. getLogStamp(), ...)
end

function isVector(vector)
    if (type(vector) ~= "userdata") then
        return false
    end

    local vector_type = getUserdataType(vector)

    if (not vector_type:match("vector")) then
        return false
    end

    return true, vector_type
end

function getVectorDimensions(vector)
    local is_vector, vector_type = isVector(vector)

    if (not is_vector) then
        return false
    end

    return vector_type:split("vector")[1]
end

function enum(tbl, prefix)
    if (type(tbl) ~= "table" or #tbl == 0 or (prefix and type(prefix) ~= "string")) then
        return
    end

    for i, v in ipairs(tbl) do
        local index = (prefix and prefix .. "_" or "") .. v

        if (not _G[index]) then
            _G[index] = i
        end
    end
end

function getIndexes(tbl)
    if (type(tbl) ~= "table") then
        return false
    end

    local t = {}

    for i in pairs(tbl) do
        t[#t + 1] = i
    end

    return t
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
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