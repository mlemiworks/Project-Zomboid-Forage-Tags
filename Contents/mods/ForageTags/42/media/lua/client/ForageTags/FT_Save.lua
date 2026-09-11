FT = FT or {}

local MOD_KEY = "ForageTags"

-- Fires for new and existing characters alike; a missing key means a fresh character.
function FT.load()
    local player = getPlayer()
    if not player then return end

    local md = player:getModData()
    local saved = md[MOD_KEY]

    if not saved then
        saved = { items = {}, categories = {}, opts = {} }
        md[MOD_KEY] = saved
    end

    saved.items = saved.items or {}
    saved.categories = saved.categories or {}
    saved.opts = saved.opts or {}

    -- Alias, not copy: writes through these go straight into modData, so there's no save step.
    FT.taggedItems = saved.items
    FT.taggedCategories = saved.categories
    FT.opts = saved.opts

    if saved.opts.showAllCategories ~= nil then
        FT.showAllCategories = saved.opts.showAllCategories
    end
    if saved.opts.showHomingArrow ~= nil then
        FT.showHomingArrow = saved.opts.showHomingArrow
    end

    FT.loaded = true
end

Events.OnCreatePlayer.Add(function(playerIndex, player)
    if playerIndex == 0 then FT.load() end
end)