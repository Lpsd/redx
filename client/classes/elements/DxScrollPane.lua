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
    self:addRenderFunction(self.processUpdate, true)
    self:addRenderFunction(self.processScrollbars)

    self.scrollbars = {}
    self.childIsDragging = false

    self.childPropertyListeners = {
        "update",
        "baseX",
        "baseY"
    }

    self.drawOffset = {
        x = 0,
        y = 0
    }

    self.fOnPropertyChange = bind(self.onPropertyChange, self)

    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(self, self.fOnPropertyChange)
    self:setClickPropagationEnabled(true)

    self:setProperty("draggable_children", true)
end

-- *******************************************************************

function DxScrollPane:processScrollbars()
    local bounds = self:getInheritedBounds()

    local scrollbarX, scrollbarY = self.scrollbars.x, self.scrollbars.y

    if (scrollbarX) then
        local trackbarSize = scrollbarX:getTrackbarSize()
        local overflow = (self.width / bounds.x.max)

        if (not scrollbarX.thumb.dragging) then
            scrollbarX:setThumbSize(math.min(trackbarSize * overflow, trackbarSize))
        end

        local offset = self.drawOffset.x
        self.drawOffset.x = -scrollbarX:getThumbPosition() * (bounds.x.max / trackbarSize)
        
        if (self.drawOffset.x ~= offset) then
            self:updateRenderTarget()
        end
    end

    if (scrollbarY) then
        local trackbarSize = scrollbarY:getTrackbarSize()
        local overflow = (self.height / bounds.y.max)

        if (not scrollbarY.thumb.dragging) then
            scrollbarY:setThumbSize(math.min(trackbarSize * overflow, trackbarSize))
        end

        local offset = self.drawOffset.y
        self.drawOffset.y = -scrollbarY:getThumbPosition() * (bounds.y.max / trackbarSize)

        if (self.drawOffset.y ~= offset) then
            self:updateRenderTarget()
        end
    end
end

-- *******************************************************************

function DxScrollPane:getScrollBar()
    return self.scrollbar
end

function DxScrollPane:setScrollBar(scrollbar)
    if (not isDxElement(scrollbar)) then
        return false
    end

    local orientation = scrollbar:isVertical() and "y" or "x"

    if (self.scrollbars[orientation]) then
        Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):removeHandler(self.scrollbars[orientation].thumb, self.fOnPropertyChange)
        self.scrollbars[orientation].thumb:removePropertyListener(orientation)
    end

    self.scrollbars[orientation] = scrollbar
    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(scrollbar.thumb, self.fOnPropertyChange)
    scrollbar.thumb:addPropertyListener(orientation)
    return true
end

-- *******************************************************************

function DxScrollPane:processUpdate()
    for i, child in ipairs(self:getInheritedChildren()) do
        if (child.dragging) then
            self.childIsDragging = true
            return self:updateRenderTarget()
        end
    end

    self.childIsDragging = false

    if (self.scrollbars.x) then
        if (self.scrollbars.x.thumb.dragging) then
            return self:updateRenderTarget()
        end
    end

    if (self.scrollbars.y) then
        if (self.scrollbars.y.thumb.dragging) then
            return self:updateRenderTarget()
        end
    end
end

-- *******************************************************************

function DxScrollPane:drawRenderTarget()
    if (not self.renderTarget) then
        return false
    end

    local color = self.style:getColor("background")

    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(color.r, color.g, color.b, color.a))

    dxSetBlendMode("add")       -- Set 'add' when drawing the render target on the screen
    dxDrawImage(self.x, self.y, self.width, self.height, self.renderTarget)
    dxSetBlendMode("blend")     -- Restore default blending
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

    local renderer = Renderer:getInstance()

    for i = #self.children, 1, -1 do
        local child = self.children[i]
        local offsetX, offsetY = self.drawOffset.x, self.drawOffset.y

        local pos = { x = child.baseX + offsetX, y = child.baseY + offsetY}
        local bounds = child:getInheritedBounds()
        
        if (pos.x + bounds.x.min < self.width) and (pos.y + bounds.y.min < self.height) and (pos.x > -bounds.x.max) and (pos.y > -bounds.y.max) then
            child:setPositionOffset(-self.x + offsetX, -self.y + offsetY)
            renderer:render({child})
            child:setPositionOffset(0, 0)   
        end
    end

    dxSetBlendMode("blend") -- Restore default blending
    dxSetRenderTarget() -- End render target drawing
end
