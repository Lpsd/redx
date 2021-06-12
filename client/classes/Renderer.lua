-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
Renderer = inherit(Singleton)
-- *******************************************************************

function Renderer:constructor()
    self.fRender = bind(self.render, self)
    self.fPreRender = bind(self.preRender, self)

    self.fHandleClick = bind(self.handleClick, self)

    self.screenWidth, self.screenHeight = guiGetScreenSize()

    addEventHandler("onClientRender", root, self.fRender)
    addEventHandler("onClientPreRender", root, self.fPreRender)
    addEventHandler("onClientClick", root, self.fHandleClick)
end

function Renderer:render(elements)
    local core = Core:getInstance()
    elements = (type(elements) == "table") and elements or core.dxRootElements

    for i = #elements, 1, -1 do
        if (elements[i].__dx) then
            elements[i]:render()
        end
    end
end

function Renderer:preRender(elements)
    local core = Core:getInstance()
    elements = (type(elements) == "table") and elements or core.dxRootElements

    for i = #elements, 1, -1 do
        if (elements[i].__dx) then
            elements[i]:preRender()
        end
    end
end


function Renderer:refreshElementIndexes()
    local core = Core:getInstance()
    for i, element in ipairs(core.dxRootElements) do
        element.index = element:getTableIndex()
        self:refreshElementChildIndexes(element)
    end 
end

function Renderer:refreshElementChildIndexes(element)
    for i, child in ipairs(element.children) do
        child.index = child:getTableIndex()
    end
end

function Renderer:handleClick(button, state)
    local core = Core:getInstance()
    if (state == "up") then
        for i = #core.dxFocusedElements, 1, -1 do
            local element = core.dxFocusedElements[i]
            element["click"..button:gsub("^%l", string.upper)](element, false)
            table.remove(core.dxFocusedElements, i)
        end

        return false
    end

    for i, element in ipairs(core.dxRootElements) do
        local inheritedBounds = element:getInheritedBounds(false)
        local pos = element:getAbsolutePosition()

        if (isMouseInPosition(pos.x + inheritedBounds.x.min, pos.y + inheritedBounds.y.min, inheritedBounds.x.max, inheritedBounds.y.max)) then
            local obstructingChild = element:getObstructingChild()

            if (obstructingChild) then
                if (obstructingChild:getProperty("click_propagate")) then
                    if (element:getClickEnabled()) then
                        local clickArea = element:getAbsoluteClickArea()
                        
                        if (isMouseInPosition(clickArea.x, clickArea.y, clickArea.width, clickArea.height)) then
                            if (not isFocusedElement(element)) then
                                table.insert(core.dxFocusedElements, element)
                            end

                            return element["click"..button:gsub("^%l", string.upper)](element, true)
                        end
                    end
                end

                if (obstructingChild:getClickEnabled()) then
                    local clickArea = obstructingChild:getAbsoluteClickArea()
                    
                    if (isMouseInPosition(clickArea.x, clickArea.y, clickArea.width, clickArea.height)) then
                        if (not isFocusedElement(obstructingChild)) then
                            table.insert(core.dxFocusedElements, obstructingChild)
                        end
                        
                        return obstructingChild["click"..button:gsub("^%l", string.upper)](obstructingChild, true)
                    end
                end
            end

            if (not isFocusedElement(element)) then
                table.insert(core.dxFocusedElements, element)
            end           

            element["click"..button:gsub("^%l", string.upper)](element, true)
            return   
        end
    end

    return false
end