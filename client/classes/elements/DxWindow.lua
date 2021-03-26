-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxWindow = inherit(DxElement)
-- *******************************************************************

function DxWindow:constructor()
    self.type = DX_WINDOW
    
    self.scrollpane = DxScrollPane:new(0, 0, self.width, self.height, false, self)

    self:addRenderFunction(self.draw)
end

-- *******************************************************************

function DxWindow:draw()
    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(self.color.realtime.r, self.color.realtime.g, self.color.realtime.b, self.color.realtime.a))
end

function DxWindow:onChildAdded(child)
    if (child ~= self.scrollpane) then
        child:setParent(self.scrollpane)
    end
end