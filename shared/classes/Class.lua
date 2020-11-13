-- Author: Lpsd
-- File: shared/classes/class.lua
-- Description: Base class

-- *******************************************************************
Class = {}
-- *******************************************************************

function Class:new(...)
	return new(self, ...)
end

function Class:destroy(...)
    return delete(self, ...)
end

-- *******************************************************************