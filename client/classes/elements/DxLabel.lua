-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxLabel = inherit(DxElement)
-- *******************************************************************

function DxLabel:constructor(text, font, alignX, alignY, clip, wordBreak, colorCoded, rotation, rotationCenterX, rotationCenterY)
    self.type = DX_LABEL

    self.clip = (type(clip) == "boolean") and clip or false
    self.wordBreak = (type(wordBreak) == "boolean") and wordBreak or false
    self.colorCoded = (type(colorCoded) == "boolean") and colorCoded or false

    self.rotation = tonumber(rotation) and rotation or 0

    self.rotationCenter = {
        x = tonumber(rotationCenterX) and rotationCenterX or 0,
        y = tonumber(rotationCenterY) and rotationCenterY or 0
    }

    self.text = text or "Default label text"
    self.font = font or "default"

    self.align = {
        x = (alignX == "left" or alignX == "center" or alignX == "right") and alignX or "left",
        y = (alignY == "top" or alignY == "center" or alignY == "bottom") and alignY or "top"
    }

    self.scale = {
        x = 1.0,
        y = 1.0
    }

    self:addRenderFunction(self.drawText)
end

-- *******************************************************************

function DxLabel:drawText()  
    local background = self.style:getColor("background")
    dxDrawRectangle(self.x, self.y, self.width, self.height, tocolor(background.r, background.g, background.b, background.a))

    local color = self.style:getColor("text")
    dxDrawText(self.text, self.x, self.y, self.x + self.width, self.y + self.height, tocolor(color.r, color.g, color.b, color.a), self.scale.x, self.scale.y, self.font, self.align.x, self.align.y, self.clip, self.wordBreak, false, self.colorCoded, true, self.rotation, self.rotationCenter.x, self.rotationCenter.y)
end