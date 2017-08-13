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

--define name of addon
AutoCategory.name = "AutoCategory";
--define addon version number
AutoCategory.version = 1.00;
AC_UNGROUPED_NAME = "Default Category"


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
AutoCategory.defaultSettings = {
	categories = {
		[1] = AC_UNGROUPED_NAME,
	},
	categorySettings = {
		[1] = {
			priority = 0,
			rule = "true",
			bag = 1,
			description = "",
			categoryName = AC_UNGROUPED_NAME,
		}
	},
}


AutoCategory.defaultAcctSettings = {
	categories = {
		[1] = AC_UNGROUPED_NAME,
	},
	categorySettings = {
		[1] = {
			priority = 0,
			rule = "true",
			bag = 1,
			description = "",
			categoryName = AC_UNGROUPED_NAME,
		}
	},
	--account specific settings
	accountWideSetting = false
}

function AutoCategory.Initialize(event, addon)
    -- filter for just BUI addon event as EVENT_ADD_ON_LOADED is addon-blind
	if addon ~= AutoCategory.name then return end

	-- load our saved variables
	AutoCategory.charSavedVariables = ZO_SavedVars:New('AutoCategorySavedVars', 1.1, nil, AutoCategory.defaultSettings)
	AutoCategory.acctSavedVariables = ZO_SavedVars:NewAccountWide('AutoCategorySavedVars', 1.1, nil, AutoCategory.defaultAcctSettings)

	AutoCategory.AddonMenu.Init()
end

function AutoCategory.RuleFunc.SpecializedItemType( ... )
	local fn = "type"
	local ac = select( '#', ... )
	if ac == 0 then
		error( "error: type(): require arguments." )
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error("error: type():  argument is nil." )
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
			error( "error: type(): argument is error." )
		end
		
	end
	
	return false
	
end

function AutoCategory.RuleFunc.ItemType( ... )
	local fn = "type"
	local ac = select( '#', ... )
	if ac == 0 then
		error( "error: type(): require arguments." )
	end
	
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		
		if not arg then
			error("error: type():  argument is nil." )
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
			error( "error: type(): argument is error." )
		end
		
	end
	
	return false
	
end


AutoCategory.Environment = {
	-- rule functions
	type = AutoCategory.RuleFunc.ItemType,
	sptype = AutoCategory.RuleFunc.SpecializedItemType,
}



function AutoCategory:MatchCategoryRules( bagId, slotIndex )
	self.checkingItemBagId = bagId
	self.checkingItemSlotIndex = slotIndex
	local needCheck = false
	for i = 1, #AutoCategory.curSavedVars.categorySettings do
		local cat = AutoCategory.curSavedVars.categorySettings[i]
		--PrintTable(AutoCategory.curSavedVars, 3)
		if cat.bag == 1 and (bagId == BAG_BACKPACK or bagId == BAG_WORN) then
			--check backpack
			needCheck = true
		elseif cat.bag == 2 and (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) then
			--check bank
			needCheck = true
		else
			needCheck = false
		end
		if needCheck then
			cat.damaged = false
			if cat.rule == nil then
				return false, "", 0
			end
			local ruleCode, res = zo_loadstring( "return(" .. cat.rule ..")" )
			if not ruleCode then
				d("Error1: " .. res)
				cat.damaged = true 
			else 
				setfenv( ruleCode, AutoCategory.Environment )
				local ok, res = pcall( ruleCode )
				if ok then
					if res == true then
						return true, cat.categoryName, cat.priority
					end
					
				else
					d("Error2: " .. res)
					cat.damaged = true 
				end
			end
		end
		if cat.damaged then
			return false, "", 0
		end
	end
	
	return false, "", 0
end
-- register our event handler function to be called to do initialization
EVENT_MANAGER:RegisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED, function(...) AutoCategory.Initialize(...) end)