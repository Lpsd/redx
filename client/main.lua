-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

DxCore = false
DxRootInstance = false
DxHoveredInstance = false

DxInstances = {}

DxProperties = {}
DxStyles = {}

DxStates = {
    "normal",
    "hovered",
    "selected",
    "disabled"
}

DxTypes = {}
DxTypeClasses = {
    ["BASE"] = "Dx",
    ["RECT"] = "Rect",
    ["BUTTON"] = "Button",
    ["CANVAS"] = "Canvas"
}

local function getHoveredInstance(dx, propagated)
    dx = isDx(dx) and dx or DxRootInstance
    propagated = (type(propagated) == "table") and propagated or {}

    local x, y = dx.absoluteX, dx.absoluteY
    local bounds = dx:getInheritedBounds(true)

    if (isMouseInPosition(bounds.min.x, bounds.min.y, (bounds.max.x - bounds.min.x), (bounds.max.y - bounds.min.y))) then
        local hovering_this = isMouseInPosition(dx.absoluteX, dx.absoluteY, dx.width, dx.height)

        for i = #dx.children, 1, -1 do
            local child = dx.children[i]
            local x, y = child.absoluteX, child.absoluteY
            bounds = child:getInheritedBounds(true)

            if
                (isMouseInPosition(
                    bounds.min.x,
                    bounds.min.y,
                    (bounds.max.x - bounds.min.x),
                    (bounds.max.y - bounds.min.y)
                ))
             then
                local next, prop = getHoveredInstance(child, propagated)

                local hovering_child = isMouseInPosition(child.absoluteX, child.absoluteY, child.width, child.height)
                local hovering_next =
                    next and isMouseInPosition(next.absoluteX, next.absoluteY, next.width, next.height) or false

                if
                    (hovering_next) and
                        ((not next.canvas) or
                            (isMouseInPosition(
                                next.canvas.absoluteX,
                                next.canvas.absoluteY,
                                next.canvas.width,
                                next.canvas.height
                            )))
                 then
                    if (hovering_this) then
                        propagated[#propagated + 1] = dx
                    end

                    return next, propagated
                elseif
                    (hovering_child) and
                        ((not child.canvas) or
                            (isMouseInPosition(
                                child.canvas.absoluteX,
                                child.canvas.absoluteY,
                                child.canvas.width,
                                child.canvas.height
                            )))
                 then
                    if (hovering_this) then
                        propagated[#propagated + 1] = dx
                    end

                    return child, propagated
                end
            end
        end

        if (hovering_this) then
            return dx, propagated
        end
    end

    return false
end

local function handleClick(button, state)
    state = (state == "down")
    local instance, propagated = getHoveredInstance()

    local ancestorClickEnabled = true

    for i, ancestor in ipairs(instance:getAncestors()) do
        if (ancestor:getProperty("click_children") == false) then
            ancestorClickEnabled = false
            break
        end
    end

    if (isDx(instance)) and (ancestorClickEnabled) and (instance:getProperty("click") == true) then
        instance:onClick(button, state, false)

        if (instance:getProperty("click_propagate") == true) then
            for i, prop in ipairs(propagated) do
                if (isDx(prop)) then
                    prop:onClick(button, state, true, instance)
                end
            end
        end
    end

    if (not state) then
        for i, inst in ipairs(DxInstances) do
            if (inst:isClicked()) then
                inst:onMouseUp(button)
            end
        end
    end
end

local function handleCursorMove()
    DxHoveredInstance = getHoveredInstance()

    for i, instance in ipairs(DxInstances) do
        if (instance:getState() == "hovered") and (instance ~= DxHoveredInstance) then
            instance:onMouseLeave()
        elseif (instance:getState() ~= "hovered" and instance:getState() ~= "selected") and (instance == DxHoveredInstance) then
            instance:onMouseEnter()
        end
    end
end

local function preRender(dx)
    dx = isDx(dx) and dx or DxRootInstance
    dx:preRender()

    return true
end

local function render(dx)
    dx = isDx(dx) and dx or DxRootInstance
    dx:render()

    return true
end

local function init()
    SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

    DxTypes = getIndexes(DxTypeClasses)
    enum(DxTypes, "DX")

    local states = deepcopy(DxStates)

    for i, state in ipairs(states) do
        states[i] = state:upper()
    end

    enum(states, "STATE")

    Autoloader.loadClasses()

    DxProperties.default = loadClassProperties("default")
    DxStyles.default = loadClassStyles("default")

    -- Load individual class properties and styles
    for i, t in pairs(DxTypeClasses) do
        local properties = loadClassProperties(t)
        local styles = loadClassStyles(t)

        if (properties) then
            DxProperties[t] = properties

            for prop, value in pairs(DxProperties.default) do
                if (type(DxProperties[t][prop]) == "nil") then
                    DxProperties[t][prop] = value
                end
            end
        else
            DxProperties[t] = deepcopy(DxProperties.default)
        end

        if (styles) then
            DxStyles[t] = styles

            for styleType, data in pairs(DxStyles.default) do
                if (type(DxStyles[t][styleType]) == "nil") then
                    DxStyles[t][styleType] = data
                else
                    for style, value in pairs(data) do
                        if (type(DxStyles[t][styleType][style]) == "nil") then
                            DxStyles[t][styleType][style] = value
                        end
                    end
                end
            end
        end
    end

    -- Create the root UI element
    DxRootInstance = Canvas:new(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, tocolor(0, 0, 0, 0), false, "root")

    addEventHandler("onClientClick", root, handleClick)
    addEventHandler("onClientCursorMove", root, handleCursorMove)

    addEventHandler("onClientPreRender", root, preRender)
    addEventHandler("onClientRender", root, render)

    bindKey(
        "F2",
        "down",
        function()
            showCursor(not isCursorShowing())
        end
    )

    addCommandHandler(
        "dxruncode",
        function(cmd, ...)
            local rawcode = table.concat({...}, " ")

            local run = loadstring(rawcode)

            if (type(run) ~= "function") then
                return false
            end

            local out = run()
            iprintd("[dxruncode] returned:", out)
        end
    )

    runTests()
end
addEventHandler("onClientResourceStart", resourceRoot, init)
