-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Rect = inherit(Dx)

function Rect:constructor(x, y, width, height, color)
    self.type = DX_RECT
end

function Rect:pre_constructor()
    self.type = DX_RECT
end

function Rect:draw(x, y)
    local state = self:getState()
    dxDrawRectangle(x, y, self.width, self.height, tocolor(self.styles.background[state][1], self.styles.background[state][2], self.styles.background[state][3], self.styles.background[state][4]))
end
