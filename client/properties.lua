-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

DEFAULT_PROPERTIES = false

local defaultPropertiesPath = "default.properties"

function loadPropertiesFromFile(path)
    local propertiesFile = fileOpen(path or defaultPropertiesPath)

    if (propertiesFile) then
        local size = fileGetSize(propertiesFile)
        local jsonData = fileRead(propertiesFile, size)

        DEFAULT_PROPERTIES = fromJSON(jsonData)

        fileClose(propertiesFile)
        dxDebug("Loaded default properties", path)
        return DEFAULT_PROPERTIES
    end
    dxDebug("Failed to load default properties", path)
    return false
end

function loadDefaultProperties()
    return loadPropertiesFromFile(defaultPropertiesPath)
end

function getDefaultProperties()
    return DEFAULT_PROPERTIES or loadDefaultProperties() or dxDebug("Problem getting default properties")
end

function setDefaultProperty(name, value)
    if (type(name) ~= "string") then
        return false
    end

    if (DEFAULT_PROPERTIES[name]) and (type(val) ~= type(DEFAULT_PROPERTIES[name])) then
        return false
    end

    DEFAULT_PROPERTIES[name] = val
    return true
end

function getDefaultProperty(name)
    return DEFAULT_PROPERTIES[name]
end