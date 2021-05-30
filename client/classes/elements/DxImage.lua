-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxImage = inherit(DxElement)
-- *******************************************************************

function DxImage:constructor(image, rotation, rotationCenterOffsetX, rotationCenterOffsetY)
    self.type = DX_IMAGE

    self.image = dxCreateTexture(image, "argb", true, "clamp")

    if (not self.image) then
        return self:delete()
    end

    self.rotation = tonumber(rotation) or 0

    self.rotationCenterOffset = {
        x = tonumber(rotationCenterOffsetX) or 0,
        y = tonumber(rotationCenterOffsetY) or 0
    }

    self:addRenderFunction(self.drawImage)
end

-- *******************************************************************

function DxImage:drawImage()
    local color = self.style:getColor("image")
    dxDrawImage(self.x, self.y, self.width, self.height, self.image, self.rotation, self.rotationCenterOffset.x, self.rotationCenterOffset.y, tocolor(color.r, color.g, color.b, color.a))
end