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

    local buttonColor = self.style:getColor("button")

    self.negativeButton.style:setColor("background", buttonColor.r, buttonColor.g, buttonColor.b)
    self.positiveButton.style:setColor("background", buttonColor.r, buttonColor.g, buttonColor.b) 

    self.trackbar = DxRect:new(self.x + (not self:isVertical() and self.buttonSize or 0), self.y + (self:isVertical() and self.buttonSize or 0), self.width - (not self:isVertical() and (self.buttonSize * 2) or 0), self.height - (self:isVertical() and self.buttonSize * 2 or 0), false, self)
    
    local trackbarColor = self.style:getColor("trackbar")
    self.trackbar.style:setColor("background", trackbarColor.r, trackbarColor.g, trackbarColor.b)
    self.trackbar:setDraggableChildren(true)

    self.thumb = DxRect:new(0, 0, self:isVertical() and self.width or 0, not self:isVertical() and self.height or 0, false, self.trackbar)
    
    local thumbColor = self.style:getColor("thumb")
    self.thumb.style:setColor("background", thumbColor.r, thumbColor.g, thumbColor.b)
    self.thumb:setProperty("force_in_bounds", true)

    -- If we create another dx-element as a child of this one, set it as internal
    self.negativeButton.__internal = true
    self.positiveButton.__internal = true
    self.trackbar.__internal = true
    self.thumb.__internal = true
    -- ...
end

-- *******************************************************************

function DxScrollBar:isVertical()
    return self.orientation == "vertical"
end

-- *******************************************************************

function DxScrollBar:setThumbSize(size)
    local vert = self:isVertical()

    self.thumb:setSize(not vert and size or nil, vert and size or nil)
end

function DxScrollBar:getThumbSize()
    return self:isVertical() and self.thumb.height or self.thumb.width
end

-- *******************************************************************

function DxScrollBar:getThumbPosition()
    local isVertical = self:isVertical()
    local pos = (isVertical) and (self.thumb.y - self.trackbar.y) or (self.thumb.x - self.trackbar.x)

    return pos
end

function DxScrollBar:setThumbPosition(pos)
    self.thumb[self:isVertical() and "baseY" or "baseX"] = pos
    return true
end

function DxScrollBar:getMaxThumbPosition()
    return (self:isVertical()) and (self.thumb.height - self.trackbar.height) or (self.thumb.width - self.trackbar.width)
end

-- *******************************************************************

function DxScrollBar:getTrackbarSize()
    return self:isVertical() and self.trackbar.height or self.trackbar.width
end

-- *******************************************************************

function DxScrollBar:onSizeUpdated()
    if (self.negativeButton) then
        self.negativeButton:setPosition(0, 0)
    end

    if (self.positiveButton) then
        self.positiveButton:setPosition(self:isVertical() and 0 or self.width - self.buttonSize, self:isVertical() and self.height - self.buttonSize or 0)
    end

    if (self.trackbar) then
        self.trackbar:setPosition((not self:isVertical() and self.buttonSize or 0), (self:isVertical() and self.buttonSize or 0))
        self.trackbar:setSize(self.width - (not self:isVertical() and (self.buttonSize * 2) or 0), self.height - (self:isVertical() and self.buttonSize * 2 or 0))
    end
end