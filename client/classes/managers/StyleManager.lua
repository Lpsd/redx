-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
StyleManager = inherit(Singleton)
-- *******************************************************************

function StyleManager:constructor()
    self.styles = {}
    self.currentStyle = false
    self.defaultStyle = false

    -- Each dx element has it's own copy of the style
    self.styleInstances = {}

    self:parseMetaStyles()
end

function StyleManager:createStyleInstance(style, dxInstance)
    if (not self:isValidStyle(style)) or (not dxInstance.__dx) then
        return false
    end

    self.styleInstances[dxInstance] = deepcopy(style)
    return self.styleInstances[dxInstance]
end

function StyleManager:isValidStyle(style)
    for i, v in ipairs(self.styles) do
        if (v == style) then
            return true
        end
    end
    return false
end

function StyleManager:setCurrentStyle(style)
    self.currentStyle = style
end

function StyleManager:getCurrentStyle()
    return self.currentStyle
end

function StyleManager:parseMetaStyles()
    local rootNode = xmlLoadFile("meta.xml")
    local nodes = xmlNodeGetChildren(rootNode)

    for i, node in ipairs(nodes) do
        local name = xmlNodeGetName(node)
        local styleName = xmlNodeGetAttribute(node, "styleName")

        if (name == "file") and (styleName) then
            local style = Style:new(styleName, xmlNodeGetAttribute(node, "src"))

            if (style:parseXML()) then
                table.insert(self.styles, style)

                if (xmlNodeGetAttribute(node, "default") == "true") then
                    self:setDefaultStyle(style)
                    self:setCurrentStyle(style)
                end
            else
                style:destroy()
                dxDebug("[StyleManager:parseMetaStyles] Failed to load style (" .. styleName .. ")")
            end
        end
    end

    dxDebug("[StyleManager] " .. #self.styles .. " styles loaded")
end

function StyleManager:setDefaultStyle(style)
    self.defaultStyle = style
end

function StyleManager:getDefaultStyle()
    return self.defaultStyle
end