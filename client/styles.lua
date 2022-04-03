-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

function loadStylesFromFile(path)
    if (not fileExists(path)) then
        return false
    end

    local stylesFile = fileOpen(path)

    if (stylesFile) then
        local size = fileGetSize(stylesFile)
        local jsonData = fileRead(stylesFile, size)

        fileClose(stylesFile)

        local tbl = fromJSON(jsonData)

        if (type(tbl) ~= "table") then
            return false
        end

        return tbl
    end

    return false
end

function loadClassStyles(class)
    local is_default = (class == "default")
    local styles = loadStylesFromFile((is_default and "" or "styles/") .. class .. ".style")
    local customStyles = (not is_default) and loadStylesFromFile("styles/custom/" .. class .. ".style")

    if (not styles) and (not customStyles) then
        return false
    end

    styles = (type(styles) == "table") and styles or {}

    if (type(customStyles) == "table") then
        for styleType, data in pairs(customStyles) do
            if (type(styles[styleType]) == "nil") then
                styles[styleType] = data
            else
                for style, value in pairs(data) do
                    if (type(styles[styleType][style]) == "nil") then
                        styles[styleType][style] = value
                    end
                end
            end
        end
    end

    return styles
end

function getClassStyles(class)
    return DxStyles[class]
end

function setClassStyle(class, name, value)
    class = (type(class) == "string") and class or "default"

    if (not DxStyles[class]) or (type(name) ~= "string") then
        return false
    end

    DxStyles[class][name] = value
end

function getClassStyle(class, name)
    class = (type(class) == "string") and class or "default"

    if (not DxStyles[class]) then
        return false
    end

    return DxStyles[class][name]
end
