-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxWindow = inherit(DxElement)
-- *******************************************************************

function DxWindow:constructor(titleText, titleHeight, scrollbarX, scrollbarY, scrollbarSize)
    self.type = DX_WINDOW

    self.titlebar = {
        text = titleText or "Window",
        height = titleHeight or 20
    }

    self.scrollbar = {
        size = tonumber(scrollbarSize) or 20
    }
    
    if (scrollbarX) then
        self.scrollbar.x = {
            element = DxScrollBar:new(0, self.height - self.scrollbar.size, self.width, self.scrollbar.size, false, self)
        }

        self.scrollbar.x.element.__internal = true
    end

    if (scrollbarY) then
        self.scrollbar.y = {
            element = DxScrollBar:new(self.width - self.scrollbar.size, 0 + self.titlebar.height, self.scrollbar.size, self.height - self.titlebar.height, false, self)
        }

        self.scrollbar.y.element.__internal = true
    end    
    
    self.scrollpane = DxScrollPane:new(0, self.titlebar.height, self.width - (self.scrollbar.y and self.scrollbar.size or 0), self.height - self.titlebar.height - (self.scrollbar.x and self.scrollbar.size or 0), false, self)
    self.scrollpane:setProperty("force_in_bounds", true)

    if (scrollbarX) then
        self.scrollpane:setScrollBar(self.scrollbar.x.element)
    end

    if (scrollbarY) then
        self.scrollpane:setScrollBar(self.scrollbar.y.element)
    end

    self:addRenderFunction(self.draw)

    -- If we create another dx-element as a child of this one, set it as internal
    -- Note: scrollbars have already been set as internal above (if created)
    self.scrollpane.__internal = true
    -- ...
end

-- *******************************************************************

function DxWindow:draw()
    local backgroundColor = self.style:getColor("background")
    local textColor = self.style:getColor("text")
    local titlebarColor = self.style:getColor("titlebar")
    local titlebarTextColor = self.style:getColor("titlebar_text")

    dxDrawRectangle(self.x, self.y, self.width, self.titlebar.height, tocolor(titlebarColor.r, titlebarColor.g, titlebarColor.b, titlebarColor.a))
    dxDrawText(self.titlebar.text, self.x, self.y, self.x + self.width, self.y + self.titlebar.height, tocolor(titlebarTextColor.r, titlebarTextColor.g, titlebarTextColor.b, titlebarTextColor.a), 1, "default", "center", "center")
    dxDrawRectangle(self.x, self.y + self.titlebar.height, self.scrollpane.width, self.scrollpane.height, tocolor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a))
end

function DxWindow:onChildAdded(child)
    if (self.scrollpane) then
        child:setParent(self.scrollpane)
    end
end