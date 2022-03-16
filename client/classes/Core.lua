-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Core = inherit(Singleton)
inherit(Autoloader, Core)

function Core:constructor()
    self:loadClasses()
end
