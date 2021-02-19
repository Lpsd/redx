-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

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