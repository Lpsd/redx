-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Text = inherit(Class)

function Text:virtual_constructor()
    self.text = {
        string = "Default text...",
        color = tocolor(255, 255, 255, 255),
        align = {
            x = "left",
            y = "top"
        }
    }
end

function Text:setText(text)
    if (type(text) ~= "string") then
        return false
    end

    self.text.string = text
    return true
end

function Text:setTextColor(color)
    color = tonumber(color)

    if (not color) then
        return false
    end

    self.text.color = color
    return true
end

function Text:getText()
    return self.text.string
end

function Text:getTextColor()
    return self.text.color
end

function Text:setTextAlign(pos, state)
    if (not self.text.align[pos]) then
        return false
    end

    local states = {
        x = {
            left = true,
            center = true,
            right = true
        },
        y = {
            top = true,
            center = true,
            bottom = true
        }
    }

    if (not states[pos][state]) then
        return false
    end

    self.text.align[pos] = state
    return true
end

function Text:getTextAlign(pos)
    return self.text.align[pos]
end
