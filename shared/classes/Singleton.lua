-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- ********************************************************************************************************************************** --
Singleton = inherit(Class)
-- ********************************************************************************************************************************** --

function Singleton:new(...)
    return self:getInstance(...)
end

function Singleton:getInstance(...)
    if (not self._instance) then
        self._instance = new(self, ...)
    end

    return self._instance
end

-- ********************************************************************************************************************************** --
