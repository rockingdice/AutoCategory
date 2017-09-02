local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

AutoCategory.AddonMenu = {}
AutoCategory.AddonMenu.DROPDOWN_CATEGORIES_NAME = "AutoCategory.AddonMenu.DropDownCategories"

local selectedCategoryName = AC_UNGROUPED_NAME
local categoryDropDownShowNames = {}
local categoryDropDownValues = {}
local categoryDropDownTooltips = {}

local dataTags = {}
dataTags["Values"] = {}

local dataTagRules = {}

local dataBags = {}
dataBags["ShowNames"] = {[1] = "Backpack", [2] = "Bank"}
dataBags["Values"] = {1, 2}

local dataBagRules = {}

local emptyCategory = {
	priority = 0,
	rule = "",
	bag = 1,
	description = "",
	categoryName = "",
}
function AutoCategory.AddonMenu.GetCategorySetting(categoryName)
	for i = 1, #AutoCategory.curSavedVars.ruleSettings  do
		local set = AutoCategory.curSavedVars.ruleSettings[i]
		if set and set.categoryName == categoryName then
			return set, i
		end
	end
	return emptyCategory, -1
end

local function CategoriesSortingFunction(a, b)
	local result = false
	--d("a.priority: " .. a.priority .. " b.priority: " .. b.priority)
	--d("a.name: " .. a.categoryName .. " b.name: " .. b.categoryName)
	
	if a.tag == b.tag then
		--alphabetical sort, cannot have same name rules
		result = a.ruleName <b.ruleName
	else
		result = a.tag <b.tag
	end
	
	return result
end

local function UpdateCategoryData()
	dataTags["Values"] = {}
	dataTagRules = {}
	dataBagRules = {}
	table.sort(AutoCategory.curSavedVars.ruleSettings, function(a, b) return CategoriesSortingFunction(a, b) end )
	for i = 1, #AutoCategory.curSavedVars.ruleSettings do
		local rule = AutoCategory.curSavedVars.ruleSettings[i]
		local tag = rule.tag
		local ruleName = rule.ruleName
		if not dataTagRules[tag] then
			dataTagRules[tag] = {["ShowNames"] = {}, ["Values"] = {}, ["Tooltips"] = {}}
			table.insert(dataTags["Values"], tag)
		end
		local tooltip = rule.description
		if rule.description == "" then
			tooltip = rule.ruleName
		end
		table.insert(dataTagRules[tag]["ShowNames"], ruleName)
		table.insert(dataTagRules[tag]["Values"], ruleName)
		table.insert(dataTagRules[tag]["Tooltips"], tooltip)
	end

	for i = 1, #AutoCategory.curSavedVars.bagSettings do
		local bagSetting = AutoCategory.curSavedVars.bagSettings[i]
		if not dataBagRules[bagSetting.bag] then
			dataBagRules[bagSetting.bag] = {["ShowNames"] = {}, ["Values"] = {}, ["Tooltips"] = {}}
		end
		for j = 1, #bagSetting["rules"] do
			local rule = bagSetting["rules"][j]
			local ruleName = rule.ruleName
			local tooltip = rule.description
			if rule.description == "" then
				tooltip = rule.ruleName
			end
			table.insert(dataBagRules[bagSetting.bag]["ShowNames"], ruleName)
			table.insert(dataBagRules[bagSetting.bag]["Values"], ruleName)
			table.insert(dataBagRules[bagSetting.bag]["Tooltips"], tooltip)
		end
	end
end

local function UpdateDropDownCategories()
	UpdateCategoryData()
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(AutoCategory.AddonMenu.DROPDOWN_CATEGORIES_NAME, "")
	dropdownCtrl:UpdateChoices(categoryDropDownShowNames, categoryDropDownValues, categoryDropDownTooltips) 	
end


function AutoCategory.AddonMenu.Init()
	AutoCategory.UpdateCurrentSavedVars()
	UpdateCategoryData()
	if #AutoCategory.curSavedVars.ruleSettings > 0 then
		selectedCategoryName = AutoCategory.curSavedVars.ruleSettings[1].categoryName
	end
	
	local panelData =  {
		type = "panel",
		name = "Auto Category",
		displayName = "RockingDice's AutoCategory",
		author = "RockingDice",
		version = "1.00",
		slashCommand = "/ac",
		registerForRefresh = true,
		registerForDefaults = true
	}
	
	local optionsTable = {
		{
			type = "header",
			name = "General Settings",
			width = "full"
		},
		{
			type = "checkbox",
			name = "Account Wide Setting",
			tooltip = "Use these settings as account-wide",
			getFunc = function() return AutoCategory.acctSavedVariables.accountWideSetting end,
			setFunc = function(value) AutoCategory.acctSavedVariables.accountWideSetting = value
				AutoCategory.UpdateCurrentSavedVars()
				if value then
				else
				end
			end,
		},
		{
			type = "header",
			name = "|c0066FF[Rules Setting]|r",
			width = "full",
		},
		{		
			type = "dropdown",
			name = "Tags",
			tooltip = "Tags are used to filter rules.",
			choices = AutoCategory.curSavedVars.tags,
			
			getFunc = function() 
				return selectedCategoryName 
			end,
			setFunc = function(value) 			
				selectedCategoryName = value
				--refresh edit controls
			end, 
			reference = AutoCategory.AddonMenu.DROPDOWN_CATEGORIES_NAME
		},
		{		
			type = "dropdown",
			name = "Rules",
			tooltip = "Category Name (Priority)",
			choices = categoryDropDownShowNames,
			choicesValues = categoryDropDownValues,
			choicesTooltips = categoryDropDownTooltips,
			
			getFunc = function() 
				return selectedCategoryName 
			end,
			setFunc = function(value) 			
				selectedCategoryName = value
				--refresh edit controls
			end, 
			reference = AutoCategory.AddonMenu.DROPDOWN_CATEGORIES_NAME
		},
		{
			type = "button",
			name = "Add",
			tooltip = "Add",
			func = function() 
				--add a category
				local num = #AutoCategory.curSavedVars.ruleSettings+1
				local newName = "Category_" .. num
				local newCategory = {
					bags = {},
					categoryName = newName,
					description = "",
					priority = 0,
					rule = "true",
				}
				table.insert(AutoCategory.curSavedVars.ruleSettings, newCategory)
									
				selectedCategoryName = newName
				UpdateDropDownCategories()
				
			end,
			width = "half",
		},
		{
			type = "button",
			name = "Remove",
			tooltip = "Remove",
			func = function() 
				--remove a category
				local lastIndex = -1
				local num = #AutoCategory.curSavedVars.ruleSettings
				for i = 1, num do
					if selectedCategoryName == AutoCategory.curSavedVars.ruleSettings[i].categoryName then
						table.remove(AutoCategory.curSavedVars.ruleSettings, i)
						if i ~= num then
							lastIndex = i
						else
							lastIndex = i - 1
						end
						break
					end
				end
				
				
				if lastIndex == -1 then 
					--don't find
					return
			end
				
				if lastIndex < 1 then
					selectedCategoryName = ""
				else
					selectedCategoryName = AutoCategory.curSavedVars.ruleSettings[lastIndex].categoryName	
				end
				
				UpdateDropDownCategories()
			end,
			width = "half",
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
		},
		{
			type = "editbox",
			name = "Category Name",
			getFunc = function() return AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).categoryName end,
			setFunc = function(value) 
				for i = 1, #AutoCategory.curSavedVars.ruleSettings do
					if AutoCategory.curSavedVars.ruleSettings[i].categoryName == selectedCategoryName then
						AutoCategory.curSavedVars.ruleSettings[i].categoryName = value
						break
					end
				end
				AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).categoryName = value 				
				selectedCategoryName = value
				
				UpdateDropDownCategories()
			end,
			isMultiline = false,
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Backpack",
			tooltip = "Apply the category rules to backpack",
			getFunc = function()
				local bags = AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).bags
				return bags["backpack"] ~= nil
			end,
			setFunc = function(value) 
				local bags = AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).bags
				bags["backpack"] = true
			end,
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Bank",
			tooltip = "Apply the category rules to bank",
			getFunc = function()
				local bags = AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).bags
				return bags["bank"] ~= nil
			end,
			setFunc = function(value) 
				local bags = AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).bags
				bags["bank"] = true
			end,
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
			width = "half",
		},
		{
			type = "editbox",
			name = "Description",
			tooltip = "Description",
			getFunc = function() return AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).description end,
			setFunc = function(value) 
				AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).description = value 
				UpdateDropDownCategories()
			end,
			isMultiline = false,
			isExtraWide = true,
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
			width = "full",
		},
		{
			type = "editbox",
			name = "Rule",
			tooltip = "Rules will be applied when filter the category's items",
			getFunc = function() return AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).rule end,
			setFunc = function(value) AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).rule = value end,
			isMultiline = true,
			isExtraWide = true,
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
			width = "full",
		},
		{
			type = "slider",
			name = "Priority",
			tooltip = "Priority determines the position for sorting categories, higher means more ahead position.",
			min = 0,
			max = 100,
			getFunc = function() return AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).priority end,
			setFunc = function(value) 
				AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).priority = value 
				UpdateDropDownCategories()
			end,
			disabled = function() return #AutoCategory.curSavedVars.ruleSettings == 0 end,
			width = "half",
		},
		{
			type = "button",
			name = "Reset to Defaults",
			tooltip = "Reset to Defaults",
			func = function() 
				--reset
				AutoCategory.charSavedVariables = AutoCategory.defaultSettings
				AutoCategory.acctSavedVariables = AutoCategory.defaultAcctSettings
				AutoCategory.UpdateCurrentSavedVars()
				selectedCategoryName = AC_UNGROUPED_NAME
				UpdateDropDownCategories()
			end,
			width = "full",
		},
	}
	LAM:RegisterAddonPanel("AC_CATEGORY_SETTINGS", panelData)
	LAM:RegisterOptionControls("AC_CATEGORY_SETTINGS", optionsTable)
end