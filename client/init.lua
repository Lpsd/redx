-- Author: Lpsd
-- File: init.lua
-- Description: Initializes the DX Library and contains globals/constants

-- Constants
SCREEN_WIDTH, SCREEN_HEIGHT = false, false
DEBUG = true

-- *******************************************************************

-- Store all DxElements
DxRootElements = {}
DxFocusedElement = false

DxCore = false

-- *******************************************************************

function init()
    SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
    
    -- Initialize the core
    DxCore = Core:getInstance()

    -- Loads the default properties
    loadDefaultProperties()

    -- Testing
    dxTest()
end
addEventHandler("onClientResourceStart", resourceRoot, init)

-- *******************************************************************

function dxTest()
    parent = DxRect:new(300, 300, 200, 200)
    parent:setColor(255, 0, 0, 255)
end

-- *******************************************************************

bindKey("F2", "down", function()
    showCursor(not isCursorShowing())
end)

-- *******************************************************************

-- Helper functions
function isFocusedElement(element)
    return DxFocusedElement == element
end

function refreshElementIndexes()
    for i, element in ipairs(DxRootElements) do
        element.index = element:getTableIndex()
        refreshElementChildIndexes(element)
    end 
end

function refreshElementChildIndexes(element)
    for i, child in ipairs(element.children) do
        child.index = child:getTableIndex()
    end
end