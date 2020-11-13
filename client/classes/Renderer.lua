-- Author: Lpsd
-- File: client/classes/Renderer.lua
-- Description: Renderer class

-- *******************************************************************
Renderer = inherit(Singleton)
-- *******************************************************************

function Renderer:constructor()
    dxDebug("Renderer initialized")

    self.fRender = bind(self.render, self)
    self.fPreRender = bind(self.preRender, self)

    self.fHandleClick = bind(self.handleClick, self)

    addEventHandler("onClientRender", root, self.fRender)
    addEventHandler("onClientPreRender", root, self.fPreRender)
    addEventHandler("onClientClick", root, self.fHandleClick)
end

function Renderer:render()
    for i = #DxRootElements, 1, -1 do
        local element = DxRootElements[i]
        element:render()
    end
end

function Renderer:preRender()
    for i = #DxRootElements, 1, -1 do
        local element = DxRootElements[i]
        element:preRender()
    end
end

function Renderer:handleClick(button, state, tbl)
    button = button:gsub("^%l", string.upper)
    tbl = (type(tbl) == "table") and tbl or DxRootElements

    if (button == "Left") and (state == "up") then
        if (DxFocusedElement) then
            DxFocusedElement["clickLeft"](DxFocusedElement, false)
            DxFocusedElement = false
        end
    end

    for i, element in ipairs(tbl) do
        if (not self:handleClick(button, state, element.children)) then
            local clickArea = element:getAbsoluteClickArea()
            if (isMouseInPosition(clickArea.x, clickArea.y, clickArea.width, clickArea.height)) then
                if (not element:isObstructed()) then
                    DxFocusedElement = element
                    return element["click"..button](element, (state == "down") and true or false)
                end
            end
        end
    end

    return false
end