local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
  
--cache data for dropdown: 
local cacheTags = {}
cacheTags = {}
 
local cacheBags = {}
cacheBags.showNames = {[AC_BAG_TYPE_BACKPACK] = "Backpack", [AC_BAG_TYPE_BANK] = "Bank"}
cacheBags.values = {AC_BAG_TYPE_BACKPACK, AC_BAG_TYPE_BANK}
cacheBags.tooltips = {"Backpack", "Bank"}

local cacheRulesByTag = {}
local cacheRulesByBag = {}

--cache for quick index
local cacheRulesByName = {}
local cacheBagEntriesByName = {}

--dropdown data for index
local dropdownData = {
	["AC_DROPDOWN_EDITBAG_BAG"] = {indexValue = AC_BAG_TYPE_BACKPACK, choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITBAG_RULE"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_ADDCATEGORY_TAG"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_ADDCATEGORY_RULE"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITRULE_TAG"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITRULE_RULE"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
}

--warning message
local warningDuplicatedName = {
	warningMessage = nil,
}

local function UpdateDuplicateNameWarning()
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME", "")
	if control then
		control:UpdateWarning()			
	end
end

local function RefreshPanel()
	UpdateDuplicateNameWarning()

	--restore warning
	warningDuplicatedName.warningMessage = nil	
end 

local function RuleDataSortingFunction(a, b)
	local result = false
	if a.tag ~= b.tag then
		result = a.tag <b.tag
	else
		--alphabetical sort, cannot have same name rules
		result = a.name <b.name
	end
	
	return result
end

local function BagDataSortingFunction(a, b)
	local result = false
	if a.priority ~= b.priority then
		result = a.priority > b.priority
	else
		result = a.name < b.name
	end
	return result
end 

local function SelectDropDownItem(typeString, item)
	dropdownData[typeString].indexValue = item
end

local function GetDropDownSelection(typeString)
	return dropdownData[typeString].indexValue
end

local function ToggleSubmenu(typeString, open)
	local control = WINDOW_MANAGER:GetControlByName(typeString, "")
	if control then
		control.open = open
		if control.open then
			control.animation:PlayFromStart()
		else
			control.animation:PlayFromEnd()
		end	
	end
end

local function RefreshCache() 
	cacheRulesByName = {}
	cacheBagEntriesByName = {}
	cacheTags = {}
	cacheRulesByTag = {}
	cacheRulesByBag = {}

	table.sort(AutoCategory.curSavedVars.rules, function(a, b) return RuleDataSortingFunction(a, b) end )
	for i = 1, #AutoCategory.curSavedVars.rules do
		local rule = AutoCategory.curSavedVars.rules[i]
		local tag = rule.tag
		if tag == "" then
			tag = AC_EMPTY_TAG_NAME
		end
		--update cache for tag grouping 
		local name = rule.name
		cacheRulesByName[name] = rule

		--update data for showing in the dropdown menu
		if not cacheRulesByTag[tag] then
			--d("add tag rule: ".. tag)
			cacheRulesByTag[tag] = {showNames = {}, values = {}, tooltips = {}}
			table.insert(cacheTags, tag)
		end
		local tooltip = rule.description
		if rule.description == "" then
			tooltip = rule.name
		end
		--d("added rule: ".. name)
		table.insert(cacheRulesByTag[tag].showNames, name)
		table.insert(cacheRulesByTag[tag].values, name)
		table.insert(cacheRulesByTag[tag].tooltips, tooltip)
	end

	for i = 1, #AutoCategory.curSavedVars.bags do
		local bag = AutoCategory.curSavedVars.bags[i]
		table.sort(bag.rules, function(a, b) return BagDataSortingFunction(a, b) end )
		--update data for showing in the dropdown menu
		local bagId = i
		if not cacheRulesByBag[bagId] then
			cacheRulesByBag[bagId] = {showNames = {}, values = {}, tooltips = {}}
		end
		if not cacheBagEntriesByName[bagId] then
			cacheBagEntriesByName[bagId] = {}
		end
		for j = 1, #bag.rules do
			local data = bag.rules[j]
			local ruleName = data.name
			cacheBagEntriesByName[bagId][ruleName] = data
			
			local priority = data.priority
			local rule = cacheRulesByName[ruleName]
			local missing = false
			if not rule then
				missing = true
			end
			if not missing then
				local tooltip = rule.description
				if tooltip == "" then
					tooltip = rule.name
				end 
				table.insert(cacheRulesByBag[bagId].showNames, string.format("%s (%d)", ruleName, priority))
				table.insert(cacheRulesByBag[bagId].values, ruleName)
				table.insert(cacheRulesByBag[bagId].tooltips, tooltip)
			else
				table.insert(cacheRulesByBag[bagId].showNames, string.format("|cFF4444(!)|r %s (%d)", ruleName, priority))				
				table.insert(cacheRulesByBag[bagId].values, ruleName)
				table.insert(cacheRulesByBag[bagId].tooltips, "This rule is missing, please make sure the rule with this name exist.")
			end
		end
	end
	
end 


local function RefreshDropdownData()
	local dataCurrentRules_AddCategory = {}
	dataCurrentRules_AddCategory.showNames = {}
	dataCurrentRules_AddCategory.values = {}
	dataCurrentRules_AddCategory.tooltips = {}
	local dataCurrentRules_EditRule = {}
	dataCurrentRules_EditRule.showNames = {}
	dataCurrentRules_EditRule.values = {}
	dataCurrentRules_EditRule.tooltips = {}
	local dataCurrentRules_EditBag = {}
	dataCurrentRules_EditBag.showNames = {}
	dataCurrentRules_EditBag.values = {}
	dataCurrentRules_EditBag.tooltips = {}
	 
	--update tag & bag selection first
	if GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG") == "" and #cacheTags > 0 then
		SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", cacheTags[1])
	end
	if GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG") == "" and #cacheTags > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", cacheTags[1])
	end
	if GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG") == "" and #cacheBags.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITBAG_BAG", cacheBags.values[1])
	end

	--refresh current dropdown rules
	if cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")] then 
		dataCurrentRules_EditRule.showNames = cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")].showNames
		dataCurrentRules_EditRule.values = cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")].values
		dataCurrentRules_EditRule.tooltips = cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")].tooltips
	end

	if cacheRulesByBag[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")] then 
		dataCurrentRules_EditBag.showNames = cacheRulesByBag[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")].showNames
		dataCurrentRules_EditBag.values =cacheRulesByBag[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")].values
		dataCurrentRules_EditBag.tooltips = cacheRulesByBag[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")].tooltips
	end

	if cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")] then 
		--remove the rules alreadly in bag
		for i = 1, #cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")].values do
			local value = cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")].values[i]
			if cacheBagEntriesByName[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")][value] == nil then
				--add the rule if not in bag
				table.insert(dataCurrentRules_AddCategory.showNames, cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")].showNames[i])
				table.insert(dataCurrentRules_AddCategory.values, cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")].values[i])
				table.insert(dataCurrentRules_AddCategory.tooltips, cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")].tooltips[i])
			end
		end
	end
	
	--update rules selection base on current dropdown data
	if GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") == "" and #dataCurrentRules_EditBag.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", dataCurrentRules_EditBag.values[1])
	end
	if GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE") == "" and #dataCurrentRules_EditRule.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", dataCurrentRules_EditRule.values[1])
	end
	if GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") == "" and #dataCurrentRules_AddCategory.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", dataCurrentRules_AddCategory.values[1])
	end
	
	--update data indices
	dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choices = cacheBags.showNames
	dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesValues = cacheBags.values
	dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesTooltips = cacheBags.tooltips
	 
	dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choices = dataCurrentRules_EditBag.showNames
	dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues = dataCurrentRules_EditBag.values
	dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesTooltips = dataCurrentRules_EditBag.tooltips
	
	dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choices = cacheTags
	dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesValues = cacheTags
	dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesTooltips = cacheTags
	
	dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choices = dataCurrentRules_AddCategory.showNames
	dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues = dataCurrentRules_AddCategory.values
	dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesTooltips = dataCurrentRules_AddCategory.tooltips
	
	dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choices = cacheTags
	dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues = cacheTags
	dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesTooltips = cacheTags
	
	dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choices = dataCurrentRules_EditRule.showNames
	dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues = dataCurrentRules_EditRule.values
	dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesTooltips = dataCurrentRules_EditRule.tooltips
	
end
 
local function UpdateDropDownMenu(name)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(name, "")
	local data = dropdownData[name]

	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, data.choicesTooltips) 
end

local function RemoveDropDownItem(typeString, dataArray, removeItem, emptyCallback)
	local removeIndex = -1
	local num = #dataArray
	for i = 1, num do
		if removeItem == dataArray[i] then
			removeIndex = i
			table.remove(dataArray, removeIndex)
			break
		end
	end
	
	assert(removeIndex ~= -1, "Cannot remove item " .. removeItem .. " in dropdown: " .. typeString)
	
	if num == 1 then
		--select none
		SelectDropDownItem(typeString, "")
		if emptyCallback then
			emptyCallback(typeString)
		end
	elseif removeIndex == num then
		--no next one, select previous one
		SelectDropDownItem(typeString, dataArray[removeIndex-1])
	else
		--select next one
		SelectDropDownItem(typeString, dataArray[removeIndex])
	end
	
end


local function IsRuleNameUsed(name)
	return cacheRulesByName[name] ~= nil
end

local function GetUsableRuleName(name)
	local testName = name
	local index = 1
	while cacheRulesByName[testName] ~= nil do
		testName = name .. index
		index = index + 1
	end
	return testName
end

local function CreateNewRule(name, tag)
	local rule = {
		name = name,
		description = "",
		rule = "true",
		tag = tag,
	}
	return rule
end

local function CreateNewBagRuleEntry(name)
	local entry = {
		name = name,
		priority = 0,
	}
	return entry	
end

local function RemoveRuleFromBag(ruleName, bagId)
	for i = 1, #AutoCategory.curSavedVars.bags[bagId].rules do
		local rule = AutoCategory.curSavedVars.bags[bagId].rules[i]
		if rule.name == ruleName then
			table.remove(AutoCategory.curSavedVars.bags[bagId].rules, i)
			return i
		end
	end
	return -1
end

function AutoCategory.GetRuleByName(name)
	if cacheRulesByName then
		return cacheRulesByName[name]
	end
end

function AutoCategory.AddonMenuInit()
	AutoCategory.UpdateCurrentSavedVars() 
	RefreshCache()  
	RefreshDropdownData() 
 
	local panelData =  {
		type = "panel",
		name = AutoCategory.settingName,
		displayName = AutoCategory.settingDisplayName,
		author = AutoCategory.author,
		version = AutoCategory.version,
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function() 
			AutoCategory.ResetToDefaults()
			RefreshCache() 
			RefreshDropdownData()
		end,
	}
	
	local optionsTable = {
		{
			type = "submenu",
		    name = "|c0066FF[General Setting]|r", -- or string id or function returning a string
		    controls = {
				{
					type = "checkbox",
					name = "Account Wide Setting",
					tooltip = "Use these settings as account-wide",
					getFunc = function() return AutoCategory.acctSavedVariables.accountWideSetting end,
					setFunc = function(value) AutoCategory.acctSavedVariables.accountWideSetting = value
						AutoCategory.UpdateCurrentSavedVars()
					end,
				},
			},
		},
		{
			type = "submenu",
		    name = "|c0066FF[Bag Setting]|r", -- or string id or function returning a string
			reference = "AC_SUBMENU_BAG_SETTING",
		    controls = {
				{		
					type = "dropdown",
					name = "Bag",
					tooltip = "Select a bag to modify rules that apply on",
					choices = dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choices,
					choicesValues = dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesTooltips,
					
					getFunc = function()  
						return GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
					end,
					setFunc = function(value) 	
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_BAG", value)
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", "")
						--reset add rule's selection, since all data will be changed.
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						 
						RefreshDropdownData() 
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end, 
					width = "half",
					reference = "AC_DROPDOWN_EDITBAG_BAG"
				},
				{		
					type = "dropdown",
					name = "Categories",
					choices = dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choices,
					choicesValues = dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesTooltips,
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") 
					end,
					setFunc = function(value) 			 
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", value )
					end, 
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_EDITBAG_RULE"
				},
				{
					type = "slider",
					name = "Category Priority",
					tooltip = "Category Priority determines the order of the category in the bag, higher means more ahead position.",
					min = 0,
					max = 100,
					getFunc = function() 
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local rule = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						if cacheBagEntriesByName[bag][rule] then
							return cacheBagEntriesByName[bag][rule].priority
						end
						return 0
					end, 
					setFunc = function(value) 
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local rule = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						if cacheBagEntriesByName[bag][rule] then
							cacheBagEntriesByName[bag][rule].priority = value 
							RefreshCache()
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						end
					end,
					disabled = function() 
						if GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") == "" then
							return true
						end 
						if #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 then
							return true
						end
						return false
					end,
					width = "full",
				},
				{
					type = "button",
					name = "Edit",
					tooltip = "Edit selected category in the category setting.",
					func = function()
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						local rule = cacheRulesByName[ruleName]
						if rule then
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", rule.tag)
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", rule.name) 
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
							ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
							ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
						end
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 end,
					width = "full",
				},
				{
					type = "button",
					name = "Remove",
					tooltip = "Remove selected rule from bag",
					func = function()  
						local bagId = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						for i = 1, #AutoCategory.curSavedVars.bags[bagId].rules do
							local bagEntry = AutoCategory.curSavedVars.bags[bagId].rules[i]
							if bagEntry.name == ruleName then
								table.remove(AutoCategory.curSavedVars.bags[bagId].rules, i)
								break
							end
						end
						RemoveDropDownItem("AC_DROPDOWN_EDITBAG_RULE", dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues, ruleName)
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 end,
					width = "full",
				},
				{
					type = "header",
					name = "Add Category",
					width = "full",
				},
				{		
					type = "dropdown",
					name = "Tag",
					choices = dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choices, 
					choicesValues = dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesTooltips,
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", value)
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						RefreshDropdownData() 
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end, 
					width = "half",
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesValues == 0 end,
					reference = "AC_DROPDOWN_ADDCATEGORY_TAG"
				},
				{		
					type = "dropdown",
					name = "Category",
					choices = dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choices, 
					choicesValues = dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesTooltips,
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", value)
					end, 
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_ADDCATEGORY_RULE"
				},
				{
					type = "button",
					name = "Edit",
					tooltip = "Edit selected category in the category setting.",
					func = function()
						local ruleName = GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE")
						local rule = cacheRulesByName[ruleName]
						if rule then
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", rule.tag)
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", rule.name) 
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
							ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
							ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
						end
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues == 0 end,
					width = "full",
				},
				{
					type = "button",
					name = "Add",
					tooltip = "Add selected rule to the bag",
					func = function()  
						local bagId = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local ruleName = GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE")
						assert(cacheBagEntriesByName[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")][ruleName] == nil, "Bag(" .. bagId .. ") already has the rule: ".. ruleName)
					 
						local entry = CreateNewBagRuleEntry(ruleName)
						table.insert(AutoCategory.curSavedVars.bags[bagId].rules, entry) 
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", ruleName) 
						RemoveDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues, ruleName)
						 
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues == 0 end,
					width = "full",
				},
				
		    },
		},
		{
			type = "submenu",
		    name = "|c0066FF[Category Setting]|r",
			reference = "AC_SUBMENU_CATEGORY_SETTING",
		    controls = {
				{		
					type = "dropdown",
					name = "Tag",
					tooltip = "Tag the rule and make them organized.",
					choices = dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choices, 
					choicesValues = dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues, 
					choicesTooltips = dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesTooltips, 
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", value)
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", "")
						RefreshDropdownData() 
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
					end, 
					width = "half",
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					reference = "AC_DROPDOWN_EDITRULE_TAG"
				},
				{		
					type = "dropdown",
					name = "Category", 
					choices = dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choices, 
					choicesValues =  dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues, 
					choicesTooltips =  dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesTooltips, 
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", value)
					end, 
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_EDITRULE_RULE"
				},
				{
					type = "button",
					name = "New",
					tooltip = "Create a new rule",
					func = function() 
						local newName = GetUsableRuleName("NewCategory")
						local tag = GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")
						if tag == "" then
							tag = AC_EMPTY_TAG_NAME
						end
						local newRule = CreateNewRule(newName, tag)
						table.insert(AutoCategory.curSavedVars.rules, newRule)
											
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", newName)
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", newRule.tag)
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
					end,
					width = "full",
				},
				{
					type = "button",
					name = "Delete",
					tooltip = "Delete selected rule",
					func = function()  
						local oldRuleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						local oldTagName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")
						local num = #AutoCategory.curSavedVars.rules
						for i = 1, num do
							if oldRuleName == AutoCategory.curSavedVars.rules[i].name then
								table.remove(AutoCategory.curSavedVars.rules, i)
								break
							end
						end 
						
						if oldRuleName == GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") then
							--rule removed, clean selection in add rule menu if selected
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						end
						
						RemoveDropDownItem("AC_DROPDOWN_EDITRULE_RULE", dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues, oldRuleName, function(typeString)
							--if tag has no rules, will remove it.
							if oldTagName == GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG") then
								--tag removed, clean tag selection in add rule menu if selected
								SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", "")
							end
							RemoveDropDownItem("AC_DROPDOWN_EDITRULE_TAG", dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues, oldTagName)
						end)
 
						RefreshCache()   
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						--rule is missing
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
					end,
					width = "full",
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues	== 0 end,
				},
				{
					type = "header",
					name = "Edit Category",
					width = "full",
				},
				{
					type = "editbox",
					name = "Name",
					tooltip = "Name cannot be duplicated.",
					getFunc = function()  
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						if cacheRulesByName[ruleName] then
							return cacheRulesByName[ruleName].name
						end
						return "" 
					end,
					warning = function()
						return warningDuplicatedName.warningMessage
					end,
					setFunc = function(value) 
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						local oldName = cacheRulesByName[ruleName].name
						if oldName == value then 
							return
						end
						if value == "" then
							warningDuplicatedName.warningMessage = "Rule name cannot be empty."
							value = oldName
						end
						
						local isDuplicated = IsRuleNameUsed(value)
						if isDuplicated then
							warningDuplicatedName.warningMessage = string.format("Name '%s' is duplicated, you can try '%s'.", value, GetUsableRuleName(value))
							value = oldName
						end
						--change editbox's value
						local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME", "")
						control.editbox:SetText(value)

						cacheRulesByName[ruleName].name = value  				
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", value )

						--Update bags so that every entry has the same name, should be changed to new name.
						for i = 1, #AutoCategory.curSavedVars.bags do
							local bag = AutoCategory.curSavedVars.bags[i]
							local rules = bag.rules
							for j = 1, #rules do
								local rule = rules[j]
								if rule.name == oldName then
									rule.name = value
								end
							end
						end
						--Update drop downs
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
					isMultiline = false,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "half",
					reference = "AC_EDITBOX_EDITRULE_NAME",
				},
				{
					type = "editbox",
					name = "Tag",
					tooltip = "The rule is visible only when you select its tag. <Empty> will be applied if leave the name blank.",
					getFunc = function()  
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						if cacheRulesByName[ruleName] then
							return cacheRulesByName[ruleName].tag
						end
						return "" 
					end, 
				 	setFunc = function(value) 
						if value == "" then
							value = AC_EMPTY_TAG_NAME
						end
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_TAG", "")
						control.editbox:SetText(value)

						local oldGroup = cacheRulesByName[GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")].tag
						cacheRulesByName[GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")].tag = value
						
						
						RemoveDropDownItem("AC_DROPDOWN_EDITRULE_RULE", dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues, ruleName, function(typeString)
							--try to remove this rule from the tag, if tag needs delete, reselect it in add rule tab		
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", "")		
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						end)
						
						if GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") == ruleName then
							--modify the same rule, reselect add rule tab
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", value)
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", ruleName)
						end

						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", value) 
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", ruleName) 
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
					 
					end,
					isMultiline = false,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "half",
					reference = "AC_EDITBOX_EDITRULE_TAG",
				},
				{
					type = "editbox",
					name = "Description",
					tooltip = "Description",
					getFunc = function() 
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						if cacheRulesByName[ruleName] then
							return cacheRulesByName[ruleName].description
						end
						return "" 
					end, setFunc = function(value) 
						cacheRulesByName[GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")].description = value 
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
					isMultiline = false,
					isExtraWide = true,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "full",
				},
				{
					type = "editbox",
					name = "Rule",
					tooltip = "Rules will be applied to bags to categorize items",
					getFunc = function() 
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						if cacheRulesByName[ruleName] then
							return cacheRulesByName[ruleName].rule
						end
						return "" 
					end, setFunc = function(value) cacheRulesByName[GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")].rule = value end,
					isMultiline = true,
					isExtraWide = true,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "full",
				},
				
		    },
		},
		
	}
	LAM:RegisterAddonPanel("AC_CATEGORY_SETTINGS", panelData)
	LAM:RegisterOptionControls("AC_CATEGORY_SETTINGS", optionsTable)
	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshPanel)
end