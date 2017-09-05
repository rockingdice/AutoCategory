--Register LAM with LibStub
local MAJOR, MINOR = "LibItemStatus", 1
local LibItemStatus, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibItemStatus then return end --the same or newer version of this lib is already loaded into memory

--== Constants ==-- 
local TCC_QUEST_GAMES_DOLLS_STATUES = 1
local TCC_QUEST_RITUAL_ODDITIES = 2
local TCC_QUEST_WRITINGS_MAPS = 3
local TCC_QUEST_COSMETICS_LINENS_ACCESSORIES = 4
local TCC_QUEST_DRINKWARE_UTENSILS_DISHES = 5
local TCC_QUEST_UNKNOWN = -1

LibItemStatus.CONST = {}
LibItemStatus.CONST.ItemFlags = { ITEM_FLAG_TRAIT_RESEARABLE = 1, ITEM_FLAG_TRAIT_DUPLICATED = 2, ITEM_FLAG_TRAIT_KNOWN = 3, ITEM_FLAG_TRAIT_RESEARCHING = 4, ITEM_FLAG_TRAIT_INTRICATE = 5, ITEM_FLAG_TRAIT_ORNATE = 6, ITEM_FLAG_TCC_QUEST = 100, ITEM_FLAG_TCC_USABLE = 101, ITEM_FLAG_TCC_USELESS = 102, ITEM_FLAG_NONE = -1}

LibItemStatus.CONST.CraftingSkillTypes = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING }
LibItemStatus.CONST.armorCraftMap = { [ARMORTYPE_LIGHT] = CRAFTING_TYPE_CLOTHIER, [ARMORTYPE_MEDIUM] = CRAFTING_TYPE_CLOTHIER, [ARMORTYPE_HEAVY] = CRAFTING_TYPE_BLACKSMITHING }
LibItemStatus.CONST.weaponCraftMap = { [WEAPONTYPE_AXE] = CRAFTING_TYPE_BLACKSMITHING, [WEAPONTYPE_HAMMER] = CRAFTING_TYPE_BLACKSMITHING, [WEAPONTYPE_SWORD] = CRAFTING_TYPE_BLACKSMITHING, [WEAPONTYPE_TWO_HANDED_AXE] = CRAFTING_TYPE_BLACKSMITHING,
          [WEAPONTYPE_TWO_HANDED_HAMMER] = CRAFTING_TYPE_BLACKSMITHING, [WEAPONTYPE_TWO_HANDED_SWORD] = CRAFTING_TYPE_BLACKSMITHING, [WEAPONTYPE_DAGGER] = CRAFTING_TYPE_BLACKSMITHING,
          [WEAPONTYPE_BOW] = CRAFTING_TYPE_WOODWORKING, [WEAPONTYPE_FIRE_STAFF] = CRAFTING_TYPE_WOODWORKING, [WEAPONTYPE_FROST_STAFF] = CRAFTING_TYPE_WOODWORKING, [WEAPONTYPE_LIGHTNING_STAFF] = CRAFTING_TYPE_WOODWORKING,
          [WEAPONTYPE_HEALING_STAFF] = CRAFTING_TYPE_WOODWORKING, [WEAPONTYPE_SHIELD] = CRAFTING_TYPE_WOODWORKING, [WEAPONTYPE_PROP] = -1
        }

LibItemStatus.CONST.armorRImap = { [ARMORTYPE_LIGHT] = { [EQUIP_TYPE_CHEST] = 1, [EQUIP_TYPE_FEET] = 2, [EQUIP_TYPE_HAND] = 3, [EQUIP_TYPE_HEAD] = 4, [EQUIP_TYPE_LEGS] = 5, [EQUIP_TYPE_SHOULDERS] = 6, [EQUIP_TYPE_WAIST] = 7 },
          [ARMORTYPE_MEDIUM] = { [EQUIP_TYPE_CHEST] = 8, [EQUIP_TYPE_FEET] = 9, [EQUIP_TYPE_HAND] = 10, [EQUIP_TYPE_HEAD] = 11, [EQUIP_TYPE_LEGS] = 12, [EQUIP_TYPE_SHOULDERS] = 13, [EQUIP_TYPE_WAIST] = 14 },
          [ARMORTYPE_HEAVY] = { [EQUIP_TYPE_CHEST] = 8, [EQUIP_TYPE_FEET] = 9, [EQUIP_TYPE_HAND] = 10, [EQUIP_TYPE_HEAD] = 11, [EQUIP_TYPE_LEGS] = 12, [EQUIP_TYPE_SHOULDERS] = 13, [EQUIP_TYPE_WAIST] = 14 }
        }
LibItemStatus.CONST.weaponRImap = { [WEAPONTYPE_AXE] = 1, [WEAPONTYPE_HAMMER] = 2, [WEAPONTYPE_SWORD] = 3, [WEAPONTYPE_TWO_HANDED_AXE] = 4, [WEAPONTYPE_TWO_HANDED_HAMMER] = 5, [WEAPONTYPE_TWO_HANDED_SWORD] = 6, [WEAPONTYPE_DAGGER] = 7,
          [WEAPONTYPE_BOW] = 1, [WEAPONTYPE_FIRE_STAFF] = 2, [WEAPONTYPE_FROST_STAFF] = 3, [WEAPONTYPE_LIGHTNING_STAFF] = 4, [WEAPONTYPE_HEALING_STAFF] = 5, [WEAPONTYPE_SHIELD] = 6, [WEAPONTYPE_PROP] = -1
        }
LibItemStatus.CONST.TCCQuestType = { TCC_QUEST_GAMES_DOLLS_STATUES, TCC_QUEST_RITUAL_ODDITIES, TCC_QUEST_WRITINGS_MAPS, TCC_QUEST_COSMETICS_LINENS_ACCESSORIES, TCC_QUEST_DRINKWARE_UTENSILS_DISHES}
LibItemStatus.CONST.TCCQuestTags = { 
	[TCC_QUEST_GAMES_DOLLS_STATUES] = {["Games"] = true, ["Dolls"] = true, ["Statues"] = true},
	[TCC_QUEST_RITUAL_ODDITIES] = {["Ritual Objects"] = true, ["Oddities"] = true},
	[TCC_QUEST_WRITINGS_MAPS] = {["Writings"] = true, ["Maps"] = true, ["Scrivener Supplies"] = true},
	[TCC_QUEST_COSMETICS_LINENS_ACCESSORIES] = {["Cosmetics"] = true, ["Linens"] = true, ["Wardrobe Accessories"] = true},
	[TCC_QUEST_DRINKWARE_UTENSILS_DISHES] = {["Drinkware"] = true, ["Utensils"] = true, ["Dishes and Cookware"] = true}
	}



--== Local functions ==--

local function IsResearchableTrait(itemType, traitType)
  return (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR)
     and (traitType == ITEM_TRAIT_TYPE_ARMOR_DIVINES
    or traitType == ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS
    or traitType == ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE
    or traitType == ITEM_TRAIT_TYPE_ARMOR_INFUSED
    or traitType == ITEM_TRAIT_TYPE_ARMOR_REINFORCED
    or traitType == ITEM_TRAIT_TYPE_ARMOR_STURDY
    or traitType == ITEM_TRAIT_TYPE_ARMOR_TRAINING
    or traitType == ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED
    or traitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED
    or traitType == ITEM_TRAIT_TYPE_WEAPON_CHARGED
    or traitType == ITEM_TRAIT_TYPE_WEAPON_DEFENDING
    or traitType == ITEM_TRAIT_TYPE_WEAPON_INFUSED
    or traitType == ITEM_TRAIT_TYPE_WEAPON_POWERED
    or traitType == ITEM_TRAIT_TYPE_WEAPON_PRECISE
    or traitType == ITEM_TRAIT_TYPE_WEAPON_SHARPENED
    or traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING
    or traitType == ITEM_TRAIT_TYPE_WEAPON_DECISIVE
    or traitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED)
end

local function IsBlacksmithWeapon(weaponType)
  return weaponType == WEAPONTYPE_AXE
      or weaponType == WEAPONTYPE_HAMMER
      or weaponType == WEAPONTYPE_SWORD
      or weaponType == WEAPONTYPE_TWO_HANDED_AXE
      or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER
      or weaponType == WEAPONTYPE_TWO_HANDED_SWORD
      or weaponType == WEAPONTYPE_DAGGER
end

local function IsWoodworkingWeapon(weaponType)
  return weaponType == WEAPONTYPE_BOW
      or weaponType == WEAPONTYPE_FIRE_STAFF
      or weaponType == WEAPONTYPE_FROST_STAFF
      or weaponType == WEAPONTYPE_LIGHTNING_STAFF
      or weaponType == WEAPONTYPE_HEALING_STAFF
      or weaponType == WEAPONTYPE_SHIELD
end
local function ItemToCraftingSkillType(itemType, armorType, weaponType)
  if itemType == ITEMTYPE_ARMOR then
    if armorType == ARMORTYPE_HEAVY then
      return CRAFTING_TYPE_BLACKSMITHING
    elseif armorType == ARMORTYPE_MEDIUM or armorType == ARMORTYPE_LIGHT then
      return CRAFTING_TYPE_CLOTHIER
    end
  elseif itemType == ITEMTYPE_WEAPON then
    if IsBlacksmithWeapon(weaponType) then
      return CRAFTING_TYPE_BLACKSMITHING
    elseif IsWoodworkingWeapon(weaponType) then
      return CRAFTING_TYPE_WOODWORKING
    end
  end
  return nil
end

local function ItemToTraitIndex(traitType)
  if traitType >= 1 and traitType <= 8 then
    return traitType
  elseif traitType == 26 then
    return 9
  elseif traitType >= 11 and traitType <= 18 then
    return traitType - 10
  elseif traitType == 25 then
    return 9
  end
  return nil
end

local function ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
  if itemType == ITEMTYPE_ARMOR then
    if armorType == ARMORTYPE_HEAVY then
      if equipType == EQUIP_TYPE_CHEST then --Cuirass
        return 8
      elseif equipType == EQUIP_TYPE_FEET then --Sabatons
        return 9
      elseif equipType == EQUIP_TYPE_HAND then --Gauntlets
        return 10
      elseif equipType == EQUIP_TYPE_HEAD then --Helm
        return 11
      elseif equipType == EQUIP_TYPE_LEGS then --Greaves
        return 12
      elseif equipType == EQUIP_TYPE_SHOULDERS then --Pauldron
        return 13
      elseif equipType == EQUIP_TYPE_WAIST then --Girdle
        return 14
      end
    elseif armorType == ARMORTYPE_MEDIUM then
      if equipType == EQUIP_TYPE_CHEST then --Jack
        return 8
      elseif equipType == EQUIP_TYPE_FEET then --Boots
        return 9
      elseif equipType == EQUIP_TYPE_HAND then --Bracers
        return 10
      elseif equipType == EQUIP_TYPE_HEAD then --Helmet
        return 11
      elseif equipType == EQUIP_TYPE_LEGS then --Guards
        return 12
      elseif equipType == EQUIP_TYPE_SHOULDERS then --Arm Cops
        return 13
      elseif equipType == EQUIP_TYPE_WAIST then --Belt
        return 14
      end
    elseif armorType == ARMORTYPE_LIGHT then
      if equipType == EQUIP_TYPE_CHEST then --Robe+Shirt = Robe & Jerkin
        return 1
      elseif equipType == EQUIP_TYPE_FEET then --Shoes
        return 2
      elseif equipType == EQUIP_TYPE_HAND then --Gloves
        return 3
      elseif equipType == EQUIP_TYPE_HEAD then --Hat
        return 4
      elseif equipType == EQUIP_TYPE_LEGS then --Breeches
        return 5
      elseif equipType == EQUIP_TYPE_SHOULDERS then --Epaulets
        return 6
      elseif equipType == EQUIP_TYPE_WAIST then --Sash
        return 7
      end
    end
  elseif itemType == ITEMTYPE_WEAPON then
    if weaponType == WEAPONTYPE_AXE then
      return 1
    elseif weaponType == WEAPONTYPE_HAMMER then
      return 2
    elseif weaponType == WEAPONTYPE_SWORD then
      return 3
    elseif weaponType == WEAPONTYPE_TWO_HANDED_AXE then
      return 4
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
      return 5
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
      return 6
    elseif weaponType == WEAPONTYPE_DAGGER then
      return 7
    elseif weaponType == WEAPONTYPE_BOW then
      return 1
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then
      return 2
    elseif weaponType == WEAPONTYPE_FROST_STAFF then
      return 3
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
      return 4
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then
      return 5
    elseif weaponType == WEAPONTYPE_SHIELD then
      return 6
    end
  end
  return 0
end

local function CacheItemTraits()
    local bagsToCheck = {
        [1] = BAG_BACKPACK,
        [2] = BAG_BANK,
		[3] = BAG_SUBSCRIBER_BANK,
    }
    for _, bagToCheck in pairs(bagsToCheck) do
      local bagSize = GetBagUseableSize(bagToCheck)
     
      for i = 0, bagSize do
          local itemLink = GetItemLink(bagToCheck, i)
          local itemType = GetItemLinkItemType(itemLink)
          local traitType, _ = GetItemLinkTraitInfo(itemLink)
          if IsResearchableTrait(itemType, traitType) then
            -- Check items for trait researching
            local armorType = GetItemLinkArmorType(itemLink)
            local weaponType = GetItemLinkWeaponType(itemLink)
            local equipType = GetItemLinkEquipType(itemLink)
			local quality = GetItemLinkQuality(itemLink)

            local craftType = ItemToCraftingSkillType(itemType, armorType, weaponType)
            local rIndex = ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
            local traitIndex = ItemToTraitIndex(traitType)
            local statusTable = LibItemStatus.ResearchTraits[craftType][rIndex][traitIndex]
			local status = statusTable[1]
            if status == -2 then
              --already researched, do nothing
            elseif status == -1 then
              --not researched, and no items recorded, record it                            
              local uniqueId = getItemId(bagToCheck, i)
			  local itemLevel = GetItemLevel(bagToCheck, i)
              LibItemStatus.ResearchTraits[craftType][rIndex][traitIndex] = {uniqueId, quality, itemLevel}
            else 
              --already have a recorded item, duplicated
            end
          end   
      end
    end
end

local function getItemId(bagId, slotIndex)
  local itemId = zo_getSafeId64Key(GetItemUniqueId(bagId, slotIndex))
  return itemId
end


--== API ==--
function LibItemStatus:RefreshResearchData()
	LibItemStatus.ResearchTraits = {}  -- craftType / itemType / traitType
	for i,craftType in pairs(LibItemStatus.CONST.CraftingSkillTypes) do
		LibItemStatus.ResearchTraits[craftType] = {}
		for researchIndex = 1, GetNumSmithingResearchLines(craftType) do
		  local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftType, researchIndex)
		  LibItemStatus.ResearchTraits[craftType][researchIndex] = {}
		  for traitIndex = 1, numTraits do
			local traitType, _, known = GetSmithingResearchLineTraitInfo(craftType, researchIndex, traitIndex)
			local durationSecs, _ = GetSmithingResearchLineTraitTimes(craftType, researchIndex, traitIndex) --can be nil
			if durationSecs then
			  LibItemStatus.ResearchTraits[craftType][researchIndex][traitIndex] = {-3}  --researching
			elseif known then
			  LibItemStatus.ResearchTraits[craftType][researchIndex][traitIndex] = {-2}  --already researched
			else
			  LibItemStatus.ResearchTraits[craftType][researchIndex][traitIndex] = {-1}
			end
		  end
		end
	end
  
    CacheItemTraits() 
	d("Refreshed All Items")
end


--Only support English now! Localization needed
function LibItemStatus:RefreshTCCQuestData()
	LibItemStatus.CurrentTCCQuest = TCC_QUEST_UNKNOWN
	local quests = QUEST_JOURNAL_MANAGER:GetQuestListData()
	for i, quest in ipairs(quests) do
		if quest.name == "The Covetous Countess" then
			local _, backgroundText, activeStepText = GetJournalQuestInfo(quest.questIndex)
			if string.find(activeStepText, "games") then
				LibItemStatus.CurrentTCCQuest = TCC_QUEST_GAMES_DOLLS_STATUES
			elseif string.find(activeStepText, "ritual") then
				LibItemStatus.CurrentTCCQuest = TCC_QUEST_RITUAL_ODDITIES
			elseif string.find(activeStepText, "writings and maps") then
				LibItemStatus.CurrentTCCQuest = TCC_QUEST_WRITINGS_MAPS
			elseif string.find(activeStepText, "cosmetics") then
				LibItemStatus.CurrentTCCQuest = TCC_QUEST_COSMETICS_LINENS_ACCESSORIES
			elseif string.find(activeStepText, "drinkware, utensils, and dishes") then
				LibItemStatus.CurrentTCCQuest = TCC_QUEST_DRINKWARE_UTENSILS_DISHES
			else
			end
		end
	end
end

function LibItemStatus:IsTCCQuestItemTag(tag)
	for k, v in pairs(LibItemStatus.CONST.TCCQuestType) do
		if LibItemStatus.CONST.TCCQuestTags[v][tag] ~= nil then
			return true
		end
	end
	return false
end


function LibItemStatus:GetItemFlagStatus(bagId, slotIndex)
	if not LibItemStatus.ResearchTraits then
		LibItemStatus:RefreshResearchData()
	end
		
  local itemLink = GetItemLink(bagId, slotIndex)
  local itemType = GetItemLinkItemType(itemLink)
  local traitType, _ = GetItemLinkTraitInfo(itemLink)
  local returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_NONE
  local name = ""
  --check if treasure type
  local itemType = GetItemLinkItemType(itemLink)
  local treasureType = itemType == ITEMTYPE_TREASURE
  if treasureType then  
	local quality = GetItemLinkQuality(itemLink)
	if quality >= 2 then 
		return LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_ORNATE
	end
	if LibItemStatus.CurrentTCCQuest == TCC_QUEST_UNKNOWN then
		return returnStatus, name
	end
    local numItemTags = GetItemLinkNumItemTags(itemLink)
    if numItemTags > 0 then 
		local useful = false
        for i = 1, numItemTags do
            local itemTagDescription, itemTagCategory = GetItemLinkItemTagInfo(itemLink, i)
			local itemTagString = zo_strformat(SI_TOOLTIP_ITEM_TAG_FORMATER, itemTagDescription)	
			if LibItemStatus.CONST.TCCQuestTags[LibItemStatus.CurrentTCCQuest][itemTagString] ~= nil then
				return LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TCC_QUEST, name
			end
			if LibItemStatus:IsTCCQuestItemTag(itemTagString) then
				useful = true
			end
		end
		if useful == false then
			return LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TCC_USELESS, name
		else
			return LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TCC_USABLE, name
		end
	end
  --Only check researchable items
  else
	  if IsResearchableTrait(itemType, traitType) then
		-- Check items for trait researching
		local armorType = GetItemLinkArmorType(itemLink)
		local weaponType = GetItemLinkWeaponType(itemLink)
		local equipType = GetItemLinkEquipType(itemLink)

		local craftType = ItemToCraftingSkillType(itemType, armorType, weaponType)
		local rIndex = ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
		local traitIndex = ItemToTraitIndex(traitType)
		local statusTable = LibItemStatus.ResearchTraits[craftType][rIndex][traitIndex]
		local status = statusTable[1]
		local curQuality = statusTable[2]
		local curLevel = statusTable[3]
		name, _, _, _ = GetSmithingResearchLineInfo(craftType, rIndex)
		if status == -3 then
		  --is researching now
		  returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_RESEARCHING
		elseif status == -2 then
		  --already researched      
		  returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_KNOWN
		elseif status == -1 then
		  --not researched, and no items recorded, record it                            
		  local uniqueId = getItemId(bagId, slotIndex)
		  local quality = GetItemLinkQuality(itemLink)
		  local itemLevel = GetItemLevel(bagId, slotIndex)
		  
		  --update cache      
		  LibItemStatus.ResearchTraits[craftType][rIndex][traitIndex] = {uniqueId, quality, itemLevel} 
		  returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_RESEARABLE
		else 
		  --already have a recorded item, check if the same
		  local uniqueId = getItemId(bagId, slotIndex)
		  local quality = GetItemLinkQuality(itemLink)
		  local itemLevel = GetItemLevel(bagId, slotIndex)
		  if status == uniqueId then
			returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_RESEARABLE
		  else
			--checck quality and level
			if quality < curQuality then
				--replace
				LibItemStatus.ResearchTraits[craftType][rIndex][traitIndex] = {uniqueId, quality, itemLevel} 
				returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_RESEARABLE
			elseif quality == curQuality then
				--check itemLevel
				if itemLevel < curLevel then
					LibItemStatus.ResearchTraits[craftType][rIndex][traitIndex] = {uniqueId, quality, itemLevel} 
					returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_RESEARABLE
				else
					returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_DUPLICATED
				end
			else
				returnStatus = LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_DUPLICATED
			end
		  end
		end
	  else
		if traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
		  return LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_INTRICATE, name
		elseif traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE then
		  return LibItemStatus.CONST.ItemFlags.ITEM_FLAG_TRAIT_ORNATE, name
		end
	  end   
	end
  return returnStatus, name
end
--[[
local function OnRefreshInventory()
	d("refresh all")
	LibItemStatus:RefreshResearchData()
end

local function OnRefreshInventorySingle()
	d("refresh single")
	LibItemStatus:RefreshResearchData()
end

EVENT_MANAGER:RegisterForEvent("LibItemStatus", EVENT_INVENTORY_FULL_UPDATE, OnRefreshInventory)
EVENT_MANAGER:RegisterForEvent("LibItemStatus", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnRefreshInventorySingle)

]]--