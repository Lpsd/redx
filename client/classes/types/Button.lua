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
    self.type = DX_BUTTON
end

function Button:draw(x, y)
    local state = self:getState()
    dxDrawRectangle(x, y, self.width, self.height, tocolor(self.styles.background[state][1], self.styles.background[state][2], self.styles.background[state][3], self.styles.background[state][4]))
    dxDrawText(self.text.string, x, y, x + self.width, y + self.height, self.text.color, 1, 1, "default", self.text.align.x, self.text.align.y)
end
