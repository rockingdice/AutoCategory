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
			["description"] = "BoE gears for selling",
			["tag"] = "Gears",
			["name"] = "BoE",
			["rule"] = "boundtype(\"on_equip\") and not isbound()",
			["damaged"] = false,
		},
		[2] = 
		{
			["description"] = "Currently equipping gears (Gamepad Only)",
			["tag"] = "Gears",
			["name"] = "Equipping",
			["rule"] = "isequipping()",
			["damaged"] = false,
		},
		[3] = 
		{
			["description"] = "",
			["tag"] = "Gears",
			["name"] = "Intricate",
			["rule"] = "trait(\"intricate\")",
			["damaged"] = false,
		},
		[4] = 
		{
			["description"] = "Gears below cp 160",
			["tag"] = "Gears",
			["name"] = "Low Level",
			["rule"] = "cp() < 160 and type(\"armor\", \"weapon\")",
			["damaged"] = false,
		},
		[5] = 
		{
			["description"] = "Gears that keep for research purpose, only keep the low quality, low level one.",
			["tag"] = "Gears",
			["name"] = "Researchable",
			["rule"] = "keepresearch()",
			["damaged"] = false,
		},
		[6] = 
		{
			["description"] = "Auto categorize set gears",
			["tag"] = "Gears",
			["name"] = "Set",
			["rule"] = "autoset()",
			["damaged"] = false,
		},
		[7] = 
		{
			["description"] = "Food, Drink, Potion",
			["tag"] = "General Items",
			["name"] = "Consumables",
			["rule"] = "type(\"food\", \"drink\", \"potion\")",
			["damaged"] = false,
		},
		[8] = 
		{
			["description"] = "",
			["tag"] = "General Items",
			["name"] = "Container",
			["rule"] = "type(\"container\")",
			["damaged"] = false,
		},
		[9] = 
		{
			["description"] = "",
			["tag"] = "General Items",
			["name"] = "Furnishing",
			["rule"] = "filtertype(\"furnishing\")",
			["damaged"] = false,
		},
		[10] = 
		{
			["description"] = "",
			["tag"] = "General Items",
			["name"] = "Glyphs & Gems",
			["rule"] = "type(\"soul_gem\", \"glyph_armor\", \"glyph_jewelry\", \"glyph_weapon\")",
			["damaged"] = false,
		},
		[11] = 
		{
			["description"] = "New Items receive recently.",
			["tag"] = "General Items",
			["name"] = "New",
			["rule"] = "isnew()",
			["damaged"] = false,
		},
		[12] = 
		{
			["description"] = "equipped in quickslots",
			["tag"] = "General Items",
			["name"] = "Quickslots",
			["rule"] = "isinquickslot()",
			["damaged"] = false,
		},
		[13] = 
		{
			["description"] = "All recipes, motifs and recipe fragments.",
			["tag"] = "General Items",
			["name"] = "Recipes & Motifs",
			["rule"] = "type(\"recipe\",\"racial_style_motif\") or sptype(\"trophy_recipe_fragment\")",
			["damaged"] = false,
		},
		[14] = 
		{
			["description"] = "Treasure maps and survey reports",
			["tag"] = "General Items",
			["name"] = "Treasure Maps",
			["rule"] = "sptype(\"trophy_survey_report\", \"trophy_treasure_map\")",
			["damaged"] = false,
		},
		[15] = 
		{
			["description"] = "#1 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#1",
			["rule"] = "setindex(1)",
			["damaged"] = false,
		},
		[16] = 
		{
			["description"] = "#2 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#2",
			["rule"] = "setindex(2)",
			["damaged"] = false,
		},
		[17] = 
		{
			["description"] = "#3 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#3",
			["rule"] = "setindex(3)",
			["damaged"] = false,
		},
		[18] = 
		{
			["description"] = "#4 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#4",
			["rule"] = "setindex(4)",
			["damaged"] = false,
		},
		[19] = 
		{
			["description"] = "#5 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#5",
			["rule"] = "setindex(5)",
			["damaged"] = false,
		},
		[20] = 
		{
			["description"] = "#6 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#6",
			["rule"] = "setindex(6)",
			["damaged"] = false,
		},
		[21] = 
		{
			["description"] = "#7 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#7",
			["rule"] = "setindex(7)",
			["damaged"] = false,
		},
		[22] = 
		{
			["description"] = "#8 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#8",
			["rule"] = "setindex(8)",
			["damaged"] = false,
		},
		[23] = 
		{
			["description"] = "#9 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#9",
			["rule"] = "setindex(9)",
			["damaged"] = false,
		},
		[24] = 
		{
			["description"] = "#10 Set from Iakoni's Gear Changer",
			["tag"] = "Iakoni's Gear Changer",
			["name"] = "Set#10",
			["rule"] = "setindex(10)",
			["damaged"] = false,
		}, 
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
	accountWideSetting = true
}