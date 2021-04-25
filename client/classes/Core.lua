-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
Core = inherit(Singleton)
-- *******************************************************************

function Core:constructor()
    self.renderer = Renderer:getInstance()
    self.eventManager = EventManager:getInstance()
    self.styleManager = StyleManager:getInstance()
    
    self.dxTypes = {
        "RECT",
        "SCROLLPANE",
        "SCROLLBAR",
        "WINDOW"
    }

    self.dxTypesClass = {
        ["RECT"] = "DxRect",
        ["SCROLLPANE"] = "DxScrollPane",
        ["SCROLLBAR"] = "DxScrollBar",
        ["WINDOW"] = "DxWindow"
    }

    self.dxRootElements = {}
    self.dxFocusedElements = {}

    self.debugMode = true

    enum(self.dxTypes, "DX")

    self.eventManager:addEvent("onDxPropertyChange", true)
end

-- *******************************************************************

function Core:getRenderer()
    return self.renderer
end

function Core:getEventManager()
    return self.eventManager
end