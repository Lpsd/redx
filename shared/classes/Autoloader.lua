-- ********************************************************************************************************************************** --
Autoloader = {__classes = {}}
-- ********************************************************************************************************************************** --

function Autoloader:loadClasses()
    local classCount = 0
    local globalStartTick = getTickCount()
    local startTick = false

    for className, class in pairs(Autoloader.__classes) do
        startTick = getTickCount()

        class:getInstance()

        local elapsedTime = getTickCount() - startTick
        iprintd("Autoloader: Loaded class '" .. className .. "' in " .. elapsedTime .. "ms")

        classCount = classCount + 1
    end

    iprintd(
        "Autoloader: Loaded " ..
            classCount ..
                " class" .. (classCount == 1 and "" or "es") .. " in " .. (getTickCount() - globalStartTick) .. "ms"
    )
end

function Autoloader:unloadClasses()
    for className, class in pairs(Autoloader.__classes) do
        class:getInstance():delete()
    end

    Autoloader.__classes = nil
end

-- ********************************************************************************************************************************** --

function preInitializeClass(className)
    local class = _G[className]

    if (type(class) == "table") then
        if (type(class.getInstance) ~= "function") then
            error("preInitializeClass: class '" .. className .. "' is not inheriting Singleton class")
            return
        end

        if (Autoloader.__classes[className]) then
            error("preInitializeClass: Class '" .. className .. "' was already added")
            return
        end

        Autoloader.__classes[className] = class
    end
end

-- ********************************************************************************************************************************** --