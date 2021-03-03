-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

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

function Renderer:handleClick(button, state)
    if (state == "up") then
        for i = #DxFocusedElements, 1, -1 do
            local element = DxFocusedElements[i]
            element["click"..button:gsub("^%l", string.upper)](element, false)
            table.remove(DxFocusedElements, i)
        end

        return false
    end

    for i, element in ipairs(DxRootElements) do
        local clickArea = element:getAbsoluteClickArea()

        if (isMouseInPosition(clickArea.x, clickArea.y, clickArea.width, clickArea.height)) then
            local obstructingChild = element:getObstructingChild()

            if (obstructingChild) then
                if (obstructingChild:getProperty("click_propagate")) then
                    if (not isFocusedElement(element)) then
                        table.insert(DxFocusedElements, element)
                    end

                    element["click"..button:gsub("^%l", string.upper)](element, (state == "down") and true or false, true)
                end

                if (not isFocusedElement(obstructingChild)) then
                    table.insert(DxFocusedElements, obstructingChild)
                end

                return obstructingChild["click"..button:gsub("^%l", string.upper)](obstructingChild, (state == "down") and true or false)
            end

            if (not isFocusedElement(element)) then
                table.insert(DxFocusedElements, element)
            end           

            element["click"..button:gsub("^%l", string.upper)](element, (state == "down") and true or false)
            return   
        end
    end

    return false
end