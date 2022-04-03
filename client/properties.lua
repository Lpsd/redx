-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

function loadPropertiesFromFile(path)
    if (not fileExists(path)) then
        return false
    end

    local propertiesFile = fileOpen(path)

    if (propertiesFile) then
        local size = fileGetSize(propertiesFile)
        local jsonData = fileRead(propertiesFile, size)

        fileClose(propertiesFile)

        local tbl = fromJSON(jsonData)

        if (type(tbl) ~= "table") then
            return false
        end

        return tbl
    end

    return false
end

function loadClassProperties(class)
    local is_default = (class == "default")
    local properties = loadPropertiesFromFile((is_default and "" or "properties/") .. class .. ".properties")
    local customProperties = (not is_default) and loadPropertiesFromFile("properties/custom/" .. class .. ".properties")

    if (not properties) and (not customProperties) then
        return false
    end

    properties = (type(properties) == "table") and properties or {}

    if (type(customProperties) == "table") then
        for prop, value in pairs(customProperties) do
            if (type(properties[prop]) == "nil") then
                properties[prop] = value
            end
        end
    end
    
    return properties
end

function getClassProperties(class)
    return DxProperties[class]
end

function setClassProperty(class, name, value)
    class = (type(class) == "string") and class or "default"

    if (not DxProperties[class]) or (type(name) ~= "string") then
        return false
    end

    DxProperties[class][name] = value
    return true
end

function getClassProperty(class, name)
    class = (type(class) == "string") and class or "default"

    if (not DxProperties[class]) then
        return false
    end

    return DxProperties[class][name]
end