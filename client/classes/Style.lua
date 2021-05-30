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
                    r = tonumber(xmlNodeGetAttribute(styleNode, "r")),
                    g = tonumber(xmlNodeGetAttribute(styleNode, "g")),
                    b = tonumber(xmlNodeGetAttribute(styleNode, "b")),
                    a = tonumber(xmlNodeGetAttribute(styleNode, "a"))
                })
            end

            if (styleType == "size") then
                table.insert(self.classStyles[className][styleType], {
                    type = xmlNodeGetAttribute(styleNode, "type"),
                    value = tonumber(xmlNodeGetAttribute(styleNode, "value"))
                })
            end
            
            if (styleType == "option") then
                local value = xmlNodeGetAttribute(styleNode, "value")

                if tonumber(value) then
                    value = tonumber(value)
                elseif (value == "true") then
                    value = true
                elseif (value == "false") then
                    value = false
                end

                table.insert(self.classStyles[className][styleType], {
                    type = xmlNodeGetAttribute(styleNode, "type"),
                    value = value
                })
            end

            if (styleType == "font") then
                local fontName = xmlNodeGetAttribute(styleNode, "fontName")

                table.insert(self.classStyles[className][styleType], {
                    type = xmlNodeGetAttribute(styleNode, "type"),
                    fontName = fontName
                })
            end
        end
    end

    return true
end

function Style:getSize(...)
    if (not self.dxInstance) or (self.dxInstance and not self.dxInstance.__dx) then
        return dxDebug("[Style:getSize] Invalid dx instance") and false
    end

    return self:getSizeByClass(self.dxInstance.type, ...)
end

function Style:getSizeByClass(classType, sizeType)
    if (not classType) then
        if (self.dxInstance) then
            classType = self.dxInstance.type
        else
            return dxDebug("[Style:_getSizeByClass] Invalid classType provided: " .. tostring(classType))
        end
    end

    local className = getDxClassNameFromType(classType)
    local classStyle = self.classStyles[className]

    if (not classStyle) then
        return dxDebug("[Style:getSizeByClass] Class style not found: " .. tostring(className)) and false
    end

    local sizes = classStyle.size
    local size

    for i, s in ipairs(sizes) do
        if (s.type == sizeType) then
            size = s.value
            break
        end
    end

    if (not size) then
        return dxDebug("[Style:getSizeByClass] Size type not found: " .. className .. "/" .. sizeType) and false
    end

    return size
end

function Style:getFont(...)
    if (not self.dxInstance) or (self.dxInstance and not self.dxInstance.__dx) then
        return dxDebug("[Style:getFont] Invalid dx instance") and false
    end

    return self:getFontByClass(self.dxInstance.type, ...)
end

function Style:getFontByClass(classType, fontType)
    if (not classType) then
        if (self.dxInstance) then
            classType = self.dxInstance.type
        else
            return dxDebug("[Style:_getFontByClass] Invalid classType provided: " .. tostring(classType))
        end
    end

    local className = getDxClassNameFromType(classType)
    local classStyle = self.classStyles[className]

    if (not classStyle) then
        return dxDebug("[Style:getFontByClass] Class style not found: " .. tostring(className)) and false
    end

    if (not classStyle.font) then
        return false
    end

    for i, font in ipairs(classStyle.font) do
        if (font.type == fontType) then
            return FontManager:getInstance():getFontContainer(font.fontName)
        end
    end

    return dxDebug("[Style:getFontByClass] Font not found: " .. className .. "/" .. fontType) and false
end

function Style:getOption(...)
    if (not self.dxInstance) or (self.dxInstance and not self.dxInstance.__dx) then
        return dxDebug("[Style:getOption] Invalid dx instance") and false
    end

    return self:getOptionByClass(self.dxInstance.type, ...)
end

function Style:getOptionByClass(classType, optionType)
    if (not classType) then
        if (self.dxInstance) then
            classType = self.dxInstance.type
        else
            return dxDebug("[Style:_getOptionByClass] Invalid classType provided: " .. tostring(classType))
        end
    end

    local className = getDxClassNameFromType(classType)
    local classStyle = self.classStyles[className]

    if (not classStyle) then
        return dxDebug("[Style:getOptionByClass] Class style not found: " .. tostring(className)) and false
    end

    local options = classStyle.option
    local option

    for i, o in ipairs(sizes) do
        if (s.type == optionType) then
            option = o.value
            break
        end
    end

    if (not option) then
        return dxDebug("[Style:getOptionByClass] Option type not found: " .. className .. "/" .. optionType) and false
    end

    return option
end

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