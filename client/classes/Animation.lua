-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Animation = inherit(Class)

local easingTypes = {
    ["Linear"] = true, 
    ["InQuad"] = true, 
    ["OutQuad"] = true, 
    ["InOutQuad"] = true, 
    ["OutInQuad"] = true, 
    ["InElastic"] = true, 
    ["OutElastic"] = true, 
    ["InOutElastic"] = true, 
    ["OutInElastic"] = true, 
    ["InBack"] = true, 
    ["OutBack"] = true, 
    ["InOutBack"] = true, 
    ["OutInBack"] = true, 
    ["InBounce"] = true, 
    ["OutBounce"] = true, 
    ["InOutBounce"] = true, 
    ["OutInBounce"] = true, 
    ["SineCurve"] = true, 
    ["CosineCurve"] = true
}

function Animation:constructor(property, from, to, duration, easing, loop, onComplete)
    self.property = (type(property) == "string" and property ~= "") and property or false
    self.from = tonumber(from)
    self.to = tonumber(to)

    if (not self.property) or (not self.from) or (not self.to) then
        return self:delete()
    end

    if (type(loop) ~= "boolean") then
        loop = false
    end

    self.duration = (tonumber(duration) and duration > 0) and tonumber(duration) or 2000
    self.easing = easingTypes[easing] and easing or "Linear"

    self.state = false
    self.startMs = 0

    self.finished = false
    self.loop = loop

    self.onComplete = (type(onComplete) == "function") and onComplete or false

    self.i = 0
    self.runs = 0
end

function Animation:setLooped(state)
    if (type(state) ~= "boolean") then
        return false
    end

    self.loop = state
end

function Animation:start()
    self.startMs = getTickCount()
    self.state = true
end

function Animation:stop()
    self.state = false
end

function Animation:toggle()
    self.state = (not self.state)
end

function Animation:run()
	local elapsed = (getTickCount() - self.startMs)
	local progress = (elapsed / self.duration)

    self.i = interpolateBetween(self.from, 0, 0, self.to, 0, 0, progress, self.easing)

    if (getTickCount() >= self.startMs + self.duration) then
        self.runs = self.runs + 1

        if (self.loop) then
            if (type(self.loop) == "number") and (self.runs < self.loop) then
                return self:start()
            end

            if (type(self.loop) == "boolean") then
                self:start()
            end
        else
            self.finished = true
        end

        if (self.onComplete) then
            self.onComplete(self)
        end
    end
end