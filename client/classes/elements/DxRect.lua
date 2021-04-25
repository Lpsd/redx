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
    local color = self.style:getColor("background")
    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(color.r, color.g, color.b, color.a))
end