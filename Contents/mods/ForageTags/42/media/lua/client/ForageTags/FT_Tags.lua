FT = FT or {}

-- Aliased to player modData by FT.load(). Never reassign these — empty in place.
FT.taggedItems = FT.taggedItems or {}
FT.taggedCategories = FT.taggedCategories or {}
FT.expanded = {}
FT.showAllCategories = false
FT.showHomingArrow = true

function FT.notifyChanged()
    if FT.window and FT.window:getIsVisible() then
        FT.window:refreshList()
    end
end

-- Tagged individually, or via any category the item definition belongs to.
-- Items can be in several categories (a caterpillar is both Insects and FishBait),
-- so this reads the item def rather than the icon's single spawn category.
function FT.isTagged(itemType)
    if not itemType then return false end
    if FT.taggedItems[itemType] then return true end

    local def = forageSystem.itemDefs[itemType]
    if def and def.categories then
        for _, catName in ipairs(def.categories) do
            if FT.taggedCategories[catName] then return true end
        end
    end
    return false
end

function FT.setItemTag(itemType, value)
    if not itemType then return end
    FT.taggedItems[itemType] = value and true or nil
    FT.notifyChanged()
end

function FT.toggleItemTag(itemType)
    FT.setItemTag(itemType, not (itemType and FT.taggedItems[itemType]))
end

function FT.setCategoryTag(catName, value)
    if not catName then return end
    FT.taggedCategories[catName] = value and true or nil
    FT.notifyChanged()
end

function FT.toggleCategoryTag(catName)
    FT.setCategoryTag(catName, not (catName and FT.taggedCategories[catName]))
end

-- Cleared in place, not reassigned, to keep the modData alias intact.
function FT.clearAllTags()
    for k in pairs(FT.taggedItems) do FT.taggedItems[k] = nil end
    for k in pairs(FT.taggedCategories) do FT.taggedCategories[k] = nil end
    FT.notifyChanged()
end


-- Vanilla translation first, ours second, CamelCase split for modded categories.
function FT.getCategoryLabel(catName)
    local key = "IGUI_SearchMode_Categories_" .. catName
    local translated = getText(key)
    if translated and translated ~= key then return translated end

    key = "UI_ForageTags_Cat_" .. catName
    translated = getText(key)
    if translated and translated ~= key then return translated end

    return (catName:gsub("(%l)(%u)", "%1 %2"))
end

-- Display order only. Categories missing here are appended alphabetically.
FT.categoryOrder = {
    "Berries", "Fruits", "Vegetables", "Mushrooms", "WildPlants", "WildHerbs",
    "MedicinalPlants", "Crops", "Insects", "FishBait",
    "Animals", "DeadAnimals", "Tracks", "Bones",
    "Firewood", "Stones", "CraftingMaterials", "ForestGoods", "ForestRarities",
    "JunkFood", "Clothing", "Medical", "Ammunition", "JunkWeapons",
    "Artifacts", "Junk", "Trash",
}

function FT.getOrderedCategories()
    local seen, ordered, extra = {}, {}, {}
    for _, name in ipairs(FT.categoryOrder) do
        if forageSystem.catDefs[name] then
            table.insert(ordered, name)
            seen[name] = true
        end
    end
    for name, _ in pairs(forageSystem.catDefs) do
        if not seen[name] then table.insert(extra, name) end
    end
    table.sort(extra)
    for _, name in ipairs(extra) do table.insert(ordered, name) end
    return ordered
end

-- Forage definitions don't change at runtime, so this is built once and kept.
FT.itemCache = nil

function FT.getItemsByCategory()
    if FT.itemCache then return FT.itemCache end

    local byCat = {}
    for fullType, itemDef in pairs(forageSystem.itemDefs) do
        local scriptItem = getScriptManager():getItem(fullType)
        local entry = {
            fullType = fullType,
            name = scriptItem and scriptItem:getDisplayName() or fullType,
            texture = scriptItem and scriptItem:getNormalTexture() or nil,
            skill = itemDef.skill or 0,
        }
        if itemDef.categories then
            for _, catName in ipairs(itemDef.categories) do
                byCat[catName] = byCat[catName] or {}
                table.insert(byCat[catName], entry)
            end
        end
    end
    for _, list in pairs(byCat) do
        table.sort(list, function(a, b) return a.name < b.name end)
    end

    FT.itemCache = byCat
    return byCat
end