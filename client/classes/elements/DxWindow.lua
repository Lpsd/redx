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

    self:addRenderFunction(self.draw)
end

-- *******************************************************************

function DxWindow:draw()
    local backgroundColor = self.style:getColor("background")
    local textColor = self.style:getColor("text")
    local titlebarColor = self.style:getColor("titlebar")
    local titlebarTextColor = self.style:getColor("titlebar_text")

    dxDrawRectangle(self.x, self.y, self.width, self.titlebar.height, tocolor(titlebarColor.r, titlebarColor.g, titlebarColor.b, titlebarColor.a))
    dxDrawText(self.titlebar.text, self.x, self.y, self.x + self.width, self.y + self.titlebar.height, tocolor(titlebarTextColor.r, titlebarTextColor.g, titlebarTextColor.b, titlebarTextColor.a), 1, "default", "center", "center")
    dxDrawRectangle(self.x, self.y + self.titlebar.height, self.width, self.height - self.titlebar.height, tocolor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a))
end

function DxWindow:onChildAdded(child)
    if (self.scrollpane) then
        child:setParent(self.scrollpane)
    end
end