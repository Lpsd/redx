-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
FontManager = inherit(Singleton)
-- *******************************************************************

function FontManager:constructor()
    self.fonts = {}

    self.qualities = {
        ["default"] = true,
        ["draft"] = true,
        ["proof"] = true,
        ["nonantialiased"] = true,
        ["antialiased"] = true,
        ["cleartype"] = true,
        ["cleartype_natural"] = true
    }

    self.mtaFonts = {
        ["default"] = true,
        ["default-bold"] = true,
        ["clear"] = true,
        ["arial"] = true,
        ["sans"] = true,
        ["pricedown"] = true,
        ["bankgothic"] = true,
        ["diploma"] = true,
        ["beckett"] = true
    }

    self.defaultQuality = "proof"
    self.defaultSizes = 16

    -- Include MTA fonts
    for font in pairs(self.mtaFonts) do
        self:createFontContainer(font)
    end

    -- Include custom fonts
    self:createFontContainer("montserrat", "fonts/Montserrat-Regular.ttf")
end

-- *******************************************************************

function FontManager:setDefaultQuality(quality)
    if (not self.qualities[quality]) then
        return false
    end

    self.defaultQuality = quality
    return true
end

-- *******************************************************************

function FontManager:setDefaultSizes(sizes)
    sizes = tonumber(sizes)

    if (not sizes) then
        return false
    end

    self.defaultSizes = sizes
    return true
end

-- *******************************************************************

function FontManager:createFontContainer(name, filepath, sizes, quality)
    if (self.fonts[name]) then
        return false
    end

    local isMtaFont = self.mtaFonts[name]

    sizes = tonumber(sizes) or self.defaultSizes
    quality = self.qualities[quality] or self.defaultQuality

    self.fonts[name] = Font:new(name, filepath, sizes, quality, isMtaFont)
    return self.fonts[name]
end

-- *******************************************************************

function FontManager:getFontContainer(name)
    return self.fonts[name]
end