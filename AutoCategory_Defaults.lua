AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3

AutoCategory = {}
AutoCategory.defaultSettings = {
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
		[1] = 
		{
			["rule"] = "type(\"armor\") and not equiptype(\"neck\") and not equiptype(\"ring\")",
			["tag"] = "Gears",
			["name"] = "Armor",
			["damaged"] = false,
			["description"] = "",
		},
		[2] = 
		{
			["rule"] = "boundtype(\"on_equip\") and not isbound() and not keepresearch()",
			["tag"] = "Gears",
			["name"] = "BoE",
			["damaged"] = false,
			["description"] = "BoE gears for selling",
		},
		[3] = 
		{
			["rule"] = "isboptradeable()",
			["tag"] = "Gears",
			["name"] = "BoP Tradeable",
			["damaged"] = false,
			["description"] = "Gears are tradeable within a limited time",
		},
		[4] = 
		{
			["rule"] = "traitstring(\"intricate\")",
			["tag"] = "Gears",
			["name"] = "Deconstruct",
			["damaged"] = false,
			["description"] = "",
		},
		[5] = 
		{
			["rule"] = "isequipping()",
			["tag"] = "Gears",
			["name"] = "Equipping",
			["damaged"] = false,
			["description"] = "Currently equipping gears (Gamepad Only)",
		},
		[6] = 
		{
			["rule"] = "cp() < 160 and type(\"armor\", \"weapon\")",
			["tag"] = "Gears",
			["name"] = "Low Level",
			["damaged"] = false,
			["description"] = "Gears below cp 160",
		},
		[7] = 
		{
			["rule"] = "equiptype(\"neck\")",
			["tag"] = "Gears",
			["name"] = "Necklace",
			["damaged"] = false,
			["description"] = "",
		},
		[8] = 
		{
			["rule"] = "keepresearch()",
			["tag"] = "Gears",
			["name"] = "Researchable",
			["damaged"] = false,
			["description"] = "Gears that keep for research purpose, only keep the low quality, low level one.",
		},
		[9] = 
		{
			["rule"] = "equiptype(\"ring\")",
			["tag"] = "Gears",
			["name"] = "Ring",
			["damaged"] = false,
			["description"] = "",
		},
		[10] = 
		{
			["rule"] = "autoset()",
			["tag"] = "Gears",
			["name"] = "Set",
			["damaged"] = false,
			["description"] = "Auto categorize set gears",
		},
		[11] = 
		{
			["rule"] = "type(\"weapon\")",
			["tag"] = "Gears",
			["name"] = "Weapon",
			["damaged"] = false,
			["description"] = "",
		},
		[12] = 
		{
			["rule"] = "type(\"food\", \"drink\", \"potion\")",
			["tag"] = "General Items",
			["name"] = "Consumables",
			["damaged"] = false,
			["description"] = "Food, Drink, Potion",
		},
		[13] = 
		{
			["rule"] = "type(\"container\")",
			["tag"] = "General Items",
			["name"] = "Container",
			["damaged"] = false,
			["description"] = "",
		},
		[14] = 
		{
			["rule"] = "filtertype(\"furnishing\")",
			["tag"] = "General Items",
			["name"] = "Furnishing",
			["damaged"] = false,
			["description"] = "",
		},
		[15] = 
		{
			["rule"] = "type(\"soul_gem\", \"glyph_armor\", \"glyph_jewelry\", \"glyph_weapon\")",
			["tag"] = "General Items",
			["name"] = "Glyphs & Gems",
			["damaged"] = false,
			["description"] = "",
		},
		[16] = 
		{
			["rule"] = "isnew()",
			["tag"] = "General Items",
			["name"] = "New",
			["damaged"] = false,
			["description"] = "New Items receive recently.",
		},
		[17] = 
		{
			["rule"] = "type(\"poison\")",
			["tag"] = "General Items",
			["name"] = "Poison",
			["damaged"] = false,
			["description"] = "",
		},
		[18] = 
		{
			["rule"] = "isinquickslot()",
			["tag"] = "General Items",
			["name"] = "Quickslots",
			["damaged"] = false,
			["description"] = "equipped in quickslots",
		},
		[19] = 
		{
			["rule"] = "type(\"recipe\",\"racial_style_motif\") or sptype(\"trophy_recipe_fragment\")",
			["tag"] = "General Items",
			["name"] = "Recipes & Motifs",
			["damaged"] = false,
			["description"] = "All recipes, motifs and recipe fragments.",
		},
		[20] = 
		{
			["rule"] = "traitstring(\"ornate\") or sptype(\"collectible_monster_trophy\") or type(\"trash\")",
			["tag"] = "General Items",
			["name"] = "Selling",
			["damaged"] = false,
			["description"] = "",
		},
		[21] = 
		{
			["rule"] = "isstolen()",
			["tag"] = "General Items",
			["name"] = "Stolen",
			["damaged"] = false,
			["description"] = "",
		},
		[22] = 
		{
			["rule"] = "sptype(\"trophy_survey_report\", \"trophy_treasure_map\")",
			["tag"] = "General Items",
			["name"] = "Treasure Maps",
			["damaged"] = false,
			["description"] = "Treasure maps and survey reports",
		},
		[23] = 
		{
			["rule"] = "setindex(1)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#1",
			["damaged"] = false,
			["description"] = "#1 Set from Iakoni's Gear Changer",
		},
		[24] = 
		{
			["rule"] = "setindex(2)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#2",
			["damaged"] = false,
			["description"] = "#2 Set from Iakoni's Gear Changer",
		},
		[25] = 
		{
			["rule"] = "setindex(3)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#3",
			["damaged"] = false,
			["description"] = "#3 Set from Iakoni's Gear Changer",
		},
		[26] = 
		{
			["rule"] = "setindex(4)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#4",
			["damaged"] = false,
			["description"] = "#4 Set from Iakoni's Gear Changer",
		},
		[27] = 
		{
			["rule"] = "setindex(5)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#5",
			["damaged"] = false,
			["description"] = "#5 Set from Iakoni's Gear Changer",
		},
		[28] = 
		{
			["rule"] = "setindex(6)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#6",
			["damaged"] = false,
			["description"] = "#6 Set from Iakoni's Gear Changer",
		},
		[29] = 
		{
			["rule"] = "setindex(7)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#7",
			["damaged"] = false,
			["description"] = "#7 Set from Iakoni's Gear Changer",
		},
		[30] = 
		{
			["rule"] = "setindex(8)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#8",
			["damaged"] = false,
			["description"] = "#8 Set from Iakoni's Gear Changer",
		},
		[31] = 
		{
			["rule"] = "setindex(9)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#9",
			["damaged"] = false,
			["description"] = "#9 Set from Iakoni's Gear Changer",
		},
		[32] = 
		{
			["rule"] = "setindex(10)",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#10",
			["damaged"] = false,
			["description"] = "#10 Set from Iakoni's Gear Changer",
		},
		[33] = 
		{
			["rule"] = "filtertype(\"alchemy\")",
			["tag"] = "Materials",
			["name"] = "Alchemy",
			["damaged"] = false,
			["description"] = "",
		},
		[34] = 
		{
			["rule"] = "filtertype(\"blacksmithing\")",
			["tag"] = "Materials",
			["name"] = "Blacksmithing",
			["damaged"] = false,
			["description"] = "",
		},
		[35] = 
		{
			["rule"] = "filtertype(\"clothing\")",
			["tag"] = "Materials",
			["name"] = "Clothing",
			["damaged"] = false,
			["description"] = "",
		},
		[36] = 
		{
			["rule"] = "filtertype(\"enchanting\")",
			["tag"] = "Materials",
			["name"] = "Enchanting",
			["damaged"] = false,
			["description"] = "",
		},
		[37] = 
		{
			["rule"] = "filtertype(\"provisioning\")",
			["tag"] = "Materials",
			["name"] = "Provisioning",
			["damaged"] = false,
			["description"] = "",
		},
		[38] = 
		{
			["rule"] = "filtertype(\"trait_items\", \"style_materials\")",
			["tag"] = "Materials",
			["name"] = "Trait/Style Gems",
			["damaged"] = false,
			["description"] = "",
		},
		[39] = 
		{
			["rule"] = "filtertype(\"woodworking\")",
			["tag"] = "Materials",
			["name"] = "Woodworking",
			["damaged"] = false,
			["description"] = "",
		},
	},
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = "BoP Tradeable",
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = "New",
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = "Container",
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = "Selling",
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = "Low Level",
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = "Deconstruct",
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = "BoE",
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = "Researchable",
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = "Equipping",
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = "Set",
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = "Weapon",
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = "Poison",
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = "Armor",
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = "Necklace",
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = "Ring",
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = "Quickslots",
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = "Consumables",
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = "Glyphs & Gems",
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = "Recipes & Motifs",
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = "Treasure Maps",
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = "Furnishing",
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = "Stolen",
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = "Alchemy",
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = "Blacksmithing",
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = "Clothing",
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = "Enchanting",
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = "Provisioning",
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = "Trait/Style Gems",
				},
				[29] = 
				{
					["priority"] = 10,
					["name"] = "Woodworking",
				},
			},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = "BoP Tradeable",
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = "New",
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = "Container",
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = "Selling",
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = "Low Level",
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = "Deconstruct",
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = "BoE",
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = "Researchable",
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = "Equipping",
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = "Set",
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = "Weapon",
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = "Poison",
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = "Armor",
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = "Necklace",
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = "Ring",
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = "Quickslots",
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = "Consumables",
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = "Glyphs & Gems",
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = "Recipes & Motifs",
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = "Treasure Maps",
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = "Furnishing",
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = "Stolen",
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = "Alchemy",
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = "Blacksmithing",
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = "Clothing",
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = "Enchanting",
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = "Provisioning",
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = "Trait/Style Gems",
				},
				[29] = 
				{
					["priority"] = 10,
					["name"] = "Woodworking",
				},
			},
		},
	}, 
	--account specific settings
	accountWideSetting = true,
	appearance = {
		["CATEGORY_FONT_NAME"] = "Univers 67",
		["CATEGORY_FONT_STYLE"] = "soft-shadow-thin",
		["CATEGORY_FONT_COLOR"] = 
		{
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
		},
		["CATEGORY_FONT_SIZE"] = 18,
		["CATEGORY_FONT_ALIGNMENT"] = 1,
	},
}