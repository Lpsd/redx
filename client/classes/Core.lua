-- Author: Lpsd
-- File: client/classes/Core.lua
-- Description: Core class

-- *******************************************************************
Core = inherit(Singleton)
-- *******************************************************************

function Core:constructor()
    self.renderer = Renderer:getInstance()
    self.eventManager = EventManager:getInstance()

    self.eventManager:addEvent("onDxPropertyChange", true)
end

-- *******************************************************************

function Core:getRenderer()
    return self.renderer
end

function Core:getEventManager()
    return self.eventManager
end