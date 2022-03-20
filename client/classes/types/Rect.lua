-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Rect = inherit(Dx)

function Rect:constructor(x, y, width, height, color)
    self.type = DX_RECT
end

function Rect:pre_constructor()
end

function Rect:draw(x, y)
    dxDrawRectangle(x, y, self.width, self.height, self.color)
end
