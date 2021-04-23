-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxScrollPane = inherit(DxElement)
-- *******************************************************************

function DxScrollPane:constructor()
    self.type = DX_SCROLLPANE
    self.renderTarget = dxCreateRenderTarget(self.width, self.height, true)

    self:setClickEnabled(false)

    self.renderWithChildren = false

    self:addRenderFunction(self.drawRenderTarget)
    self:addRenderFunction(self.processUpdate)

    self.scrollbar = false

    self.color.default.a = 0

    self.childPropertyListeners = {
        "update",
        "baseX",
        "baseY"
    }

    self.fOnPropertyChange = bind(self.onPropertyChange, self)

    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(self, self.fOnPropertyChange)
    self:setClickPropagationEnabled(true)

    self:setProperty("draggable_children", true)
end

-- *******************************************************************

function DxScrollPane:getScrollBar()
    return self.scrollbar
end

function DxScrollPane:setScrollBar(scrollbar)
    if (scrollbar ~= false) and (scrollbar ~= nil) and (not isDxElement(scrollbar)) then
        return false
    end

    if (isDxElement(self.scrollbar)) then
        self.scrollbar:destroy()
    end

    self.scrollbar = scrollbar
    return true
end

-- *******************************************************************

function DxScrollPane:processUpdate()
    for i, child in ipairs(self:getInheritedChildren()) do
        if (child.dragging) then
            return self:updateRenderTarget()
        end
    end
end

-- *******************************************************************

function DxScrollPane:drawRenderTarget()
    if (not self.renderTarget) then
        return false
    end

    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(self.color.realtime.r, self.color.realtime.g, self.color.realtime.b, self.color.realtime.a))
    dxDrawImage(self.x, self.y, self.width, self.height, self.renderTarget)
end

-- *******************************************************************

function DxScrollPane:onChildAdded(child)
    self:hookChild(child)
end

function DxScrollPane:onChildRemoved(child)
    self:unhookChild(child)
end

function DxScrollPane:onChildInherited(child)
    self:hookChild(child)
end
function DxScrollPane:onChildDisinherited(child)
    self:unhookChild(child)
end

function DxScrollPane:hookChild(child)
    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(child, self.fOnPropertyChange)

    for i, property in ipairs(self.childPropertyListeners) do
        child:addPropertyListener(property)
    end

    self:updateRenderTarget()
end

function DxScrollPane:unhookChild(child)
    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):removeHandler(child, self.fOnPropertyChange)

    for i, property in ipairs(self.childPropertyListeners) do
        child:removePropertyListener(property)
    end

    self:updateRenderTarget()
end

-- *******************************************************************

function DxScrollPane:onPropertyChange(property, oldValue, newValue)
    self:updateRenderTarget()
end

-- *******************************************************************

function DxScrollPane:updateRenderTarget()
    if isElement(self.renderTarget) then
        destroyElement(self.renderTarget)
    end

    if (not isElement(self.renderTarget)) then
        self.renderTarget = dxCreateRenderTarget(self.width, self.height, true)
    end

    dxSetRenderTarget(self.renderTarget, true) -- Start render target drawing
    dxSetBlendMode("modulate_add")  -- Set blend mode

    for i = #self.children, 1, -1 do
        local child = self.children[i]
        child:setPositionOffset(-self.x, -self.y)
        child:render(true)
        child:setPositionOffset(0, 0)
    end

    dxSetBlendMode("blend") -- Restore default blending
    dxSetRenderTarget() -- End render target drawing
end