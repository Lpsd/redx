-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxScrollBar = inherit(DxElement)
-- *******************************************************************

function DxScrollBar:constructor()
    self.orientation = (self.width > self.height) and "horizontal" or "vertical"
    self.type = DX_SCROLLBAR

    self.buttonSize = (self:isVertical() and self.width or self.height)

    self.negativeButton = DxRect:new(0, 0, self.buttonSize, self.buttonSize, false, self)
    self.positiveButton = DxRect:new(self:isVertical() and 0 or self.width - self.buttonSize, self:isVertical() and self.height - self.buttonSize or 0, self.buttonSize, self.buttonSize, false, self)

    self.negativeButton:setColor(66, 66, 66)
    self.positiveButton:setColor(66, 66, 66)  

    self.trackbar = DxRect:new(self.x + (not self:isVertical() and self.buttonSize or 0), self.y + (self:isVertical() and self.buttonSize or 0), self.width - (not self:isVertical() and (self.buttonSize * 2) or 0), self.height - (self:isVertical() and self.buttonSize * 2 or 0), false, self)
    self.trackbar:setColor(33, 33, 33)
    self.trackbar:setDraggableChildren(true)

    self.handle = {
        size = {
            min = (self.buttonSize / 2),
            max = (self.trackbar.height),
            current = self.trackbar.height
        },
        offset = 0
    }

    self.handle.element = DxRect:new(0, 0, self.width, self.handle.size.min, false, self.trackbar)
    self.handle.element:setColor(11, 11, 11)
end

-- *******************************************************************

function DxScrollBar:isVertical()
    return self.orientation == "vertical"
end