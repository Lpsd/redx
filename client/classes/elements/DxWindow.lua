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
        x = {
            enabled = false
        },
        y = {
            enabled = false
        },
        size = tonumber(scrollbarSize) or 20
    }
    
    if (scrollbarX) then
        self:createScrollBar("x")
    end

    if (scrollbarY) then
        self:createScrollBar("y")
    end    
    
    self.scrollpane = DxScrollPane:new(0, self.titlebar.height, self.width - (self.scrollbar.y.enabled and self.scrollbar.size or 0), self.height - self.titlebar.height - (self.scrollbar.x.enabled and self.scrollbar.size or 0), false, self)
    self.scrollpane:setProperty("force_in_bounds", true)
    self.scrollpane:setName("SCROLLPANE1")

    self.scrollpane:addScrollBar(self.scrollbar.x.element)
    self.scrollpane:addScrollBar(self.scrollbar.y.element)


    self:setDragArea(0, 0, self.width, self.titlebar.height)

    self:addRenderFunction(self.draw)

    self.font, self.fontSize = self.style:getFont("titlebar")

    -- If we create another dx-element as a child of this one, set it as internal
    -- Note: scrollbars have already been set as internal above (if created)
    self.scrollpane.__internal = true
    -- ...

    self:addPropertyListener("titlebar")

    self.fOnPropertyChange = bind(self.onPropertyChange, self)
    Core:getInstance():getEventManager():getEventFromName("onDxPropertyChange"):addHandler(self, self.fOnPropertyChange)

    self:recalculateSizeAndPosition()
end

-- *******************************************************************

function DxWindow:draw()
    local backgroundColor = self.style:getColor("background")
    local textColor = self.style:getColor("text")
    local titlebarColor = self.style:getColor("titlebar")
    local titlebarTextColor = self.style:getColor("titlebar_text")

    dxDrawRectangle(self.x, self.y, self.width, self.titlebar.height, tocolor(titlebarColor.r, titlebarColor.g, titlebarColor.b, titlebarColor.a))
    dxDrawText(self.titlebar.text, self.x, self.y, self.x + self.width, self.y + self.titlebar.height, tocolor(titlebarTextColor.r, titlebarTextColor.g, titlebarTextColor.b, titlebarTextColor.a), 1, self.font:getFontBySize(self.fontSize), "center", "center")
    dxDrawRectangle(self.x, self.y + self.titlebar.height, self.scrollpane.width, self.scrollpane.height, tocolor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a))
end

-- *******************************************************************

function DxWindow:onChildAdded(child)
    if (self.scrollpane) then
        child:setParent(self.scrollpane)
    end
end

function DxWindow:onPropertyChange(property, oldValue, newValue)
    if (property == "titlebar") then

    end
end

-- *******************************************************************

function DxWindow:createScrollBar(orientation)
    if (orientation ~= "x") and (orientation ~= "y") or (isElement(self.scrollbar[orientation].element)) then
        return false
    end

    local args = (orientation == "x") and 
        {0, self.height - self.scrollbar.size, self.width, self.scrollbar.size, false, self} or 
        {self.width - self.scrollbar.size, 0 + self.titlebar.height, self.scrollbar.size, self.height - self.titlebar.height, false, self}

    self.scrollbar[orientation].element = DxScrollBar:new(unpack(args))
    self.scrollbar[orientation].element.__internal = true
    self.scrollbar[orientation].enabled = true
end

function DxWindow:setTitlebarHeight(height)
    height = tonumber(height)
    if (not height) then
        return false
    end

    -- Hack to trigger "titlebar" property listener on height change
    local titlebar = self.titlebar
    titlebar.height = height
    self.titlebar = titlebar

    self:recalculateSizeAndPosition()
end

function DxWindow:recalculateSizeAndPosition()
    if (not self.scrollbar) then
        return false
    end

    if (self.scrollbar.x.enabled) then
        self.scrollbar.x.element:setSize(self.width, self.scrollbar.size)
        self.scrollbar.x.element:setPosition(0, self.height - self.scrollbar.size)
    end
    
    if (self.scrollbar.y.enabled) then
        self.scrollbar.y.element:setSize(self.scrollbar.size, self.height - self.titlebar.height)
        self.scrollbar.y.element:setPosition(self.width - self.scrollbar.size, 0 + self.titlebar.height)
    end


    if (self.scrollpane) then
        self.scrollpane:setSize(self.width - (self.scrollbar.y.enabled and self.scrollbar.size or 0), self.height - self.titlebar.height - (self.scrollbar.x.enabled and self.scrollbar.size or 0))
        self.scrollpane:setPosition(0, self.titlebar.height)
    end

    self:setDragArea(0, 0, self.width, self.titlebar.height)
    return true
end

-- *******************************************************************

function DxWindow:onSizeUpdated()
    self:recalculateSizeAndPosition()
end

-- *******************************************************************

function DxWindow:setHorizontalScrollBarEnabled(state)
    self.scrollbar.x.enabled = (type(state) == "boolean") and state or self.scrollbar.x.enabled
    self:recalculateSizeAndPosition()
end

function DxWindow:setVerticalScrollBarEnabled(state)
    self.scrollbar.y.enabled = (type(state) == "boolean") and state or self.scrollbar.x.enabled
    self:recalculateSizeAndPosition()
end