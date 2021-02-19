-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxScrollPane = inherit(DxElement)
-- *******************************************************************

function DxScrollPane:constructor()
    self.type = DX_SCROLLPANE
    self.renderTarget = dxCreateRenderTarget(self.width, self.height, true)

    self.renderWithChildren = false

    self:addRenderFunction(self.drawRenderTarget)
    self:addRenderFunction(self.processUpdate)

    self.color.default.a = 50

    self.fOnPropertyChange = bind(self.onPropertyChange, self)

    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(self, self.fOnPropertyChange)
end

-- *******************************************************************

function DxScrollPane:processUpdate()
    for i, child in ipairs(self.children) do
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
    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(child, self.fOnPropertyChange)

    child:addPropertyListener("baseX")
    child:addPropertyListener("baseY")

    self:updateRenderTarget()
end

function DxScrollPane:onChildRemoved(child)
    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):removeHandler(child, self.fOnPropertyChange)

    child:removePropertyListener("baseX")
    child:removePropertyListener("baseY")

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
        child:render()
        child:setPositionOffset(0, 0)
    end

    dxSetBlendMode("blend") -- Restore default blending
    dxSetRenderTarget() -- End render target drawing
end