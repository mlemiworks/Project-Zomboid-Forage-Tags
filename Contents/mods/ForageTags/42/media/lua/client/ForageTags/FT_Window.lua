require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTextEntryBox"
require "ISUI/ISTickBox"
require "ISUI/ISButton"

FT = FT or {}

local ROW_HEIGHT   = 24
local CHECK_X_CAT  = 24
local CHECK_X_ITEM = 44
local CHECK_SIZE   = 14
local ARROW_X      = 6
local LABEL_X_CAT  = 46
local ICON_X_ITEM  = 66
local TOP_BAR_H = 22
local TICK_PAD = 38   -- box (TOP_BAR_H 22) + textGap (10) + right margin (6)

FT.TagWindow = ISCollapsableWindow:derive("FT_TagWindow")

-- build the flat row array ---------------------------------------------------

-- Flat array of category and item rows; collapsed categories simply omit their items.
function FT.buildRows(filterText)
    local rows = {}
    local byCat = FT.getItemsByCategory()
    local filter = (filterText and filterText ~= "") and string.lower(filterText) or nil

    for _, catName in ipairs(FT.getOrderedCategories()) do
        local def = forageSystem.catDefs[catName]
            if def and (FT.showAllCategories or not def.categoryHidden) then
            local matching = {}
            for _, entry in ipairs(byCat[catName] or {}) do
                if not filter or string.find(string.lower(entry.name), filter, 1, true) then
                    table.insert(matching, entry)
                end
            end

            if #matching > 0 then
                table.insert(rows, {
                    kind = "category",
                    catName = catName,
                    label = FT.getCategoryLabel(catName),
                    count = #matching,
                })
                if FT.expanded[catName] or filter then
                    for _, entry in ipairs(matching) do
                        table.insert(rows, {
                            kind = "item",
                            catName = catName,
                            entry = entry,
                            label = entry.name,
                        })
                    end
                end
            end
        end
    end
    return rows
end

-- drawing --------------------------------------------------------------------

local function drawCheck(listBox, x, y, checked, dimmed)
    local a = dimmed and 0.45 or 1.0
    listBox:drawRectBorder(x, y, CHECK_SIZE, CHECK_SIZE, a, 0.7, 0.7, 0.7)
    if checked then
        listBox:drawRect(x + 3, y + 3, CHECK_SIZE - 6, CHECK_SIZE - 6, a, 0.95, 0.8, 0.25)
    end
end

function FT.drawTagRow(listBox, y, item, alt)
    local row = item.item
    local h = ROW_HEIGHT
    local textY = y + (h - listBox.fontHgt) / 2
    local checkY = y + (h - CHECK_SIZE) / 2

    if row.kind == "category" then
        listBox:drawRect(0, y, listBox:getWidth(), h, 0.12, 1, 1, 1)
        listBox:drawText(FT.expanded[row.catName] and "-" or "+",
            ARROW_X, textY, 0.7, 0.7, 0.7, 1, listBox.font)
        drawCheck(listBox, CHECK_X_CAT, checkY, FT.taggedCategories[row.catName], false)
        listBox:drawText(row.label .. "  (" .. row.count .. ")",
            LABEL_X_CAT, textY, 1, 1, 1, 1, listBox.font)
    else
        local tagged = FT.taggedItems[row.entry.fullType]
        local inherited = (not tagged) and FT.isTagged(row.entry.fullType)
        drawCheck(listBox, CHECK_X_ITEM, checkY, tagged or inherited, inherited)
        if row.entry.texture then
            listBox:drawTextureScaled(row.entry.texture, ICON_X_ITEM, y + 2, h - 4, h - 4, 1, 1, 1, 1)
        end
        listBox:drawText(row.label, ICON_X_ITEM + h + 4, textY, 0.9, 0.9, 0.9, 1, listBox.font)
    end

    -- The list derives each row's height from this; returning the wrong value breaks hit-testing.
    return y + h
end

-- clicks ---------------------------------------------------------------------

-- Category rows have two click zones: the checkbox tags, everywhere else expands.
function FT.TagWindow:onRowClick(item)
    if not item then return end
    local mouseX = self.listBox:getMouseX()

    if item.kind == "category" then
        if mouseX >= CHECK_X_CAT and mouseX < CHECK_X_CAT + CHECK_SIZE + 4 then
            FT.toggleCategoryTag(item.catName)
        else
            FT.expanded[item.catName] = (not FT.expanded[item.catName]) or nil
            self:refreshList()
        end
    else
        if (not FT.taggedItems[item.entry.fullType])
           and FT.isTagged(item.entry.fullType) then return end
        FT.toggleItemTag(item.entry.fullType)
    end
end
-- window ---------------------------------------------------------------------

function FT.TagWindow:refreshList()
    if not self.listBox or not self.searchBox then return end
    local scroll = self.listBox:getYScroll()
    self.listBox:clear()
    self.listBox:setScrollHeight(0)
    -- Full rebuild on every change; cheap enough at this row count.
    for _, row in ipairs(FT.buildRows(self.searchBox:getInternalText())) do
        self.listBox:addItem(row.label, row, row.entry and ("Level " .. row.entry.skill) or nil)
    end
    self.listBox:setYScroll(scroll)
end

function FT.TagWindow:onSearchChange()
    self:refreshList()
end

function FT.TagWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 4

    local labelCat   = getText("UI_ForageTags_AllCategories")
    local labelArrow = getText("UI_ForageTags_HomingArrow")

    local tm = getTextManager()
    local wCat   = tm:MeasureStringX(UIFont.Small, labelCat) + TICK_PAD
    local wArrow = tm:MeasureStringX(UIFont.Small, labelArrow) + TICK_PAD
    local ticksW = wCat + wArrow + pad

    self.searchBox = ISTextEntryBox:new("", pad, th + pad,
        self.width - pad * 3 - ticksW, TOP_BAR_H)
    self.searchBox:initialise()
    self.searchBox:instantiate()
    self.searchBox.anchorRight = true
    self.searchBox.onTextChange = function() self:onSearchChange() end
    self:addChild(self.searchBox)

    local clearW = 18
    self.clearBtn = ISButton:new(
        self.searchBox:getRight() - clearW - 2,
        th + pad + 2,
        clearW, TOP_BAR_H - 4,
        "X", self, FT.TagWindow.onClearSearch)
    self.clearBtn:initialise()
    self.clearBtn:instantiate()
    self.clearBtn.anchorLeft = false
    self.clearBtn.anchorRight = true
    self.clearBtn.borderColor.a = 0
    self.clearBtn.backgroundColor.a = 0
    self.clearBtn.backgroundColorMouseOver.a = 0.3
    self:addChild(self.clearBtn)

    self.tickCat = ISTickBox:new(self.width - pad - ticksW, th + pad,
        wCat, TOP_BAR_H, "", self, FT.TagWindow.onTickCategories)
    self.tickCat:initialise()
    self.tickCat:instantiate()
    self.tickCat.anchorLeft = false
    self.tickCat.anchorRight = true
    self.tickCat:addOption(labelCat)
    self.tickCat:setSelected(1, FT.showAllCategories)
    self:addChild(self.tickCat)

    self.tickArrow = ISTickBox:new(self.width - pad - wArrow, th + pad,
        wArrow, TOP_BAR_H, "", self, FT.TagWindow.onTickArrow)
    self.tickArrow:initialise()
    self.tickArrow:instantiate()
    self.tickArrow.anchorLeft = false
    self.tickArrow.anchorRight = true
    self.tickArrow:addOption(labelArrow)
    self.tickArrow:setSelected(1, FT.showHomingArrow)
    self:addChild(self.tickArrow)

    local listY = th + pad + TOP_BAR_H + pad

    self.listBox = ISScrollingListBox:new(0, listY, self.width, self.height - listY)
    self.listBox:initialise()
    self.listBox:instantiate()
    self.listBox:setFont(UIFont.Small, 4)
    self.listBox.itemheight = ROW_HEIGHT
    self.listBox.drawBorder = false
    self.listBox.selected = -1
    self.listBox.anchorRight = true
    self.listBox.anchorBottom = true
    self.listBox.doDrawItem = FT.drawTagRow
    self.listBox:setOnMouseDownFunction(self, FT.TagWindow.onRowClick)
    self:addChild(self.listBox)

    self:refreshList()
end

function FT.TagWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o:setResizable(true)
    o.title = getText("UI_ForageTags_WindowTitle")
    return o
end

function FT.TagWindow:onClearSearch()
    self.searchBox:setText("")
    self:refreshList()
end

function FT.TagWindow:prerender()
    ISCollapsableWindow.prerender(self)
    if self.clearBtn and self.searchBox then
        local txt = self.searchBox:getInternalText()
        self.clearBtn:setVisible(txt ~= nil and txt ~= "")
    end
end

function FT.TagWindow:onTickCategories(index, selected)
    FT.showAllCategories = selected
    if FT.opts then FT.opts.showAllCategories = selected end
    self:refreshList()
end

function FT.TagWindow:onTickArrow(index, selected)
    FT.showHomingArrow = selected
    if FT.opts then FT.opts.showHomingArrow = selected end
end

function FT.TagWindow:scrollToCategory(catName)
    if not catName then return end
    for i, row in ipairs(self.listBox.items) do
        if row.item and row.item.kind == "category" and row.item.catName == catName then
            self.listBox:ensureVisible(i)
            return
        end
    end
end

function FT.openWindow()
    if FT.window then
        FT.window:setVisible(true)
        FT.window:bringToTop()
        FT.window:refreshList()
        return
    end
    FT.window = FT.TagWindow:new(200, 200, 420, 520)
    FT.window:initialise()
    FT.window:addToUIManager()
end