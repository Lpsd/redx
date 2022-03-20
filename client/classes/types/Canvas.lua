-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

Canvas = inherit(Dx)

function Canvas:constructor(x, y, width, height, color)
    self.type = DX_CANVAS
    self.canvasColor = tocolor(255, 255, 255, 255)

    self.renderTarget = false
    self.isRedrawing = false

    self:setProperty("click_propagate", true)
    self:setProperty("drag_propagate", true)

    self:addRenderFunction(self.redrawQueued, true)

    self:create()
end

function Canvas:pre_constructor()
end

function Canvas:create()
    if (isElement(self.renderTarget)) then
        destroyElement(self.renderTarget)
    end

    self.renderTarget = dxCreateRenderTarget(self.width, self.height, true)
end

function Canvas:redraw()
    self.redrawNextFrame = true
end

function Canvas:redrawQueued()
    if (not self.redrawNextFrame) or (not isElement(self.renderTarget)) then
        return false
    end

    self.isRedrawing = true

    dxSetRenderTarget(self.renderTarget, true)
    dxSetBlendMode("modulate_add")

    for i = 1, #self.children do
        local child = self.children[i]
        child:render(self)
    end

    dxSetBlendMode("blend")
    dxSetRenderTarget()

    self.isRedrawing = false
    self.redrawNextFrame = false

    self:redrawNextCanvasAncestor()
end

function Canvas:draw(x, y)
    if (isElement(self.renderTarget)) then
        dxDrawImage(x, y, self.width, self.height, self.renderTarget, 0, 0, 0, self.canvasColor)
    end
end

function Canvas:getCanvasAncestors()
    local ancestors = self:getAncestors()
    local t = {}

    for i = #ancestors, 1, -1 do
        local ancestor = ancestors[i]
        if (ancestor.type == DX_CANVAS) then
            t[#t + 1] = ancestor
        end
    end

    return t
end

function Canvas:redrawNextCanvasAncestor(recursive, canvas)
    local ancestors = self:getCanvasAncestors()

    if (type(ancestors) ~= "table") or (not ancestors[1]) then
        return false
    end

    ancestors[1]:redraw()
    ancestors[1]:redrawNextCanvasAncestor()
end
