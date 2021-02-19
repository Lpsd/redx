-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxRect = inherit(DxElement)
-- *******************************************************************

function DxRect:constructor()
    self.type = DX_RECT
    self:addRenderFunction(self.drawRect)
end

-- *******************************************************************

function DxRect:drawRect()
    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(self.color.realtime.r, self.color.realtime.g, self.color.realtime.b, self.color.realtime.a))
end