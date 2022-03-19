-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

DxCore = false
DxRootInstance = false

DxInstances = {}

DxProperties = {}

DxTypes = {}
DxTypeClasses = {
    ["BASE"] = "Dx",
    ["RECT"] = "Rect",
    ["CANVAS"] = "Canvas"
}

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

local function loadPropertiesFromFile(path)
    local propertiesFile = fileOpen(path or "default.properties")

    if (propertiesFile) then
        local size = fileGetSize(propertiesFile)
        local jsonData = fileRead(propertiesFile, size)

        DxProperties = fromJSON(jsonData)

        fileClose(propertiesFile)
        iprintd("Loaded default properties", path)
        return DxProperties
    end

    iprintd("Failed to load default properties", path)
    return false
end

local function loadDefaultProperties(path)
    return loadPropertiesFromFile((type(path) == "string") and path or "default.properties")
end

local function getDefaultProperties()
    return DxProperties or loadDefaultProperties() or iprintd("Problem getting default properties")
end

function setDefaultProperty(name, value)
    if (type(name) ~= "string") then
        return false
    end

    if (DxProperties[name]) and (type(val) ~= type(DxProperties[name])) then
        return false
    end

    DxProperties[name] = val
    return true
end

function getDefaultProperty(name)
    return DxProperties[name]
end

function getHoveredInstance(dx, propagated)
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
                local hovering_next = next and isMouseInPosition(next.absoluteX, next.absoluteY, next.width, next.height) or false

                if (hovering_next) then
                    if (hovering_this) then
                        propagated[#propagated + 1] = dx
                    end

                    return next, propagated
                elseif (hovering_child) then
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

    Autoloader.loadClasses()

    loadDefaultProperties()

    -- Create the root UI element
    DxRootInstance = Canvas:new(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, tocolor(0, 0, 0, 0), false, "root")

    addEventHandler("onClientClick", root, handleClick)
    
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
