-- Author: Lpsd
-- File: client/classes/Event.lua
-- Description: Event class

-- *******************************************************************
Event = inherit(Class)
-- *******************************************************************

function Event:constructor(eventName, allowRemoteTrigger)
    self.name = eventName
    self.allowRemoteTrigger = allowRemoteTrigger

    self.handlers = {}

    dxDebug("Event added", eventName)
end

function Event:addHandler(dxElement, handlerFunction)
    if (not dxElement) or (not dxElement.__dx) then
        if (dxElement ~= root) then
            return dxDebug("[Event:addHandler] Invalid dx-element supplied") and false
        end
    end

    if (type(handlerFunction) ~= "function") then
        return dxDebug("[Event:addHandler] Invalid handler function supplied") and false
    end

    if (not self.handlers[dxElement]) then
        self.handlers[dxElement] = {}
    end

    local index = (#self.handlers[dxElement] + 1)
    self.handlers[dxElement][index] = handlerFunction

    return true
end

function Event:removeHandler(dxElement, handlerFunction)
    if (not dxElement) or (not dxElement.__dx) then
        if (dxElement ~= root) then
            return dxDebug("[Event:removeHandler] Invalid dx-element supplied") and false
        end
    end

    if (type(handlerFunction) ~= "function") then
        return dxDebug("[Event:removeHandler] Invalid handler function supplied") and false
    end

    if (not self.handlers[dxElement]) then
        return false
    end

    for i, func in ipairs(self.handlers[dxElement]) do
        if (func == handlerFunction) then
            self.handlers[dxElement][i] = nil
            return true
        end
    end

    return false
end

-- *******************************************************************

function Event:getHandlerFunctions(sourceElement)
    local functions = {}

    if (not sourceElement) or (not sourceElement.__dx) then
        if (sourceElement ~= root) then
            return dxDebug("[Event:getHandlerFunctions] Invalid dx-element supplied") and false
        end
    end

    if (not self.handlers[sourceElement]) then
        return false
    end

    if (sourceElement == root) then
        for element, funcList in pairs(self.handlers) do
            for i, func in ipairs(funcList) do
                functions[#functions+1] = func
            end
        end
    else
        for i, func in ipairs(self.handlers[sourceElement]) do
            functions[#functions+1] = func
        end
    end

    return functions
end