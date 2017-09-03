------------------
--LOAD LIBRARIES--
------------------

--load LibAddonsMenu-2.0
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0");

----------------------
--INITIATE VARIABLES--
----------------------

--create Addon UI table
AutoCategory = {};
AutoCategory.RuleFunc = {}
AutoCategory.Inited = false

AutoCategory.name = "AutoCategory";
AutoCategory.version = 1.00;
AutoCategory.settingName = "Auto Category"
AutoCategory.settingDisplayName = "RockingDice's AutoCategory"
AutoCategory.author = "RockingDice"

AC_UNGROUPED_NAME = "Others"
AC_EMPTY_TAG_NAME = "<Empty>"

AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3

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
	if not AutoCategory.acctSavedVariables.accountWideSetting  then
		AutoCategory.curSavedVars = AutoCategory.charSavedVariables
		d("Use Character setting")
	else 
		AutoCategory.curSavedVars = AutoCategory.acctSavedVariables
		d("Use Accountwide Setting")
	end
end

function AutoCategory.ResetToDefaults()
	if not AutoCategory.acctSavedVariables.accountWideSetting  then
		AutoCategory.curSavedVars.rules = AutoCategory.defaultSettings.rules
		AutoCategory.curSavedVars.bags = AutoCategory.defaultSettings.bags 
	else 
		AutoCategory.curSavedVars.rules = AutoCategory.defaultAcctSettings.rules
		AutoCategory.curSavedVars.bags = AutoCategory.defaultAcctSettings.bags 
	end
end
AutoCategory.defaultSettings = {
	rules = {

	},
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {},
		},
	}, 
}


AutoCategory.defaultAcctSettings = {
	rules = {

	},
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {},
		},
	}, 
	--account specific settings
	accountWideSetting = false
}

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
        
    -- fix fence- launder issue
	function ZO_Fence_Keyboard_OnEnterLaunder(self, totalLaunders, laundersUsed)
	    self.mode = ZO_MODE_STORE_LAUNDER
	    ZO_PlayerInventoryInfoBarAltFreeSlots:SetHidden(false)
	    ZO_PlayerInventoryInfoBarAltMoney:SetHidden(true)
	    self:UpdateTransactionLabel(totalLaunders, laundersUsed, SI_FENCE_LAUNDER_LIMIT, SI_FENCE_LAUNDER_LIMIT_REACHED)

	    local function ColorCost(control, data, scrollList)
	        priceControl = control:GetNamedChild("SellPrice")
	        if priceControl then
		        ZO_CurrencyControl_SetCurrencyData(priceControl, CURT_MONEY, data.stackLaunderPrice, CURRENCY_DONT_SHOW_ALL, (GetCarriedCurrencyAmount(CURT_MONEY) < data.stackLaunderPrice))
		        ZO_CurrencyControl_SetCurrency(priceControl, ZO_KEYBOARD_CURRENCY_OPTIONS)
		    end
	    end

	    PLAYER_INVENTORY:RefreshBackpackWithFenceData(ColorCost)
	    ZO_PlayerInventorySortByPriceName:SetText(GetString(SI_LAUNDER_SORT_TYPE_COST))
	    self:RefreshFooter()
	end
	ZO_Fence_Keyboard.OnEnterLaunder = ZO_Fence_Keyboard_OnEnterLaunder

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
		            table.insert(newScrollData, ZO_ScrollList_CreateDataEntry(998, {bestItemTypeName = entry.bestItemTypeName}))
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
		
		AutoCategory.AddonMenu.Init()
		
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


--============Rule Function==============--

function AutoCategory.RuleFunc.SpecializedItemType( ... )
	local fn = "type"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		local _, sptype = GetItemLinkItemType(itemLink)
		if type( arg ) == "number" then
			if arg == sptype then
				return true
			end
		elseif type( arg ) == "string" then
			
			local itemTypeMap = {
				["additive"] = SPECIALIZED_ITEMTYPE_ADDITIVE,
				["armor"] = SPECIALIZED_ITEMTYPE_ARMOR,
				["armor_booster"] = SPECIALIZED_ITEMTYPE_ARMOR_BOOSTER,
				["armor_trait"] = SPECIALIZED_ITEMTYPE_ARMOR_TRAIT,
				["ava_repair"] = SPECIALIZED_ITEMTYPE_AVA_REPAIR,
				["blacksmithing_booster"] = SPECIALIZED_ITEMTYPE_BLACKSMITHING_BOOSTER,
				["blacksmithing_material"] = SPECIALIZED_ITEMTYPE_BLACKSMITHING_MATERIAL,
				["blacksmithing_raw_material"] = SPECIALIZED_ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
				["clothier_booster"] = SPECIALIZED_ITEMTYPE_CLOTHIER_BOOSTER,
				["clothier_material"] = SPECIALIZED_ITEMTYPE_CLOTHIER_MATERIAL,
				["clothier_raw_material"] = SPECIALIZED_ITEMTYPE_CLOTHIER_RAW_MATERIAL,
				["collectible_monster_trophy"] = SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY,
				["collectible_rare_fish"] = SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH,
				["container"] = SPECIALIZED_ITEMTYPE_CONTAINER,
				["container_event"] = SPECIALIZED_ITEMTYPE_CONTAINER_EVENT,
				["costume"] = SPECIALIZED_ITEMTYPE_COSTUME,
				["crown_item"] = SPECIALIZED_ITEMTYPE_CROWN_ITEM,
				["crown_repair"] = SPECIALIZED_ITEMTYPE_CROWN_REPAIR,
				["disguise"] = SPECIALIZED_ITEMTYPE_DISGUISE,
				["drink_alcoholic"] = SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC,
				["drink_cordial_tea"] = SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA,
				["drink_distillate"] = SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE,
				["drink_liqueur"] = SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR,
				["drink_tea"] = SPECIALIZED_ITEMTYPE_DRINK_TEA,
				["drink_tincture"] = SPECIALIZED_ITEMTYPE_DRINK_TINCTURE,
				["drink_tonic"] = SPECIALIZED_ITEMTYPE_DRINK_TONIC,
				["drink_unique"] = SPECIALIZED_ITEMTYPE_DRINK_UNIQUE,
				["dye_stamp"] = SPECIALIZED_ITEMTYPE_DYE_STAMP,
				["enchanting_rune_aspect"] = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ASPECT,
				["enchanting_rune_essence"] = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
				["enchanting_rune_potency"] = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_POTENCY,
				["enchantment_booster"] = SPECIALIZED_ITEMTYPE_ENCHANTMENT_BOOSTER,
				["fish"] = SPECIALIZED_ITEMTYPE_FISH,
				["flavoring"] = SPECIALIZED_ITEMTYPE_FLAVORING,
				["food_entremet"] = SPECIALIZED_ITEMTYPE_FOOD_ENTREMET,
				["food_fruit"] = SPECIALIZED_ITEMTYPE_FOOD_FRUIT,
				["food_gourmet"] = SPECIALIZED_ITEMTYPE_FOOD_GOURMET,
				["food_meat"] = SPECIALIZED_ITEMTYPE_FOOD_MEAT,
				["food_ragout"] = SPECIALIZED_ITEMTYPE_FOOD_RAGOUT,
				["food_savoury"] = SPECIALIZED_ITEMTYPE_FOOD_SAVOURY,
				["food_unique"] = SPECIALIZED_ITEMTYPE_FOOD_UNIQUE,
				["food_vegetable"] = SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE,
				["furnishing_crafting_station"] = SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION,
				["furnishing_light"] = SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT,
				["furnishing_material_alchemy"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY,
				["furnishing_material_blacksmithing"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING,
				["furnishing_material_clothier"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER,
				["furnishing_material_enchanting"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING,
				["furnishing_material_provisioning"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING,
				["furnishing_material_woodworking"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING,
				["furnishing_ornamental"] = SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL,
				["furnishing_seating"] = SPECIALIZED_ITEMTYPE_FURNISHING_SEATING,
				["furnishing_target_dummy"] = SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY,
				["glyph_armor"] = SPECIALIZED_ITEMTYPE_GLYPH_ARMOR,
				["glyph_jewelry"] = SPECIALIZED_ITEMTYPE_GLYPH_JEWELRY,
				["glyph_weapon"] = SPECIALIZED_ITEMTYPE_GLYPH_WEAPON,
				["ingredient_alcohol"] = SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL,
				["ingredient_drink_additive"] = SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE,
				["ingredient_food_additive"] = SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE,
				["ingredient_fruit"] = SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT,
				["ingredient_meat"] = SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT,
				["ingredient_rare"] = SPECIALIZED_ITEMTYPE_INGREDIENT_RARE,
				["ingredient_tea"] = SPECIALIZED_ITEMTYPE_INGREDIENT_TEA,
				["ingredient_tonic"] = SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC,
				["ingredient_vegetable"] = SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE,
				["lockpick"] = SPECIALIZED_ITEMTYPE_LOCKPICK,
				["lure"] = SPECIALIZED_ITEMTYPE_LURE,
				["master_writ"] = SPECIALIZED_ITEMTYPE_MASTER_WRIT,
				["mount"] = SPECIALIZED_ITEMTYPE_MOUNT,
				["none"] = SPECIALIZED_ITEMTYPE_NONE,
				["plug"] = SPECIALIZED_ITEMTYPE_PLUG,
				["poison"] = SPECIALIZED_ITEMTYPE_POISON,
				["poison_base"] = SPECIALIZED_ITEMTYPE_POISON_BASE,
				["potion"] = SPECIALIZED_ITEMTYPE_POTION,
				["potion_base"] = SPECIALIZED_ITEMTYPE_POTION_BASE,
				["racial_style_motif_book"] = SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK,
				["racial_style_motif_chapter"] = SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER,
				["raw_material"] = SPECIALIZED_ITEMTYPE_RAW_MATERIAL,
				["reagent_animal_part"] = SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART,
				["reagent_fungus"] = SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS,
				["reagent_herb"] = SPECIALIZED_ITEMTYPE_REAGENT_HERB,
				["recipe_alchemy_formula_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
				["recipe_blacksmithing_diagram_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
				["recipe_clothier_pattern_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
				["recipe_enchanting_schematic_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
				["recipe_provisioning_design_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
				["recipe_provisioning_standard_drink"] = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
				["recipe_provisioning_standard_food"] = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD,
				["recipe_woodworking_blueprint_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
				["siege_ballista"] = SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA,
				["siege_battle_standard"] = SPECIALIZED_ITEMTYPE_SIEGE_BATTLE_STANDARD,
				["siege_catapult"] = SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT,
				["siege_graveyard"] = SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD,
				["siege_monster"] = SPECIALIZED_ITEMTYPE_SIEGE_MONSTER,
				["siege_oil"] = SPECIALIZED_ITEMTYPE_SIEGE_OIL,
				["siege_ram"] = SPECIALIZED_ITEMTYPE_SIEGE_RAM,
				["siege_trebuchet"] = SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET,
				["siege_universal"] = SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL,
				["soul_gem"] = SPECIALIZED_ITEMTYPE_SOUL_GEM,
				["spellcrafting_tablet"] = SPECIALIZED_ITEMTYPE_SPELLCRAFTING_TABLET,
				["spice"] = SPECIALIZED_ITEMTYPE_SPICE,
				["style_material"] = SPECIALIZED_ITEMTYPE_STYLE_MATERIAL,
				["tabard"] = SPECIALIZED_ITEMTYPE_TABARD,
				["tool"] = SPECIALIZED_ITEMTYPE_TOOL,
				["trash"] = SPECIALIZED_ITEMTYPE_TRASH,
				["treasure"] = SPECIALIZED_ITEMTYPE_TREASURE,
				["trophy_key"] = SPECIALIZED_ITEMTYPE_TROPHY_KEY,
				["trophy_key_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
				["trophy_material_upgrader"] = SPECIALIZED_ITEMTYPE_TROPHY_MATERIAL_UPGRADER,
				["trophy_museum_piece"] = SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE,
				["trophy_recipe_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
				["trophy_runebox_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
				["trophy_scroll"] = SPECIALIZED_ITEMTYPE_TROPHY_SCROLL,
				["trophy_survey_report"] = SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT,
				["trophy_treasure_map"] = SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
				["weapon"] = SPECIALIZED_ITEMTYPE_WEAPON,
				["weapon_booster"] = SPECIALIZED_ITEMTYPE_WEAPON_BOOSTER,
				["weapon_trait"] = SPECIALIZED_ITEMTYPE_WEAPON_TRAIT,
				["woodworking_booster"] = SPECIALIZED_ITEMTYPE_WOODWORKING_BOOSTER,
				["woodworking_material"] = SPECIALIZED_ITEMTYPE_WOODWORKING_MATERIAL,
				["woodworking_raw_material"] = SPECIALIZED_ITEMTYPE_WOODWORKING_RAW_MATERIAL,
			}
			local v = itemTypeMap[string.lower( arg )]
			if v and v == sptype then
				return true
			end
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		
	end
	
	return false
	
end

function AutoCategory.RuleFunc.ItemType( ... )
	local fn = "type"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		local itemType = GetItemLinkItemType(itemLink)
		if type( arg ) == "number" then
			if arg == itemType then
				return true
			end
		elseif type( arg ) == "string" then
			
		local itemTypeMap = {
				["additive"] = ITEMTYPE_ADDITIVE,
				["armor"] = ITEMTYPE_ARMOR,
				["armor_booster"] = ITEMTYPE_ARMOR_BOOSTER,
				["armor_trait"] = ITEMTYPE_ARMOR_TRAIT,
				["ava_repair"] = ITEMTYPE_AVA_REPAIR,
				["blacksmithing_booster"] = ITEMTYPE_BLACKSMITHING_BOOSTER,
				["blacksmithing_material"] = ITEMTYPE_BLACKSMITHING_MATERIAL,
				["blacksmithing_raw_material"] = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
				["clothier_booster"] = ITEMTYPE_CLOTHIER_BOOSTER,
				["clothier_material"] = ITEMTYPE_CLOTHIER_MATERIAL,
				["clothier_raw_material"] = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
				["collectible"] = ITEMTYPE_COLLECTIBLE,
				["container"] = ITEMTYPE_CONTAINER,
				["costume"] = ITEMTYPE_COSTUME,
				["crown_item"] = ITEMTYPE_CROWN_ITEM,
				["crown_repair"] = ITEMTYPE_CROWN_REPAIR,
				["deprecated"] = ITEMTYPE_DEPRECATED,
				["disguise"] = ITEMTYPE_DISGUISE,
				["drink"] = ITEMTYPE_DRINK,
				["dye_stamp"] = ITEMTYPE_DYE_STAMP,
				["enchanting_rune_aspect"] = ITEMTYPE_ENCHANTING_RUNE_ASPECT,
				["enchanting_rune_essence"] = ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
				["enchanting_rune_potency"] = ITEMTYPE_ENCHANTING_RUNE_POTENCY,
				["enchantment_booster"] = ITEMTYPE_ENCHANTMENT_BOOSTER,
				["fish"] = ITEMTYPE_FISH,
				["flavoring"] = ITEMTYPE_FLAVORING,
				["food"] = ITEMTYPE_FOOD,
				["furnishing"] = ITEMTYPE_FURNISHING,
				["furnishing_material"] = ITEMTYPE_FURNISHING_MATERIAL,
				["glyph_armor"] = ITEMTYPE_GLYPH_ARMOR,
				["glyph_jewelry"] = ITEMTYPE_GLYPH_JEWELRY,
				["glyph_weapon"] = ITEMTYPE_GLYPH_WEAPON,
				["ingredient"] = ITEMTYPE_INGREDIENT,
				["lockpick"] = ITEMTYPE_LOCKPICK,
				["lure"] = ITEMTYPE_LURE,
				["master_writ"] = ITEMTYPE_MASTER_WRIT,
				["mount"] = ITEMTYPE_MOUNT,
				["none"] = ITEMTYPE_NONE,
				["plug"] = ITEMTYPE_PLUG,
				["poison"] = ITEMTYPE_POISON,
				["poison_base"] = ITEMTYPE_POISON_BASE,
				["potion"] = ITEMTYPE_POTION,
				["potion_base"] = ITEMTYPE_POTION_BASE,
				["racial_style_motif"] = ITEMTYPE_RACIAL_STYLE_MOTIF,
				["raw_material"] = ITEMTYPE_RAW_MATERIAL,
				["reagent"] = ITEMTYPE_REAGENT,
				["recipe"] = ITEMTYPE_RECIPE,
				["siege"] = ITEMTYPE_SIEGE,
				["soul_gem"] = ITEMTYPE_SOUL_GEM,
				["spellcrafting_tablet"] = ITEMTYPE_SPELLCRAFTING_TABLET,
				["spice"] = ITEMTYPE_SPICE,
				["style_material"] = ITEMTYPE_STYLE_MATERIAL,
				["tabard"] = ITEMTYPE_TABARD,
				["tool"] = ITEMTYPE_TOOL,
				["trash"] = ITEMTYPE_TRASH,
				["treasure"] = ITEMTYPE_TREASURE,
				["trophy"] = ITEMTYPE_TROPHY,
				["weapon"] = ITEMTYPE_WEAPON,
				["weapon_booster"] = ITEMTYPE_WEAPON_BOOSTER,
				["weapon_trait"] = ITEMTYPE_WEAPON_TRAIT,
				["woodworking_booster"] = ITEMTYPE_WOODWORKING_BOOSTER,
				["woodworking_material"] = ITEMTYPE_WOODWORKING_MATERIAL,
				["woodworking_raw_material"] = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
			}
			local v = itemTypeMap[string.lower( arg )]
			if v and v == itemType then
				return true
			end
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		
	end
	
	return false
	
end

function AutoCategory.RuleFunc.EquipType( ... )
	local fn = "equiptype"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local _, _, _, _, _, equipType = GetItemInfo(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)

		if type( arg ) == "number" then
			if arg == equipType then
				return true
			end
		elseif type( arg ) == "string" then
			
			local itemTypeMap = {
				["chest"] = EQUIP_TYPE_CHEST,
				["costume"] = EQUIP_TYPE_COSTUME,
				["feet"] = EQUIP_TYPE_FEET,
				["hand"] = EQUIP_TYPE_HAND,
				["head"] = EQUIP_TYPE_HEAD,
				["invalid"] = EQUIP_TYPE_INVALID,
				["legs"] = EQUIP_TYPE_LEGS,
				["main_hand"] = EQUIP_TYPE_MAIN_HAND,
				["neck"] = EQUIP_TYPE_NECK,
				["off_hand"] = EQUIP_TYPE_OFF_HAND,
				["one_hand"] = EQUIP_TYPE_ONE_HAND,
				["poison"] = EQUIP_TYPE_POISON,
				["ring"] = EQUIP_TYPE_RING,
				["shoulders"] = EQUIP_TYPE_SHOULDERS,
				["two_hand"] = EQUIP_TYPE_TWO_HAND,
				["waist"] = EQUIP_TYPE_WAIST,
			}
			local v = itemTypeMap[string.lower( arg )]
			if v and v == equipType then
				return true
			end
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		
	end
	
	return false
	
end

function AutoCategory.RuleFunc.IsBound( ... )
	local fn = "isbound"
	
	local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	local isBound = IsItemLinkBound(itemLink)
	return isBound
end

function AutoCategory.RuleFunc.IsNew( ... )
	local fn = "isnew"

	return SHARED_INVENTORY:IsItemNew(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
end

function AutoCategory.RuleFunc.BoundType( ... )
	local fn = "boundtype"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		local boundType = GetItemLinkBindType(itemLink)
		if type( arg ) == "number" then
			if arg == boundType then
				return true
			end
		elseif type( arg ) == "string" then
			
		local itemTypeMap = {
				["none"] = BIND_TYPE_NONE,
				["on_equip"] = BIND_TYPE_ON_EQUIP,
				["on_pickup"] = BIND_TYPE_ON_PICKUP,
				["on_pickup_backpack"] = BIND_TYPE_ON_PICKUP_BACKPACK,
				["unset"] = BIND_TYPE_UNSET,
			}
			local v = itemTypeMap[string.lower( arg )]
			if v and v == boundType then
				return true
			end
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		
	end
	
	return false
	
end


function AutoCategory.RuleFunc.FilterType( ... )
	local fn = "filtertype"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	local itemTypeMap = {
				["alchemy"] = ITEMFILTERTYPE_ALCHEMY,
				["all"] = ITEMFILTERTYPE_ALL,
				["armor"] = ITEMFILTERTYPE_ARMOR,
				["blacksmithing"] = ITEMFILTERTYPE_BLACKSMITHING,
				["buyback"] = ITEMFILTERTYPE_BUYBACK,
				["clothing"] = ITEMFILTERTYPE_CLOTHING,
				["collectible"] = ITEMFILTERTYPE_COLLECTIBLE,
				["consumable"] = ITEMFILTERTYPE_CONSUMABLE,
				["crafting"] = ITEMFILTERTYPE_CRAFTING,
				["damaged"] = ITEMFILTERTYPE_DAMAGED,
				["enchanting"] = ITEMFILTERTYPE_ENCHANTING,
				["furnishing"] = ITEMFILTERTYPE_FURNISHING,
				["house_with_template"] = ITEMFILTERTYPE_HOUSE_WITH_TEMPLATE,
				["junk"] = ITEMFILTERTYPE_JUNK,
				["miscellaneous"] = ITEMFILTERTYPE_MISCELLANEOUS,
				["provisioning"] = ITEMFILTERTYPE_PROVISIONING,
				["quest"] = ITEMFILTERTYPE_QUEST,
				["quickslot"] = ITEMFILTERTYPE_QUICKSLOT,
				["reuse"] = ITEMFILTERTYPE_REUSE,
				["style_materials"] = ITEMFILTERTYPE_STYLE_MATERIALS,
				["trait_items"] = ITEMFILTERTYPE_TRAIT_ITEMS,
				["weapons"] = ITEMFILTERTYPE_WEAPONS,
				["woodworking"] = ITEMFILTERTYPE_WOODWORKING,
	}
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local itemFilterType = { GetItemFilterTypeInfo(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex) }
		local testFilterType
		if type( arg ) == "number" then
			testFilterType = arg
		elseif type( arg ) == "string" then  
			testFilterType = itemTypeMap[string.lower( arg )]
			if testFilterType == nil then
				error( string.format("error: %s(): argument '%s' is not recoginzed.", fn, string.lower(arg)))
			end			
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		for i = 1, #itemFilterType do
			if itemFilterType[i] == testFilterType then
				return true
			end
		end
	end
	
	return false
	
end

function AutoCategory.RuleFunc.Level( ... )
	local fn = "level"
	local level = GetItemRequiredLevel(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	return level
end


function AutoCategory.RuleFunc.CPLevel( ... )
	local fn = "cp"
	local level = GetItemRequiredChampionPoints(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	return level
end


function AutoCategory.RuleFunc.KeepForResearch( ... )
	if GamePadBuddy then
		local itemFlagStatus = GamePadBuddy:GetItemFlagStatus(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		return itemFlagStatus == GamePadBuddy.CONST.ItemFlags.ITEM_FLAG_TRAIT_RESEARABLE
	else
		return true
	end
end

function AutoCategory.RuleFunc.SetName( ... )
	local fn = "set"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		local hasSet, setName = GetItemLinkSetInfo(itemLink)
		if not hasSet then
			return false
		end
		local findString
		if type( arg ) == "number" then
			findString = tostring(arg)
		elseif type( arg ) == "string" then
			findString = arg
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		if string.find(setName, findString, 1 ,true) then
			return true
		end
	end
	
	return false
end


function AutoCategory.RuleFunc.AutoSetName( ... )
	local fn = "autoset"

	local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	local hasSet, setName = GetItemLinkSetInfo(itemLink)
	if not hasSet then
		return false
	end
	AutoCategory.AdditionCategoryName = AutoCategory.AdditionCategoryName .. string.format(" (%s)", setName)
	return true
end

function AutoCategory.RuleFunc.Trait( ... )
	local fn = "trait"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		
		local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		local traitType, _ = GetItemLinkTraitInfo(itemLink)
		local traitText = GetString("SI_ITEMTRAITTYPE", traitType)
		local findString;
		if type( arg ) == "number" then
			findString = tostring(arg)
		elseif type( arg ) == "string" then
			findString = arg
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		if string.find(traitText, findString, 1, true) then
			return true
		end 
	end
	
	return false
	
end


local function IokaniGearChanger_GetGearSet(bagId, slotIndex)
	local result = {}
	if GearChangerByIakoni and GearChangerByIakoni.savedVariables then
		local itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			local a=GearChangerByIakoni.savedVariables.ArraySet
			local b=GearChangerByIakoni.savedVariables.ArraySetSavedFlag
			local itemID = Id64ToString(GetItemUniqueId(bagId, slotIndex))
			for i=1, 10 do
				if b[i] == 1 then --check only if the set is saved
					for _,u in pairs(GearChangerByIakoni.WornArray) do
						if itemID==a[i][u] then
							--find gear in set i
							table.insert(result, i)
						end
					end
				end
			end	
		end
	end
	return result
end

function AutoCategory.RuleFunc.SetIndex( ... )
	local fn = "setindex"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	local setIndices = IokaniGearChanger_GetGearSet(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		local comIndex = -1
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		if type( arg ) == "number" then
			comIndex = arg
		elseif type( arg ) == "string" then
			comIndex = tonumber(arg)
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		for i=1, #setIndices do
			local index = setIndices[i]
			if comIndex == index then
				return true
			end
		end 
	end
	
	return false 
end

function AutoCategory.RuleFunc.InSet( ... )
	local fn = "inset"
	
	local setIndices = IokaniGearChanger_GetGearSet(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	return #setIndices ~= 0
end

function AutoCategory.RuleFunc.IsEquipping( ... )
	local fn = "isequipping"
	return AutoCategory.checkingItemBagId == BAG_WORN
end

function AutoCategory.RuleFunc.IsInQuickslot( ... )
	local fn = "isinquickslot"
	local slotIndex = GetItemCurrentActionBarSlot(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	return slotIndex ~= nil
end

AutoCategory.Environment = {
	-- rule functions
	
	type = AutoCategory.RuleFunc.ItemType,
	
	sptype = AutoCategory.RuleFunc.SpecializedItemType,

	equiptype = AutoCategory.RuleFunc.EquipType,

	filtertype = AutoCategory.RuleFunc.FilterType,

	isnew = AutoCategory.RuleFunc.IsNew,
	
	isbound = AutoCategory.RuleFunc.IsBound,
	
	boundtype = AutoCategory.RuleFunc.BoundType,
	
	level = AutoCategory.RuleFunc.Level,
	
	cp = AutoCategory.RuleFunc.CPLevel,

	set = AutoCategory.RuleFunc.SetName,

	autoset = AutoCategory.RuleFunc.AutoSetName,

	trait = AutoCategory.RuleFunc.Trait,

	isequipping = AutoCategory.RuleFunc.IsEquipping,

	isinquickslot = AutoCategory.RuleFunc.IsInQuickslot,
	
	-- GamePadBuddy
	keepresearch = AutoCategory.RuleFunc.KeepForResearch,

	-- Iakoni's Gear Changer
	setindex = AutoCategory.RuleFunc.SetIndex,

	inset = AutoCategory.RuleFunc.InSet,
}

--====API====--
function AutoCategory:MatchCategoryRules( bagId, slotIndex )
	AutoCategory.LazyInit()

	self.checkingItemBagId = bagId
	self.checkingItemSlotIndex = slotIndex
	local bag_type_id
	if bagId == BAG_BACKPACK or bagId == BAG_WORN then
		bag_type_id = AC_BAG_TYPE_BACKPACK
	elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
		bag_type_id = AC_BAG_TYPE_BANK
	end
	if not bag_type_id then
		return false, "", 0
	end
	local needCheck = false
	local bag = AutoCategory.curSavedVars.bags[bag_type_id]
	for i = 1, #bag.rules do
		local rule = bag.rules[i] 

		rule.damaged = false
		if rule.rule == nil then
			return false, "", 0
		end
		local ruleCode, res = zo_loadstring( "return(" .. rule.rule ..")" )
		if not ruleCode then
			d("Error1: " .. res)
			rule.damaged = true 
		else 
			setfenv( ruleCode, AutoCategory.Environment )
			AutoCategory.AdditionCategoryName = ""
			local ok, res = pcall( ruleCode )
			if ok then
				if res == true then
					return true, rule.categoryName .. AutoCategory.AdditionCategoryName, rule.priority
				end 
			else
				d("Error2: " .. res)
				rule.damaged = true 
			end
		end
		if rule.damaged then
			return false, "", 0
		end
	end
	
	return false, "", 0
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