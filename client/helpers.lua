-- Helper functions
function isFocusedElement(e)
    for i, element in ipairs(Core:getInstance().dxFocusedElements) do
        if e == element then
            return true
        end
    end
    return false
end

-- e.g: getDxClassNameFromType(rectInstance.type) = DxRect
function getDxClassNameFromType(dxType)
    local core = Core:getInstance()
    local name = core.dxTypes[dxType]
    
    if (not name) then
        return false
    end
    
    return core.dxTypesClass[name]
end