-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Dx = inherit(Class)

function Dx:constructor()
    if (instanceof(self, Dx, true)) then
        error("Cannot create a direct instance of Dx, use Rect instead")
        return self:delete()
    end
end

function Dx:virtual_constructor(x, y, width, height, color, parent, name)
    
    if (isVector(x)) then
        width = y
        x, y = x.x, x.y
    end

    if (isVector(width)) then
        color = height
        width, height = width.x, width.y
    end

    parent = isDx(parent) and parent or DxRootInstance

    self.propertyListeners = {}
    self.properties = {}

    -- Used for property listeners
    local mt = getmetatable(self)
    mt.__newindex = self.set
    mt.__index = self.get
    setmetatable(self, mt)

    self.type = DX_BASE
    self.name = name

    self.element = createElement("dx")
    self.index = -1

    self.parent = false
    self.children = {}

    self.renderFunctions = {
        render = {},
        preRender = {}
    }

    self.minWidth, self.minHeight = 0, 0

    self.click = {
        left = {
            func = bind(self.onClickLeft, self),
            state = false,
            dragging = false,
            propagated = false,
            pos = {
                x = 0,
                y = 0
            },
            offset = {
                x = 0,
                y = 0
            }
        },
        right = {
            func = bind(self.onClickRight, self),
            state = false,
            dragging = false,
            propagated = false,
            pos = {
                x = 0,
                y = 0
            },
            offset = {
                x = 0,
                y = 0
            }
        },
        middle = {
            func = bind(self.onClickMiddle, self),
            state = false,
            dragging = false,
            propagated = false,
            pos = {
                x = 0,
                y = 0
            },
            offset = {
                x = 0,
                y = 0
            }
        }
    }

    self.frozen = {
        x = false,
        y = false
    }

    self.properties = deepcopy(DxProperties)

    if (self.pre_constructor) then
        self:pre_constructor()
    end

    self.x, self.y = tonumber(x) or 0, tonumber(y) or 0
    self.absoluteX, self.absoluteY = self.x, self.y

    self.width, self.height = tonumber(width) and math.max(self.minWidth, width) or self.minWidth, tonumber(width) and math.max(self.minHeight, height) or self.minHeight

    self.color = tonumber(color) or tocolor(33, 33, 33)

    self:addRenderFunction(self.checkForCanvas, true)
    self:addRenderFunction(self.updatePosition, true)

    local func = bind(self.onVisualPropertyChange, self)
    self:addPropertyListener("x", func, false)
    self:addPropertyListener("y", func, false)
    self:addPropertyListener("width", func, false)
    self:addPropertyListener("height", func, false)
    self:addPropertyListener("index", func, false)
    self:addPropertyListener("children", func, false)
    self:addPropertyListener("parent", func, false)
    self:addPropertyListener("canvas", func, false)

    self.lastLogMs = 0
    self.logDelayMs = 3000

    DxInstances[#DxInstances + 1] = self

    if (parent) then
        self:setParent(parent)
    end
end

function Dx:log(...)
    if (getTickCount() <= self.lastLogMs + self.logDelayMs) then
        return false
    end

    iprintd(...)
    self.lastLogMs = getTickCount()
end

function Dx:onVisualPropertyChange(property)
    if (self.canvas) then
        self.canvas:redraw()
    end
end

function Dx:get(property)
    local class = getmetatable(self).__class

    if (rawget(self, "propertyListeners")[property]) then
        return (class.properties) and (class.properties[property]) or rawget(self, "properties")[property] or rawget(self, property)
    end

    return class[property] or rawget(self, property)
end

function Dx:set(property, newValue)
    local func = rawget(self, "propertyListeners")[property]

    if (func) then
        local properties = rawget(self, "properties")
        
        rawset(self, property, nil)

        if (properties[property] ~= newValue) then
            properties[property] = newValue
            rawset(self, "properties", properties)

            if (self.name == "rect") then
                iprintd(self.name, property, "updated")
            end

            if (type(func) == "function") then
                func(property)
            end
        end

        return
    end

    rawset(self, property, newValue)
end

function Dx:pre_draw(x, y)
    x, y = tonumber(x) or self.absoluteX, tonumber(y) or self.absoluteY

    if (type(self.draw) ~= "function") then
        return false
    end

    self:draw(x, y)
end

function Dx:setParent(parent)
    if (self:isRootInstance()) then
        return false
    end

    if (type(parent) == "table") and (not isDx(parent)) then
        return false
    end

    parent = (not parent) and DxRootInstance or parent

    -- Remove self from old parent before setting new parent
    if (isDx(self.parent)) then
        self.parent:removeChild(self)
    end

    self.parent = parent
    parent:addChild(self)

    self:checkForCanvas()

    self:updatePosition(true)
    parent:doPropagate("onForceUpdatePosition", true)

    return true
end

function Dx:addChild(child)
    if (not isDx(child)) or (self:isChild(child, false)) then
        return false
    end

    table.insert(self.children, 1, child)
    child:bringToFront()

    return true
end

function Dx:removeChild(child)
    if (not isDx(child)) then
        return false
    end

    for i, c in ipairs(self.children) do
        if (child == c) then
            return table.remove(self.children, i)
        end
    end

    self:updateIndex(true)

    return false
end

function Dx:setIndex(index)
    if (self:isRootInstance()) then
        return false
    end

    index = tonumber(index)

    if (not index) or (index <= 0) then
        return false
    end

    local currentIndex = tonumber(self:getIndex(true))

    if (currentIndex) then
        table.remove(self.parent.children, currentIndex)
    end

    table.insert(self.parent.children, index, self)

    self.parent:updateIndex(true)

    return true
end

function Dx:updateIndex(update_children)
    update_children = (type(update_children) ~= "boolean") and true or update_children

    self.index = self:getIndex(true)

    for i, child in ipairs(self.children) do
        child:updateIndex(true)
    end
end

function Dx:getIndex(lookup)
    if (self:isRootInstance()) then
        return false
    end

    if (not lookup) then
        return self.index
    end

    for i, instance in ipairs(self.parent.children) do
        if (instance == self) then
            return i
        end
    end

    return false
end

function Dx:setName(name)
    if (type(name) ~= "string") then
        return false
    end

    self.name = name
end

function Dx:getName()
    return self.name
end

function Dx:isTopLevel()
    return (self.parent == DxRootInstance)
end

function Dx:isRootInstance()
    return (not DxRootInstance) or (self == DxRootInstance)
end

function Dx:preRender()
    for func, data in pairs(self.renderFunctions.preRender) do
        func(unpack(data.args))
    end

    for i = 1, #self.children do
        self.children[i]:preRender()
    end
end

function Dx:render(originCanvas, x, y)
    for func, data in pairs(self.renderFunctions.render) do
        func(unpack(data.args))
    end

    local draw = (not self.canvas) or (self.canvas == originCanvas)

    if (draw) then
        local ancestorOffset = self:getAncestorOffset(originCanvas)
        self:pre_draw(
            (originCanvas and originCanvas ~= DxRootInstance) and (self.x + ancestorOffset.x) or self.absoluteX,
            (originCanvas and originCanvas ~= DxRootInstance) and (self.y + ancestorOffset.y) or self.absoluteY
        )
    end

    if (not originCanvas) or (self.canvas == originCanvas) then
        for i = 1, #self.children do
            local child = self.children[i]
            self.children[i]:render(originCanvas)
        end
    end
end

function Dx:addRenderFunction(func, preRender, protected, ...)
    if (type(func) ~= "function") then
        return false
    end

    func = bind(func, self)

    local renderType = preRender and "preRender" or "render"

    if (self.renderFunctions[renderType][func]) then
        iprintd("[addRenderFunction] Render function already exists", string.format("(priority: %s)", renderType), func)
        return false
    end

    self.renderFunctions[renderType][func] = {
        protected = protected,
        args = {...}
    }

    return true
end

function Dx:removeRenderFunction(func, preRender)
    if (type(func) ~= "function") then
        return false
    end

    func = bind(func, self)

    local renderType = preRender and "preRender" or "render"

    if (not self.renderFunctions[renderType][func]) then
        iprintd(
            "[removeRenderFunction] Render function doesn't exist",
            string.format("(priority: %s)", renderType),
            func
        )
        return false
    end

    self.renderFunctions[renderType][func] = nil
    return true
end

function Dx:addPropertyListener(property, func, bindFunc)
    if (self.propertyListeners[property]) then
        return iprintd(
            "[addPropertyListener] Property listener already active",
            string.format("property: %s", property)
        ) and false
    end

    if (type(bindFunc) == "nil") then
        bindFunc = true
    end

    self.propertyListeners[property] = true

    if (type(func) == "function") then
        self.propertyListeners[property] = (bindFunc) and bind(func, self) or func
    end

    self.properties[property] = self[property]

    self[property] = nil

    return true
end

function Dx:removePropertyListener(property)
    if (not self.propertyListeners[property]) then
        return iprintd(
            "[removePropertyListener] Property listener does not exist",
            string.format("property: %s", property)
        ) and false
    end

    self.propertyListeners[property] = nil
    return true
end

function Dx:getType()
    return DxTypes[self.type] and "DX_" .. DxTypes[self.type] or false
end

function Dx:getEnumerableType()
    return self.type
end

function Dx:getPosition(absolute)
    if (type(absolute) ~= "boolean") then
        absolute = true
    end

    if (not absolute) then
        return self.x, self.y
    end

    return self.absoluteX, self.absoluteY
end

function Dx:updatePosition(force)
    self.previousX, self.previousY = self.x, self.y

    local offset = {
        x = self.click.left.offset.x,
        y = self.click.left.offset.y
    }

    if (self.click.left.dragging) then
        local cx, cy = getAbsoluteCursorPosition()
        self.click.left.offset.x, self.click.left.offset.y = (self.click.left.pos.x - cx), (self.click.left.pos.y - cy)
    end

    local pos = {
        x = self.x + (offset.x - self.click.left.offset.x),
        y = self.y + (offset.y - self.click.left.offset.y)
    }

    local force = self:getProperty("force_in_bounds")
    local force_inherited = self:getProperty("force_in_bounds_inherited")

    if (force == true or force_inherited == true) and (isDx(self.parent)) then
        local parentBounds = self.parent:getBounds()
        local bounds = (force_inherited) and self:getInheritedBounds() or self:getBounds()

        if (pos.x + bounds.min.x < parentBounds.min.x) then
            pos.x = (parentBounds.min.x - bounds.min.x)
        end

        if (pos.y + bounds.min.y < parentBounds.min.y) then
            pos.y = (parentBounds.min.y - bounds.min.y)
        end

        if (pos.x + bounds.max.x > parentBounds.max.x) then
            pos.x = (parentBounds.max.x - bounds.max.x)
        end

        if (pos.y + bounds.max.y > parentBounds.max.y) then
            pos.y = (parentBounds.max.y - bounds.max.y)
        end
    end

    if (self.forceUpdatePosition == true) or ((not force) and ((self.x ~= pos.x) or (self.y ~= pos.y) or true)) then
        self.forceUpdatePosition = false
        self:setPosition(pos.x, pos.y)
    end
end

function Dx:setPosition(x, y)
    if (self:isRootInstance()) then
        return false
    end

    local pos = {
        x = tonumber(x) or 0,
        y = tonumber(y) or 0
    }

    if (not pos.x) or (not pos.y) then
        return false
    end

    local previousX, previousY = self.x, self.y
    self.x, self.y = (self.frozen.x) and self.x or pos.x, (self.frozen.y) and self.y or pos.y

    local ancestorOffset = self:getAncestorOffset()

    self.absoluteX, self.absoluteY =
        (self.frozen.x) and self.absoluteX or (pos.x + ancestorOffset.x),
        (self.frozen.y) and self.absoluteY or (pos.y + ancestorOffset.y)

    self:doPropagate("onForceUpdatePosition", true)
    return true
end

function Dx:getAncestorOffset(stopAt)
    local ancestorOffset = {
        x = 0,
        y = 0
    }

    for i, ancestor in ipairs(self:getAncestors()) do
        ancestorOffset.x, ancestorOffset.y = ancestorOffset.x + ancestor.x, ancestorOffset.y + ancestor.y

        if (stopAt == ancestor) then
            break
        end
    end

    return ancestorOffset
end

function Dx:getAncestors(tbl)
    tbl = (type(tbl) == "table") and tbl or {}

    local parent = self.parent

    if (not parent) then
        return tbl
    end

    tbl[#tbl + 1] = parent
    return parent:getAncestors(tbl)
end

function Dx:isAncestor(ancestor)
    if (not isDx(ancestor)) then
        return false
    end

    for i, a in ipairs(self:getAncestors()) do
        if (ancestor == a) then
            return true
        end
    end

    return false
end

function Dx:getCanvas()
    local ancestors = self:getAncestors()

    for i = 1, #ancestors do
        local ancestor = ancestors[i]
        if (ancestor.type == DX_CANVAS) then
            return ancestor
        end
    end

    return false
end

function Dx:checkForCanvas()
    local canvas = self:getCanvas()

    if (not canvas) then
        return false
    end

    self.canvas = canvas
end

function Dx:onClick(button, state, propagated, propagatedInstance)
    self.click[button].state = state
    self.click[button].propagated = propagated
    self.click[button].func(state)

    local ancestorDragEnabled = false

    for i, ancestor in ipairs(self:getAncestors()) do
        if (ancestor:getProperty("drag_children") == true) then
            ancestorDragEnabled = true
            break
        end
    end

    if
        (not self:isRootInstance() and self.type ~= DX_CANVAS) and
            (ancestorDragEnabled or (self:getProperty("drag") == true))
     then
        if (not propagated) or (propagatedInstance:getProperty("drag_propagate") == true) then
            self.click[button].dragging = state
        end
    end

    self.click[button].pos.x, self.click[button].pos.y = getAbsoluteCursorPosition()
    self.click[button].offset.x, self.click[button].offset.y = 0, 0
end

function Dx:onClickLeft(state)
    if (state) and (self:getProperty("click_order") == true) then
        self:bringToFront()

        if (self:getProperty("click_order_propagate") == true) then
            for i, ancestor in ipairs(self:getAncestors()) do
                ancestor:bringToFront()
            end
        end
    end

    iprintd("clicked left", state, self:getName())
end

function Dx:onClickRight(state)
    iprintd("clicked right", state, self:getName())
end

function Dx:onClickMiddle(state)
    iprintd("clicked middle", state, self:getName())
end

function Dx:onMouseUp(button)
    if (not self.click[button]) then
        return false
    end

    self.click[button].dragging = false
end

function Dx:sendToBack()
    self:setIndex(1)
end

function Dx:bringToFront()
    if (not isDx(self.parent)) then
        return false
    end

    self:setIndex(#self.parent.children)
end

function Dx:getBounds(absolute)
    if (type(absolute) ~= "boolean") then
        absolute = false
    end

    return {
        min = {
            x = (absolute) and self.absoluteX or 0,
            y = (absolute) and self.absoluteY or 0
        },
        max = {
            x = self.width + (absolute and self.absoluteX or 0),
            y = self.height + (absolute and self.absoluteY or 0)
        }
    }
end

function Dx:getInheritedBounds(absolute)
    local bounds = self:getBounds(absolute)

    for i, child in ipairs(self:getChildren(true)) do
        local x, y = child.absoluteX, child.absoluteY

        if (not absolute) then
            x, y = (x - self.absoluteX), (y - self.absoluteY)
        end

        if (x < bounds.min.x) then
            bounds.min.x = x
        end

        if (y < bounds.min.y) then
            bounds.min.y = y
        end

        if (x + child.width) > bounds.max.x then
            bounds.max.x = (x + child.width)
        end

        if (y + child.height) > bounds.max.y then
            bounds.max.y = (y + child.height)
        end
    end

    return bounds
end

function Dx:getChildren(inherited)
    if (type(inherited) ~= "boolean") then
        inherited = false
    end

    if (not inherited) then
        return self.children
    end

    local children = {}

    for i, child in ipairs(self.children) do
        children[#children + 1] = child

        for i, grandChild in ipairs(child:getChildren(true)) do
            children[#children + 1] = grandChild
        end
    end

    return children
end

function Dx:isChild(child, inherited)
    if (type(inherited) ~= "boolean") then
        inherited = false
    end

    local children = self:getChildren(inherited)

    for i, c in ipairs(children) do
        if (child == c) then
            return true
        end
    end

    return false
end

function Dx:setProperty(name, val)
    if (type(name) ~= "string") then
        return false
    end

    self.properties[name] = val
    return true
end

function Dx:getProperty(name)
    return self.properties[name]
end

function Dx:isClicked()
    return (self.click.left.state) or (self.click.right.state) or (self.click.middle.state)
end

function Dx:getClicked()
    return {
        left = self.click.left.state,
        right = self.click.right.state,
        middle = self.click.middle.state
    }
end

function Dx:doPropagate(method, inherited, ...)
    if (type(inherited) ~= "boolean") then
        inherited = false
    end

    for i, child in ipairs(self:getChildren(inherited)) do
        if (type(child[method]) == "function") then
            child[method](child, self, ...)
        end
    end

    return true
end

function Dx:onForceUpdatePosition(ancestor)
    self.forceUpdatePosition = true
end

function Dx:setFrozen(pos, state)
    if (pos ~= "x") and (pos ~= "y") then
        return false
    end

    if (type(state) ~= "boolean") then
        state = true
    end

    self.frozen[pos] = state
end

function Dx:setCentered(dx, inherited)
    dx = isDx(dx) and dx or self.parent

    if (dx ~= DxRootInstance) and (not isDx(dx)) then
        return false
    end

    if (type(inherited) ~= "boolean") then
        inherited = false
    end

    local bounds = (inherited) and dx:getInheritedBounds() or dx:getBounds()

    local offset = {
        x = 0,
        y = 0
    }

    if (dx ~= self.parent) then
        offset.x, offset.y = (dx.absoluteX - self.absoluteX) + (self.x), (dx.absoluteY - self.absoluteY) + (self.y)
    end

    local pos = {
        x = ((bounds.max.x - bounds.min.x) / 2) - (self.width / 2) + offset.x,
        y = ((bounds.max.y - bounds.min.y) / 2) - (self.height / 2) + offset.y
    }

    return self:setPosition(pos.x, pos.y)
end
