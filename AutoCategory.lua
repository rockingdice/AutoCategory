------------------
--LOAD LIBRARIES--
------------------

--load LibAddonsMenu-2.0
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0");

----------------------
--INITIATE VARIABLES--
----------------------

--create Addon UI table
AutoCategory.RuleFunc = {}
AutoCategory.Inited = false

AutoCategory.name = "AutoCategory";
AutoCategory.version = "1.01";
AutoCategory.settingName = "Auto Category"
AutoCategory.settingDisplayName = "RockingDice's AutoCategory"
AutoCategory.author = "RockingDice"

AC_UNGROUPED_NAME = "Others"
AC_EMPTY_TAG_NAME = "<Empty>"


key = ""
function PrintTable(table , level)
  level = level or 1
  local indent = ""
  for i = 1, level do
    indent = indent.."  "
  end

  if key ~= "" then
    d(indent..key.." ".."=".." ".."{")
  else
    d(indent .. "{")
  end

  key = ""
  for k,v in pairs(table) do
     if type(v) == "table" then
        key = k
        PrintTable(v, level + 1)
     else
        local content = string.format("%s%s = %s", indent .. "  ",tostring(k), tostring(v))
      d(content)  
      end
  end
  d(indent .. "}")

end
 
function AutoCategory.UpdateCurrentSavedVars()
	AutoCategory.curSavedVars= {}
	if not AutoCategory.acctSavedVariables.accountWideSetting  then
		AutoCategory.curSavedVars.rules = AutoCategory.acctSavedVariables.rules
		AutoCategory.curSavedVars.bags = AutoCategory.charSavedVariables.bags
		d("Use Character setting")
	else 
		AutoCategory.curSavedVars.rules = AutoCategory.acctSavedVariables.rules
		AutoCategory.curSavedVars.bags = AutoCategory.acctSavedVariables.bags 
		d("Use Accountwide Setting")
	end
end

function AutoCategory.ResetToDefaults()
	AutoCategory.acctSavedVariables.accountWideSetting = AutoCategory.defaultAcctSettings.accountWideSetting
	AutoCategory.acctSavedVariables.rules = AutoCategory.defaultAcctSettings.rules
	AutoCategory.acctSavedVariables.bags = AutoCategory.defaultAcctSettings.bags
	AutoCategory.charSavedVariables.rules = AutoCategory.defaultSettings.rules
	AutoCategory.charSavedVariables.bags = AutoCategory.defaultSettings.bags
	
end

local function removeSameNamedCategory(categories)
	local names = {}
	local name = nil
	for i = 1, #categories do
		name = categories[i].categoryName
		if not name or names[name] then
			table.remove(categories, i)
		end
	end
end

local CUSTOM_GAMEPAD_ITEM_SORT =
{
	sortPriorityName  = { tiebreaker = "bestItemTypeName" },
	bestItemTypeName = { tiebreaker = "name" },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tiebreaker = "uniqueId" },
    uniqueId = { isId64 = true },
}
 
local sortKeys =
{
    slotIndex = { isNumeric = true },
    stackCount = { tiebreaker = "slotIndex", isNumeric = true },
    name = { tiebreaker = "stackCount" },
    quality = { tiebreaker = "name", isNumeric = true },
    stackSellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    statusSortOrder = { tiebreaker = "age", isNumeric = true},
    age = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true},
    statValue = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
}

local function AutoCategory_ItemSortComparator(left, right)
    return ZO_TableOrderingFunction(left, right, "sortPriorityName", CUSTOM_GAMEPAD_ITEM_SORT, ZO_SORT_ORDER_UP)
end

local function NilOrLessThan(value1, value2)
    if value1 == nil then
        return true
    elseif value2 == nil then
        return false
    else
        return value1 < value2
    end
end


local function FixIakoniGearChanger()
	if GearChangerByIakoni then
		local function GearChangerByIakoni_DoRefresh(list)
			local a=GearChangerByIakoni.savedVariables.ArraySet
			local b=GearChangerByIakoni.savedVariables.ArraySetSavedFlag

			--loop through the currently shown inventory items
			for _,v in pairs(list.activeControls) do
				local bag = v.dataEntry.data.bagId
				local slot = v.dataEntry.data.slotIndex
				if bag ~= nil and slot ~= nil then
					local itemID = Id64ToString(GetItemUniqueId(bag, slot))
					local marker = v:GetNamedChild("GCBISet")
					if not marker then
						marker = GearChangerByIakoni.CreateControlMarker(v)
					end
					marker:SetHidden(true)
					
					local itemType = GetItemType(bag, slot)
					
					if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
						local founditem = false

						for i=1, 10 do
							if b[i] == 1 then --check only if the set is saved
								for _,u in pairs(GearChangerByIakoni.WornArray) do
									if itemID==a[i][u] then
										marker:SetHidden(false)
										founditem = true
										break
									end
								end
							end
							
							if founditem then
								break
							end
						end
					end
				end 
			end 
		end
		GearChangerByIakoni.DoRefresh = GearChangerByIakoni_DoRefresh
	end
end

function AutoCategory.HookKeyboardMode()
	--Add a new data type: row with header
	local function AC_Setup_InventoryRowWithHeader(rowControl, slot, overrideOptions)
		--PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listSetupCallback(rowControl:GetNamedChild("InventoryItemRow"), slot, overrideOptions)
		--PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listSetupCallback(rowControl, slot, overrideOptions)
		--set header
		rowControl:GetNamedChild("HeaderName"):SetText(slot.bestItemTypeName)
	end
	ZO_ScrollList_AddDataType(ZO_PlayerInventoryList, 998, "AC_InventoryItemRowHeader", 40, AC_Setup_InventoryRowWithHeader, PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listHiddenCallback, nil, ZO_InventorySlot_OnPoolReset)
	ZO_ScrollList_AddDataType(ZO_CraftBagList, 998, "AC_InventoryItemRowHeader", 40, AC_Setup_InventoryRowWithHeader, PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listHiddenCallback, nil, ZO_InventorySlot_OnPoolReset)
	ZO_ScrollList_AddDataType(ZO_PlayerBankBackpack, 998, "AC_InventoryItemRowHeader", 40, AC_Setup_InventoryRowWithHeader, PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listHiddenCallback, nil, ZO_InventorySlot_OnPoolReset)
	ZO_ScrollList_AddDataType(ZO_GuildBankBackpack, 998, "AC_InventoryItemRowHeader", 40, AC_Setup_InventoryRowWithHeader, PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listHiddenCallback, nil, ZO_InventorySlot_OnPoolReset)
          
    --Custom sort with group name
	local function ZO_InventoryManager_ApplySort(self, inventoryType)
	    local inventory
	    if inventoryType == INVENTORY_BANK then
	        inventory = self.inventories[INVENTORY_BANK]
	    elseif inventoryType == INVENTORY_GUILD_BANK then
	        inventory = self.inventories[INVENTORY_GUILD_BANK]
	    elseif inventoryType == INVENTORY_CRAFT_BAG then
	        inventory = self.inventories[INVENTORY_CRAFT_BAG]
	    else
	        -- Use normal inventory by default (instead of the quest item inventory for example)
	        inventory = self.inventories[self.selectedTabType]
	    end

	    local list = inventory.listView
	    local scrollData = ZO_ScrollList_GetDataList(list)

	    if inventory.sortFn == nil then
	        inventory.sortFn =  function(entry1, entry2)
	                                return ZO_TableOrderingFunction(entry1.data, entry2.data, inventory.currentSortKey, sortKeys, inventory.currentSortOrder)
	                            end
	    end

	    table.sort(scrollData, inventory.sortFn) 
 
        -- change data type
	    local lastBestItemCategoryName
        scrollData = ZO_ScrollList_GetDataList(list)
        local newScrollData = {}
	    for i, entry in ipairs(scrollData) do 
	    	if entry.typeId ~= 998 then
		        if entry.bestItemTypeName ~= lastBestItemCategoryName then
		            lastBestItemCategoryName = entry.bestItemTypeName
		            table.insert(newScrollData, ZO_ScrollList_CreateDataEntry(998, {bestItemTypeName = entry.bestItemTypeName, stackLaunderPrice = 0}))
		        end
		        table.insert(newScrollData, entry)
	    	end
	    end
	    list.data = newScrollData

	    ZO_ScrollList_Commit(list)
	end

	local function ZO_InventoryManager_UpdateList(self, inventoryType, updateEvenIfHidden)
	    local inventory = self.inventories[inventoryType]

	    --temp, need switch
	    inventory.sortFn = function(left, right)
		    if right.sortPriorityName ~= left.sortPriorityName then
		        return NilOrLessThan(left.sortPriorityName, right.sortPriorityName)
		    end
		    return ZO_TableOrderingFunction(left.data, right.data, inventory.currentSortKey, sortKeys, inventory.currentSortOrder)
		end

	    local list = inventory.listView
	    if (list and not list:IsHidden()) or updateEvenIfHidden then
	        local scrollData = ZO_ScrollList_GetDataList(list)
	        ZO_ScrollList_Clear(list)

	        -- TODO: possibly change the quest item implementation to just be a list of slots instead of being indexed by questIndex/slot
	        -- For now just write two different iteration functions for quest/real inventories.

	        self.cachedSearchText = inventory.searchBox:GetText()

	        if inventoryType == INVENTORY_QUEST_ITEM then
	            local questItems = inventory.slots
	            for questIndex, questItemTable in pairs(questItems) do
	                for questItemIndex = 1, #questItemTable do
	                    local slotData = questItemTable[questItemIndex]

	                    if(self:ShouldAddSlotToList(inventory, slotData)) then
	                        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(inventory.listDataType, slotData)
	                    end
	                end
	            end
	        else
	            local slots = inventory.slots
	            for bagIndex, bagId in ipairs(inventory.backingBags) do
	                if slots[bagId] then
	                    for slotIndex, slotData in pairs(slots[bagId]) do
	                        if self:ShouldAddSlotToList(inventory, slotData) then
	                        	local entry = ZO_ScrollList_CreateDataEntry(inventory.listDataType, slotData)

								local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex)
								if not matched then
						            entry.bestItemTypeName = AC_UNGROUPED_NAME 
						            entry.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
								else
									entry.bestItemTypeName = categoryName 
									entry.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
								end
	                            scrollData[#scrollData + 1] = entry
	                        end
	                    end
	                end
	            end
	        end

	        self.cachedSearchText = nil

	        -- don't commit after sort, need fix data
	        self:ApplySort(inventoryType)

	        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.bankWithdrawTabKeybindButtonGroup)

	        local isEmptyList = not ZO_ScrollList_HasVisibleData(list)
	        if inventory.sortHeaders then
	            inventory.sortHeaders.headerContainer:SetHidden(isEmptyList)
	        end
	        self:UpdateEmptyBagLabel(inventoryType, isEmptyList)

	        self.isListDirty[inventoryType] = false      
	    else
	        self.isListDirty[inventoryType] = true
	    end
	end
	local originalUpdateList = ZO_InventoryManager.UpdateList
	local originalApplySort = ZO_InventoryManager.ApplySort
	ZO_InventoryManager.UpdateList = function(...)
		if IsInGamepadPreferredMode() then
			originalUpdateList(...)
		else
			ZO_InventoryManager_UpdateList(...)
		end
	end
	ZO_InventoryManager.ApplySort = function(...)
		if IsInGamepadPreferredMode() then
			originalApplySort(...)
		else
			ZO_InventoryManager_ApplySort(...)
		end
	end	
end

function AutoCategory.HookGamepadCraft()
	local function ZO_GamepadCraftingInventory_GetIndividualInventorySlotsAndAddToScrollData(self, predicate, filterFunction, filterType, data, useWornBag)
	    local bagsToUse = useWornBag and ZO_ALL_CRAFTING_INVENTORY_BAGS_AND_WORN or ZO_ALL_CRAFTING_INVENTORY_BAGS_WITHOUT_WORN
	    local list = SHARED_INVENTORY:GenerateFullSlotData(predicate, unpack(bagsToUse))

	    ZO_ClearTable(self.itemCounts)

	    local filteredDataTable = {}
	    for i, slotData in ipairs(list) do
	        local bagId = slotData.bagId
	        local slotIndex = slotData.slotIndex
	        if not filterFunction or filterFunction(bagId, slotIndex, filterType) then
	            local itemName = GetItemName(bagId, slotIndex)
	            local icon = GetItemInfo(bagId, slotIndex)
	            local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)
	            local customSortData = self.customDataSortFunction and self.customDataSortFunction(bagId, slotIndex) or 0

	            local data = ZO_GamepadEntryData:New(name)
	            data:InitializeCraftingInventoryVisualData(slotData.bagId, slotData.slotIndex, slotData.stackCount, customSortData, slotData)
	            -- if slotData.bagId == BAG_WORN then
	            --     data.bestItemCategoryName = zo_strformat(GetString(SI_GAMEPAD_SECTION_HEADER_EQUIPPED_ITEM), data.bestItemCategoryName)
	            -- end

				local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex)
				if not matched then
		            data.bestItemTypeName = AC_UNGROUPED_NAME
		            data.bestItemCategoryName = AC_UNGROUPED_NAME
		            data.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
				else
					data.bestItemTypeName = categoryName
					data.bestItemCategoryName = categoryName
					data.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
				end

	            ZO_InventorySlot_SetType(data, self.baseSlotType)
	            filteredDataTable[#filteredDataTable + 1] = data

	            if self.customExtraDataFunction then
	                self.customExtraDataFunction(bagId, slotIndex, filteredDataTable[#filteredDataTable])
	            end
	        end
	        self.itemCounts[i] = slotData.stackCount
	    end

	    table.sort(filteredDataTable, AutoCategory_ItemSortComparator)

	    local lastBestItemCategoryName
	    for i, itemData in ipairs(filteredDataTable) do
	        if itemData.bestItemCategoryName ~= lastBestItemCategoryName then
	            lastBestItemCategoryName = itemData.bestItemCategoryName
	            itemData:SetHeader(zo_strformat(SI_GAMEPAD_CRAFTING_INVENTORY_HEADER, lastBestItemCategoryName))
	        end

	        local template = self:GetListEntryTemplate(itemData)

	        self.list:AddEntry(template, itemData)
	    end

	    return list
	end

	ZO_GamepadCraftingInventory.GetIndividualInventorySlotsAndAddToScrollData = ZO_GamepadCraftingInventory_GetIndividualInventorySlotsAndAddToScrollData
end

function AutoCategory.HookGamepadStore(list)
	--change item 
	local originalUpdateFunc = list.updateFunc
	list.updateFunc = function( ... )
		local filteredDataTable = originalUpdateFunc(...)
		--add new fields to item data
		local tempDataTable = {}
		for i = 1, #filteredDataTable  do
			local itemData = filteredDataTable[i]
			--use custom categories

			local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(itemData.bagId, itemData.slotIndex)
			if not matched then
	            itemData.bestItemTypeName = AC_UNGROUPED_NAME
	            itemData.bestGamepadItemCategoryName = AC_UNGROUPED_NAME
	            itemData.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
			else
				itemData.bestItemTypeName = categoryName
				itemData.bestGamepadItemCategoryName = categoryName
				itemData.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
			end

	        table.insert(tempDataTable, itemData)
		end
		filteredDataTable = tempDataTable
		return filteredDataTable
	end

	list.sortFunc = AutoCategory_ItemSortComparator
end

function AutoCategory.LazyInit()
	if not AutoCategory.Inited then
		-- load our saved variables
		AutoCategory.charSavedVariables = ZO_SavedVars:New('AutoCategorySavedVars', 1.1, nil, AutoCategory.defaultSettings)
		AutoCategory.acctSavedVariables = ZO_SavedVars:NewAccountWide('AutoCategorySavedVars', 1.1, nil, AutoCategory.defaultAcctSettings)
		--removeSameNamedCategory(AutoCategory.charSavedVariables.categorySettings)
		--removeSameNamedCategory(AutoCategory.acctSavedVariables.categorySettings)
		
		AutoCategory.AddonMenuInit()
		
		AutoCategory.HookGamepadCraft()
		AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_SELL].list)
		AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_BUY_BACK].list)

		AutoCategory.HookKeyboardMode()

		--capabilities with other add-ons
		FixIakoniGearChanger()

		AutoCategory.Inited = true
	end
end

function AutoCategory.Initialize(event, addon)
    -- filter for just BUI addon event as EVENT_ADD_ON_LOADED is addon-blind
	if addon ~= AutoCategory.name then return end

    SLASH_COMMANDS["/ac"] = AutoCategory.cmd
	AutoCategory.LazyInit()
end


--== Slash command ==--
function AutoCategory.cmd( text )
	if text == nil then text = true end
    LAM2:OpenToPanel(AC_CATEGORY_SETTINGS) 
	local addons = LAM2.addonList:GetChild(1)
	if addons:GetNumChildren() ~= 0 then
		for a=1,addons:GetNumChildren(),1 do 
			if addons:GetChild(a):GetText() == AutoCategory.settingName then
				addons:GetChild(a):SetSelected(true)
				break
			end	
		end
	end	
	--Second time's the charm
	if text then
		zo_callLater(function()AutoCategory.cmd(false)end,500)
	end
end
-- register our event handler function to be called to do initialization
EVENT_MANAGER:RegisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED, function(...) AutoCategory.Initialize(...) end)