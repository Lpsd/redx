-- Author: Lpsd
-- File: shared/classes/singleton.lua
-- Description: Basic singleton class

-- *******************************************************************
Singleton = inherit(Class)
-- *******************************************************************

function Singleton:getInstance(...)
    if (not self._instance) then
        self._instance = self:new(...)
    end

    return self._instance
end