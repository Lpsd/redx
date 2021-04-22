-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
EventManager = inherit(Singleton)
-- *******************************************************************

function EventManager:constructor()
    self.events = {}
end

-- *******************************************************************

function EventManager:addEvent(eventName, allowRemoteTrigger)
    if (self.events[eventName]) then
        return dxDebug("[EventManager:addEvent] Event already added!") and false
    end

    self.events[eventName] = Event:new(eventName)
end

function EventManager:removeEvent(eventName)
    if (not self.events[eventName]) then
        return dxDebug("[EventManager:removeEvent] Event does not exist") and false
    end

    self.events[eventName]:destroy()
    self.events[eventName] = nil

    return true
end

-- *******************************************************************

function EventManager:getEventFromName(eventName)
    return self.events[eventName]
end

-- *******************************************************************

function EventManager:triggerEvent(eventName, sourceElement, ...)
    local event = self:getEventFromName(eventName)

    if (not event) then
        return dxDebug("[EventManager:triggerEvent] Event does not exist") and false
    end

    local functions = event:getHandlerFunctions(sourceElement)

    if (not functions) then
        return false
    end

    for i, func in ipairs(functions) do
        func(...)
    end
    
    return true
end