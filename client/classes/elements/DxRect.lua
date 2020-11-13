-- Author: Lpsd
-- File: client/classes/elements/DxRect.lua
-- Description: Basic rectangle class

-- *******************************************************************
DxRect = inherit(DxElement)
-- *******************************************************************

function DxRect:constructor()
    self:addRenderFunction(self.drawRect)
end

-- *******************************************************************

function DxRect:drawRect()
    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(self.color.realtime.r, self.color.realtime.g, self.color.realtime.b, self.color.realtime.a))
end