FT = FT or {}

Events.onFillSearchIconContextMenu.Add(function(context, icon)
    if not icon.itemType then return end
    if not icon.identified then return end


    context:addOption(
        getText(FT.taggedItems[icon.itemType] and "ContextMenu_ForageTags_Untag" or "ContextMenu_ForageTags_Tag"),
        icon,
        function(ic) FT.toggleItemTag(ic.itemType) end)

    context:addOption(getText("ContextMenu_ForageTags_Open"), icon, function(ic)
        FT.openWindowAtCategory(ic.catDef and ic.catDef.name)
    end)
end)

function FT.openWindowAtCategory(catName)
    if catName then
        FT.expanded = {}
        FT.expanded[catName] = true
    end
    FT.openWindow()
    if catName and FT.window then
        FT.window:scrollToCategory(catName)
    end
end