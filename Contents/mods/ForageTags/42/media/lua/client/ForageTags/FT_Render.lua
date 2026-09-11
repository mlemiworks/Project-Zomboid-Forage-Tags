require "Foraging/ISForageIcon"

FT = FT or {}
FT.starTex = getTexture("media/textures/FT_star.png")
FT.starSize = 16
FT.offX = -18
FT.offY = -5

local GOLD  = { 0.95, 0.80, 0.25 }
local PLAIN = { 0.80, 0.80, 0.80 }

-- Captured from ISBaseIcon, assigned to ISForageIcon — no wrapper stacking on Lua reload.
local originalRenderPinIcon = ISBaseIcon.renderPinIcon
local originalUpdateWorldMarker = ISBaseIcon.updateWorldMarker


-- Vanilla's render() already handled the seen check, zoom and position before calling this.
function ISForageIcon:renderPinIcon()
    originalRenderPinIcon(self)

    if not FT.isTagged(self.itemType) then return end
    if not FT.starTex then return end

    -- Divide by zoom so the star keeps a constant on-screen size.
    local size = FT.starSize / self.zoom
    local x = self.width - size + (FT.offX / self.zoom)
    local y = FT.offY / self.zoom

    self:drawTextureScaled(FT.starTex, x, y, size, size, self:getAlpha(), 1, 1, 1)
end


-- Runs every update, so markers created after a tag change get recoloured too.
function ISForageIcon:updateWorldMarker()
    originalUpdateWorldMarker(self)

    local m = self.worldMarker
    if not m then return end

    local c = PLAIN
    if FT.showHomingArrow and FT.isTagged(self.itemType) then
        c = GOLD
    end

    m:setR(c[1])
    m:setG(c[2])
    m:setB(c[3])
end