-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxWindow = inherit(DxElement)
-- *******************************************************************

function DxWindow:constructor(titleText, titleHeight)
    self.type = DX_WINDOW

    self.titlebar = {
        text = titleText or "Window",
        height = titleHeight or 20
    }
    
    self.scrollpane = DxScrollPane:new(0, self.titlebar.height, self.width, self.height - self.titlebar.height, false, self)
    self.scrollpane:setProperty("force_in_bounds", true)

    self:setColor(33, 33, 33)

    self:addRenderFunction(self.draw)
end

-- *******************************************************************

function DxWindow:draw()
    dxDrawRectangle(self.x, self.y, self.width, self.titlebar.height, tocolor(self.color.realtime.r - 9, self.color.realtime.g - 9, self.color.realtime.b - 9, self.color.realtime.a))
    dxDrawText(self.titlebar.text, self.x, self.y, self.x + self.width, self.y + self.titlebar.height, tocolor(self.textColor.realtime.r, self.textColor.realtime.g, self.textColor.realtime.b, self.textColor.realtime.a), 1, "default", "center", "center")
    dxDrawRectangle(self.x, self.y + self.titlebar.height, self.width, self.height - self.titlebar.height, tocolor(self.color.realtime.r, self.color.realtime.g, self.color.realtime.b, self.color.realtime.a))
end

function DxWindow:onChildAdded(child)
    if (self.scrollpane) then
        child:setParent(self.scrollpane)
    end
end