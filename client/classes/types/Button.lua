-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Button = inherit(Dx)
inherit(Text, Button)

function Button:constructor(x, y, width, height, color)
    self.type = DX_BUTTON

    self:setText("Button")
    self:setTextAlign("x", "center")
    self:setTextAlign("y", "center")
end

function Button:pre_constructor()
end

function Button:draw(x, y)
    dxDrawRectangle(x, y, self.width, self.height, self.color)
    dxDrawText(self.text.string, x, y, x + self.width, y + self.height, self.text.color, 1, 1, "default", self.text.align.x, self.text.align.y)
end
