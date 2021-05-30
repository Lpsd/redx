-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
Font = inherit(Class)
-- *******************************************************************

function Font:constructor(name, filepath, sizes, quality, isMtaFont)
    self.name = name
    self.filepath = filepath
    self.sizes = sizes
    self.quality = quality
    self.isMtaFont = isMtaFont

    self.fonts = {}

    self:createFonts()

    return self
end

-- *******************************************************************

function Font:createFonts()
    if (#self.fonts > 0) then
        self:destroyFonts()
    end

    for i = 1, self.sizes do
        self.fonts[i] = self.isMtaFont and self.name or dxCreateFont(self.filepath, i, false, self.quality)
    end

    return true
end

function Font:destroyFonts()
    for i = #self.fonts, 1, -1 do
        if (isElement(self.fonts[i])) then
            destroyElement(self.fonts[i])
        end
    end

    self.fonts = {}
    return true
end

-- *******************************************************************

function Font:getFontBySize(size)
    return self.fonts[size]
end