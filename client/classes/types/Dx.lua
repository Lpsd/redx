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

    self.type = DX_BASE

    if (self.pre_constructor) then
        self:pre_constructor()
    end

    parent = isDx(parent) and parent or DxRootInstance

    self.propertyListeners = {}
    self.internalProperties = {}

    -- Used for property listeners
    local mt = getmetatable(self)
    mt.__newindex = self.set
    mt.__index = self.get
    setmetatable(self, mt)

    self.name = name

    self.element = createElement("dx")
    self.index = -1

    self.parent = false

    self.children = {}
    self.inheritedChildren = {}

    self.ancestors = {}

    self.renderFunctions = {
        render = {},
        preRender = {}
    }

    self.bounds = {}
    self.inheritedBounds = {}

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

    self.properties = deepcopy(DxProperties[self:getClassName()] or DxProperties.default)
    self.styles = deepcopy(DxStyles[self:getClassName()] or DxStyles.default)

    self.state = STATE_NORMAL

    self.animations = {}
    self.animationAffectors = {
        ["x"] = {
            {self.updatePosition, true}
        },
        ["y"] = {
            {self.updatePosition, true}
        }
    }

    self.x, self.y = tonumber(x) or 0, tonumber(y) or 0
    self.absoluteX, self.absoluteY = self.x, self.y

    self.width, self.height =
        tonumber(width) and math.max(self.minWidth, width) or self.minWidth,
        tonumber(width) and math.max(self.minHeight, height) or self.minHeight

    color = tonumber(color)

    if (color) then
        self.styles.background.normal = { getRGBA(color) }
    end

    self:addRenderFunction(self.updatePosition, true)
    self:addRenderFunction(self.processAnimations)

    local func = bind(self.onVisualPropertyChange, self)
    self:addPropertyListener("x", func, false)
    self:addPropertyListener("y", func, false)
    self:addPropertyListener("width", func, false)
    self:addPropertyListener("height", func, false)
    self:addPropertyListener("color", func, false)
    self:addPropertyListener("index", func, false)
    self:addPropertyListener("canvas", func, false)
    self:addPropertyListener("state", func, false)

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

function Dx:addAnimation(animation, start)
    if (not animation) or (not instanceof(animation, Animation, true)) then
        return false
    end

    if (type(start) ~= "boolean") then
        start = true
    end

    self.animations[#self.animations + 1] = animation

    if (start) then
        animation:start()
    end

    return true
end

function Dx:removeAnimation(animation)
    if (not animation) or (not instanceof(animation, Animation, true)) then
        return false
    end

    for i = 1, #self.animations do
        local anim = self.animations[i]

        if (anim == animation) then
            table.remove(self.animations, i)
            return true
        end
    end

    return false
end

function Dx:processAnimations()
    local destroy = {}

    for i = 1, #self.animations do
        local animation = self.animations[i]

        if (animation:isDestroyed()) then
            destroy[#destroy + 1] = i
        else
            if (animation.state) and (not animation.finished) then
                animation:run()

                if (animation.onRender) then
                    animation.onRender(self, animation.i)
                end

                if (#animation.i == 1) then
                    self[animation.property] = animation.i[1]

                    local affectors = self.animationAffectors[animation.property]

                    if (affectors) then
                        for j = 1, #affectors do
                            local args = deepcopy(affectors[j])
                            local func = args[1]

                            table.remove(args, 1)
                            func(self, unpack(args))
                        end
                    end
                end
            end
        end
    end

    for i = #destroy, 1, -1 do
        table.remove(self.animations, i)
    end
end

function Dx:onVisualPropertyChange(property)
    if (self.canvas) then
        self.canvas:redraw()
    end
end

function Dx:get(property)
    local class = getmetatable(self).__class

    if (rawget(self, "propertyListeners")[property]) then
        return (class.internalProperties) and (class.internalProperties[property]) or rawget(self, "internalProperties")[property] or
            rawget(self, property)
    end

    return class[property] or rawget(self, property)
end

function Dx:set(property, newValue)
    local func = rawget(self, "propertyListeners")[property]

    if (func) then
        local properties = rawget(self, "internalProperties")

        rawset(self, property, nil)

        if (properties[property] ~= newValue) then
            properties[property] = newValue
            rawset(self, "internalProperties", properties)

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

    self:updateAncestors()
    self:doPropagate(false, "updateAncestors", true)

    self:updateInheritedChildren()
    self:doPropagate(true, "updateInheritedChildren")

    self:checkForCanvas()

    self:updatePosition(true)
    self:doPropagate(true, "updateInheritedBounds", true)

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
    return (self == DxRootInstance)
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

    self.internalProperties[property] = self[property]

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

function Dx:getClassName()
    return DxTypeClasses[DxTypes[self.type]]
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

function Dx:getTopLevelParent()
    return (self.parent == DxRootInstance) and self or self.parent:getTopLevelParent()
end

function Dx:updatePosition(forceUpdate)
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

    if
        (self.previousX ~= (frozen and self.previousX or pos.x) or
            self.previousY ~= (frozen and self.previousY or pos.y)) and
            (force == true or force_inherited == true) and
            (isDx(self.parent))
     then
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

    self.previousX, self.previousY = self.x, self.y

    if ((self.x ~= pos.x) or (self.y ~= pos.y)) or (forceUpdate) then
        self:setPosition(pos.x, pos.y, forceUpdate)
    end
end

function Dx:setPosition(x, y, forceUpdate)
    if (self:isRootInstance()) then
        return false
    end

    if (type(forceUpdate) ~= "boolean") then
        forceUpdate = false
    end

    local pos = {
        x = tonumber(x) or 0,
        y = tonumber(y) or 0
    }

    if (not pos.x) or (not pos.y) then
        return false
    end

    local previousX, previousY = self.x, self.y
    local newX, newY = (self.frozen.x) and self.x or pos.x, (self.frozen.y) and self.y or pos.y

    if (newX ~= previousX) or (newY ~= previousY) or (forceUpdate) then
        if (newX ~= previousX) then
            self.x = newX
        end

        if (newY ~= previousY) then
            self.y = newY
        end

        local ancestorOffset = self:getAncestorOffset()
        self.absoluteX, self.absoluteY = (pos.x + ancestorOffset.x), (pos.y + ancestorOffset.y)

        self:updateBounds()
        self:updateInheritedBounds()

        self:doPropagate(true, "updateInheritedBounds", true)
        self:doPropagate(false, "onForceUpdatePosition", true)
    end

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

function Dx:getAncestors(lookup, tbl)
    if (type(lookup) ~= "boolean") then
        lookup = false
    end

    if (not lookup) then
        return self.ancestors
    end

    tbl = (type(tbl) == "table") and tbl or {}

    local parent = self.parent

    if (not parent) then
        return tbl
    end

    tbl[#tbl + 1] = parent
    return parent:getAncestors(true, tbl)
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

function Dx:inCanvas()
    return self.canvas and true or false
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

    if (not self:isRootInstance() and self.type ~= DX_CANVAS) then
        if (self:getProperty("drag")) or (ancestorDragEnabled) then
            if (not propagated) or (propagatedInstance:getProperty("drag_propagate") == true) then
                self.click[button].dragging = state
            end
        end
    end

    self.click[button].pos.x, self.click[button].pos.y = getAbsoluteCursorPosition()
    self.click[button].offset.x, self.click[button].offset.y = 0, 0

    if (not state) then
        self:onMouseUp(button)
    end
end

function Dx:onClickLeft(state)
    if (state) then
        self.state = (self.click.left.propagated == false) and STATE_SELECTED or self.state

        if (self:getProperty("click_order") == true) then
            self:bringToFront()

            if (self:getProperty("click_order_propagate") == true) then
                for i, ancestor in ipairs(self:getAncestors()) do
                    if (ancestor:getProperty("click_order") == true) then
                        ancestor:bringToFront()
                    end
                end
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
    self.state = (DxHoveredInstance == self) and STATE_HOVERED or STATE_NORMAL
end

function Dx:onMouseEnter()
    self.state = STATE_HOVERED
end

function Dx:onMouseLeave()
    self.state = STATE_NORMAL
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

function Dx:getBounds(absolute, lookup)
    if (type(absolute) ~= "boolean") then
        absolute = false
    end

    if (type(lookup) ~= "boolean") then
        lookup = false
    end

    local tag = (absolute and "absolute" or "relative")

    if (not lookup) and (self.bounds[tag]) then
        return self.bounds[tag]
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

function Dx:getInheritedBounds(absolute, lookup)
    if (type(lookup) ~= "boolean") then
        lookup = false
    end

    local tag = (absolute and "absolute" or "relative")

    if (not lookup) and (self.inheritedBounds[tag]) then
        return self.inheritedBounds[tag]
    end

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

function Dx:updateBounds()
    self.bounds.absolute = self:getBounds(true, true)
    self.bounds.relative = self:getBounds(false, true)
end

function Dx:updateInheritedBounds()
    self.inheritedBounds.absolute = self:getInheritedBounds(true, true)
    self.inheritedBounds.relative = self:getInheritedBounds(false, true)
end

function Dx:updateAncestors()
    self.ancestors = self:getAncestors(true)
end

function Dx:updateInheritedChildren()
    self.inheritedChildren = self:getChildren(true, true)
end

function Dx:getChildren(inherited, lookup)
    if (type(inherited) ~= "boolean") then
        inherited = false
    end

    if (not inherited) then
        return self.children
    end

    if (type(lookup) ~= "boolean") then
        lookup = false
    end

    if (not lookup) then
        return self.inheritedChildren
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

function Dx:getParents(parents)
    local parents = parents or {}

    if (not self.parent) then
        return parents
    end

    parents[#parents + 1] = self.parent

    if (self.parent:isTopLevel()) then
        return parents
    end

    return self.parent:getParents(parents)
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

-- direction: up (true) = parents, down (false) = children
-- inherited: whether to propagate on inherited children or not (doesn't affect parent propagation)
function Dx:doPropagate(direction, method, inherited, ...)
    if (type(direction) ~= "boolean") then
        direction = false
    end

    if (type(inherited) ~= "boolean") then
        inherited = false
    end

    local tbl = (direction) and self:getParents() or self:getChildren(inherited)

    for i, instance in ipairs(tbl) do
        if (type(instance[method]) == "function") then
            instance[method](instance, self, ...)
        end
    end

    return true
end

function Dx:onForceUpdatePosition(ancestor)
    self:updatePosition(true)
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

function Dx:getState(enum)
    return enum and self.state or DxStates[self.state]
end
