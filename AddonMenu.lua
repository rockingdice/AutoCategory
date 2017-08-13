local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

AutoCategory.AddonMenu = {}
AutoCategory.AddonMenu.DROPDOWN_CATEGORIES_NAME = "AutoCategory.AddonMenu.DropDownCategories"

local selectedCategoryName = AC_UNGROUPED_NAME
local categoryDropDownShowNames = {}
local categoryDropDownTooltips = {}

local emptyCategory = {
	priority = 0,
	rule = "",
	bag = 1,
	description = "",
	categoryName = "",
}
function AutoCategory.AddonMenu.GetCategorySetting(categoryName)
	for i = 1, #AutoCategory.curSavedVars.categorySettings  do
		local set = AutoCategory.curSavedVars.categorySettings[i]
		if set and set.categoryName == categoryName then
			return set
		end
	end
	return emptyCategory
end

local function CategoriesSortingFunction(left, right, accend)
	local a = AutoCategory.AddonMenu.GetCategorySetting(left)
	local b = AutoCategory.AddonMenu.GetCategorySetting(right)
	local a_less_than_b = a.priority < b.priority
	if not accend then
		a_less_than_b = not a_less_than_b
	end
	return a_less_than_b
end

local function UpdateCategoryData()
	categoryDropDownShowNames = {}
	categoryDropDownTooltips = {}
	table.sort(AutoCategory.curSavedVars.categories, function(a, b) return CategoriesSortingFunction(a, b, false) end )
	for i = 1, #AutoCategory.curSavedVars.categories do
		local name = AutoCategory.curSavedVars.categories[i]
		local cat = AutoCategory.AddonMenu.GetCategorySetting(name)
		categoryDropDownShowNames[i] = string.format("%s (%d)", name, cat.priority)
		
		if cat.description ~= "" then
			categoryDropDownTooltips[i] = cat.description 
		else 
			categoryDropDownTooltips[i] = cat.categoryName
		end
	end
end

local function UpdateDropDownCategories()
	UpdateCategoryData()
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(AutoCategory.AddonMenu.DROPDOWN_CATEGORIES_NAME, "")
	dropdownCtrl:UpdateChoices(categoryDropDownShowNames, AutoCategory.curSavedVars.categories, categoryDropDownTooltips) 	
end

function AutoCategory.AddonMenu.Init()
	AutoCategory.UpdateCurrentSavedVars()
	UpdateCategoryData()
	if #AutoCategory.curSavedVars.categories > 0 then
		selectedCategoryName = AutoCategory.curSavedVars.categories[1]
	end
	
	local panelData =  {
		type = "panel",
		name = "AutoCategory",
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
			name = "|c0066FF[Categories Setting]|r",
			width = "full",
		},
		{		
			type = "dropdown",
			name = "Categories",
			tooltip = "Categories to put items in",
			choices = categoryDropDownShowNames,
			choicesValues = AutoCategory.curSavedVars.categories,
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
				local num = #AutoCategory.curSavedVars.categories+1
				local newName = "Category_" .. num
				AutoCategory.curSavedVars.categories[num] = newName
				local newCategory = {
					bag = 1,
					categoryName = newName,
					description = "",
					priority = 0,
				}
				table.insert(AutoCategory.curSavedVars.categorySettings, newCategory)
									
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
				local num = #AutoCategory.curSavedVars.categories
				for i = 1, num do
					if selectedCategoryName == AutoCategory.curSavedVars.categories[i] then
						table.remove(AutoCategory.curSavedVars.categories, i)
						if i ~= num then
							lastIndex = i
						else
							lastIndex = i - 1
						end
						break
					end
				end
				for i = 1, num do
					if selectedCategoryName == AutoCategory.curSavedVars.categorySettings[i].categoryName then
						table.remove(AutoCategory.curSavedVars.categorySettings, i)
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
					selectedCategoryName = AutoCategory.curSavedVars.categories[lastIndex]	
				end
				
				UpdateDropDownCategories()
			end,
			width = "half",
			disabled = function() return #AutoCategory.curSavedVars.categories == 0 end,
		},
		{
			type = "editbox",
			name = "Category Name",
			getFunc = function() return AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).categoryName end,
			setFunc = function(value) 
				for i = 1, #AutoCategory.curSavedVars.categories do
					if AutoCategory.curSavedVars.categories[i] == selectedCategoryName then
						AutoCategory.curSavedVars.categories[i] = value
						break
					end
				end
				AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).categoryName = value 				
				selectedCategoryName = value
				
				UpdateDropDownCategories()
			end,
			isMultiline = false,
			disabled = function() return #AutoCategory.curSavedVars.categories == 0 end,
			width = "half",
		},
		{		
			type = "dropdown",
			name = "Bag",
			tooltip = "Backpack or Bank",
			choices = {"Backpack", "Bank"},
			choicesValues = {1, 2},
			getFunc = function()  
				return AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).bag
			end,
			setFunc = function(value) 
				AutoCategory.AddonMenu.GetCategorySetting(selectedCategoryName).bag = value
			end, 
			disabled = function() return #AutoCategory.curSavedVars.categories == 0 end,
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
			disabled = function() return #AutoCategory.curSavedVars.categories == 0 end,
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
			disabled = function() return #AutoCategory.curSavedVars.categories == 0 end,
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
			disabled = function() return #AutoCategory.curSavedVars.categories == 0 end,
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