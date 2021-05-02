-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
Style = inherit(Class)
-- *******************************************************************

function Style:constructor(styleName, src)
    self.name = styleName
    self.src = src

    self.dxInstance = false -- optional
    self.classStyles = {}
end

function Style:parseXML()
    local rootNode = xmlLoadFile(self.src)

    if (not rootNode) then
        return false
    end

    local nodes = xmlNodeGetChildren(rootNode)

    for i, classNode in ipairs(nodes) do
        local className = xmlNodeGetAttribute(classNode, "name")

        if (not className) then
            return dxDebug("Problem getting XML style class name") and false
        end

        local class = _G[className]

        if (not class) then
            return dxDebug("Problem getting class: " .. className) and false
        end

        if (not class.__dx) then
            return dxDebug("Class is not of '__dx' type: " .. className) and false
        end

        if (not self.classStyles[className]) then
            self.classStyles[className] = {}
        end

        local styleNodes = xmlNodeGetChildren(classNode)

        for i, styleNode in ipairs(styleNodes) do
            local styleType = xmlNodeGetName(styleNode)

            if (not self.classStyles[className][styleType]) then
                self.classStyles[className][styleType] = {}
            end

            if (styleType == "color") then
                table.insert(self.classStyles[className][styleType], {
                    type = xmlNodeGetAttribute(styleNode, "type"),
                    r = xmlNodeGetAttribute(styleNode, "r"),
                    g = xmlNodeGetAttribute(styleNode, "g"),
                    b = xmlNodeGetAttribute(styleNode, "b"),
                    a = xmlNodeGetAttribute(styleNode, "a")
                })
            end
        end
    end

    return true
end

-- returns r, g, b, a
function Style:getColor(...)
    if (not self.dxInstance) or (self.dxInstance and not self.dxInstance.__dx) then
        return dxDebug("[Style:getColor] Invalid dx instance") and false
    end

    return self:getColorByClass(self.dxInstance.type, ...)
end


function Style:getColorByClass(classType, colorType)
    if (not classType) then
        if (self.dxInstance) then
            classType = self.dxInstance.type
        else
            return dxDebug("[Style:_getColor] Invalid classType provided: " .. tostring(classType))
        end
    end

    local className = getDxClassNameFromType(classType)
    local classStyle = self.classStyles[className]

    if (not classStyle) then
        return dxDebug("[Style:getColor] Class style not found: " .. tostring(className)) and false
    end

    local colors = classStyle.color
    local color

    for i, c in ipairs(colors) do
        if (c.type == colorType) then
            color = c
            break
        end
    end

    if (not color) then
        return dxDebug("[Style:getColor] Color type not found: " .. className .. "/" .. colorType) and false
    end

    return color
end

function Style:setColor(...)
    if (not self.dxInstance) or (self.dxInstance and not self.dxInstance.__dx) then
        return dxDebug("[Style:setColor] Invalid dx instance") and false
    end

    local set = self:setColorByClass(self.dxInstance.type, ...)
    self.dxInstance:forceUpdate()
    
    return set
end

function Style:setColorByClass(classType, colorType, r, g, b, a)
    r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

    if (not classType) then
        if (self.dxInstance) then
            classType = self.dxInstance.type
        else
            return dxDebug("[Style:_setColor] Invalid classType provided: " .. tostring(classType))
        end
    end

    local className = getDxClassNameFromType(classType)
    local classStyle = self.classStyles[className]

    if (not classStyle) then
        return dxDebug("[Style:setColor] Class style not found: " .. tostring(className)) and false
    end

    local color

    for i, c in ipairs(classStyle.color) do
        if (c.type == colorType) then
            color = c
            break
        end
    end

    if (not color) then
        return dxDebug("[Style:setColor] Color type not found: " .. tostring(className) .. "/" .. colorType) and false
    end

    color.r, color.g, color.b, color.a = r or color.r, g or color.g, b or color.b, a or color.a

    return true
end    