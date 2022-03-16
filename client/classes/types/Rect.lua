-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Rect = inherit(Dx)

function Rect:constructor(x, y, width, height, color)
    self.type = DX_RECT

    self:addRenderFunction(self.draw)

    iprintd("[Rect] created", self.x, self.y, self.width, self.height, self.color)
end

function Rect:pre_constructor()
    self.minWidth, self.minHeight = 100, 100
end

function Rect:draw()
    dxDrawRectangle(self.absoluteX, self.absoluteY, self.width, self.height, self.color)
end
