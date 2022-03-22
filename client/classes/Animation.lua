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

function Animation:constructor(property, from, to, duration, easing, loop, onRender, onComplete)
    self.property = (type(property) == "string" and property ~= "") and property or false
    self.from = (type(from) == "table") and from or {tonumber(from)}
    self.to = (type(to) == "table") and to or {tonumber(to)}

    if (not self.property) or (#self.from ~= #self.to) then
        return self:delete()
    end

    for i = 1, #self.from do
        self.from[i] = tonumber(self.from[i])

        if (not self.from[i]) then
            return self:delete()
        end
    end

    for i = 1, #self.to do
        self.to[i] = tonumber(self.to[i])

        if (not self.to[i]) then
            return self:delete()
        end
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

    self.onRender = (type(onRender) == "function") and onRender or false
    self.onComplete = (type(onComplete) == "function") and onComplete or false

    self.i = {}
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
    self.startMs = getTickCount()
end

function Animation:run()
	local elapsed = (getTickCount() - self.startMs)
	local progress = (elapsed / self.duration)

    for index, i in ipairs(self.from) do
        self.i[index] = interpolateBetween(i, 0, 0, self.to[index], 0, 0, progress, "Linear")
    end

    if (getTickCount() >= self.startMs + self.duration) then
        self.runs = self.runs + 1

        if (self.loop) then
            if (type(self.loop) == "number") and (self.runs < self.loop) then
                self:start()
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