-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
Singleton = inherit(Class)
-- *******************************************************************

function Singleton:getInstance(...)
    if (not self._instance) then
        self._instance = self:new(...)
    end

    return self._instance
end