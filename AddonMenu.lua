local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

AutoCategory.AddonMenu = {}
AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_BAG = "AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_BAG"
AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE = "AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE"
AutoCategory.AddonMenu.DROPDOWN_ADDRULE_TAG = "AutoCategory.AddonMenu.DROPDOWN_ADDRULE_TAG"
AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE = "AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE"
AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG = "AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG"
AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE = "AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE"
AutoCategory.AddonMenu.EDITBOX_EDITRULE_NAME = "AutoCategory.AddonMenu.EDITBOX_EDITRULE_NAME"
AutoCategory.AddonMenu.EDITBOX_EDITRULE_TAG = "AutoCategory.AddonMenu.EDITBOX_EDITRULE_TAG"
local selectedTag_RuleEditTab = ""
local selectedRule_RuleEditTab = ""
local selectedBag_BagViewTab = AC_BAG_TYPE_BACKPACK
local selectedRule_BagViewTab = ""
local selectedTag_BagAddRuleTab = ""
local selectedRule_BagAddRuleTab = ""



--array: tagName
local dataTags = {}
dataTags.values = {}

--array: bagData
local dataBags = {}
dataBags.showNames = {[AC_BAG_TYPE_BACKPACK] = "Backpack", [AC_BAG_TYPE_BANK] = "Bank"}
dataBags.values = {AC_BAG_TYPE_BACKPACK, AC_BAG_TYPE_BANK}
dataBags.tooltips = {"Backpack", "Bank"}

local dataRulesByTag = {}
local dataRulesByBag = {}

local dataCurrentRules_AddRule = {}
local dataCurrentRules_EditRule = {}
local dataCurrentRules_BagView = {}

--map{tagName : array{ruleData}} 
local cacheRulesByName = {}
local cacheBagEntriesByName = {}

local dropdownData = {}
local warningDuplicatedName = {
	warningMessage = nil,
}

local function UpdateDuplicateNameWarning()
	local control = WINDOW_MANAGER:GetControlByName(AutoCategory.AddonMenu.EDITBOX_EDITRULE_NAME, "")
	if control then
		control:UpdateWarning()			
	end
end

local function RefreshPanel()
	UpdateDuplicateNameWarning()

	--restore warning
	warningDuplicatedName.warningMessage = nil	
end

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

local function RefreshCache() 
	cacheRulesByName = {}
	dataTags.values = {}
	dataRulesByTag = {}
	dataRulesByBag = {}

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
		if not dataRulesByTag[tag] then
			--d("add tag rule: ".. tag)
			dataRulesByTag[tag] = {showNames = {}, values = {}, tooltips = {}}
			table.insert(dataTags.values, tag)
		end
		local tooltip = rule.description
		if rule.description == "" then
			tooltip = rule.name
		end
		--d("added rule: ".. name)
		table.insert(dataRulesByTag[tag].showNames, name)
		table.insert(dataRulesByTag[tag].values, name)
		table.insert(dataRulesByTag[tag].tooltips, tooltip)
	end

	for i = 1, #AutoCategory.curSavedVars.bags do
		local bag = AutoCategory.curSavedVars.bags[i]
		table.sort(bag, function(a, b) return BagDataSortingFunction(a, b) end )
		--update data for showing in the dropdown menu
		local bagId = i
		if not dataRulesByBag[bagId] then
			dataRulesByBag[bagId] = {showNames = {}, values = {}, tooltips = {}}
		end
		for j = 1, #bag.rules do
			local data = bag.rules[j]
			local ruleName = data.name
			cacheBagEntriesByName[ruleName] = data
			
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
				table.insert(dataRulesByBag[bagId].showNames, string.format("%s%s (%d)", ruleName, priority))
				table.insert(dataRulesByBag[bagId].values, ruleName)
				table.insert(dataRulesByBag[bagId].tooltips, tooltip)
			else
				table.insert(dataRulesByBag[bagId].showNames, string.format("! %s (%d)", ruleName, priority))
				table.insert(dataRulesByBag[bagId].values, ruleName)
				table.insert(dataRulesByBag[bagId].tooltips, "This rule is missing, please make sure the rule with this name exist.")
			end
			
		end
	end
end

local function RefreshDropDownSelection()
	--try to select first 
	if selectedTag_BagAddRuleTab == "" and #dataTags.values > 0 then
		selectedTag_BagAddRuleTab = dataTags.values[1]
	end
	if selectedTag_RuleEditTab == "" and #dataTags.values > 0 then
		selectedTag_RuleEditTab = dataTags.values[1]
	end
	if selectedBag_BagViewTab == "" and #dataBags.values > 0 then
		selectedBag_BagViewTab = dataBags.values[1]
	end
	if selectedRule_BagViewTab == "" and dataRulesByBag[selectedBag_BagViewTab] and #dataRulesByBag[selectedBag_BagViewTab].values > 0 then
		selectedRule_BagViewTab = dataRulesByBag[selectedBag_BagViewTab].values[1]
	end
	if selectedRule_RuleEditTab == "" and dataRulesByTag[selectedTag_RuleEditTab] and #dataRulesByTag[selectedTag_RuleEditTab].values > 0 then
		selectedRule_RuleEditTab = dataRulesByTag[selectedTag_RuleEditTab].values[1]
	end
	if selectedRule_BagAddRuleTab == "" and dataRulesByTag[selectedTag_BagAddRuleTab] and #dataRulesByTag[selectedTag_BagAddRuleTab].values > 0 then
		selectedRule_BagAddRuleTab = dataRulesByTag[selectedTag_BagAddRuleTab].values[1]
	end
end

local function RefreshCurrentRules()
	dataCurrentRules_AddRule = {}
	dataCurrentRules_AddRule.showNames = {}
	dataCurrentRules_AddRule.values = {}
	dataCurrentRules_AddRule.tooltips = {}
	dataCurrentRules_EditRule = {}
	dataCurrentRules_EditRule.showNames = {}
	dataCurrentRules_EditRule.values = {}
	dataCurrentRules_EditRule.tooltips = {}
	dataCurrentRules_BagView = {}
	dataCurrentRules_BagView.showNames = {}
	dataCurrentRules_BagView.values = {}
	dataCurrentRules_BagView.tooltips = {}
	  
	if dataRulesByTag[selectedTag_BagAddRuleTab] then 
		dataCurrentRules_AddRule.showNames = dataRulesByTag[selectedTag_BagAddRuleTab].showNames
		dataCurrentRules_AddRule.values = dataRulesByTag[selectedTag_BagAddRuleTab].values
		dataCurrentRules_AddRule.tooltips = dataRulesByTag[selectedTag_BagAddRuleTab].tooltips
	end

	if dataRulesByTag[selectedTag_RuleEditTab] then 
		dataCurrentRules_EditRule.showNames = dataRulesByTag[selectedTag_RuleEditTab].showNames
		dataCurrentRules_EditRule.values = dataRulesByTag[selectedTag_RuleEditTab].values
		dataCurrentRules_EditRule.tooltips = dataRulesByTag[selectedTag_RuleEditTab].tooltips
	end

	if dataRulesByBag[selectedBag_BagViewTab] then 
		dataCurrentRules_BagView.showNames = dataRulesByBag[selectedBag_BagViewTab].showNames
		dataCurrentRules_BagView.values =dataRulesByBag[selectedBag_BagViewTab].values
		dataCurrentRules_BagView.tooltips = dataRulesByBag[selectedBag_BagViewTab].tooltips
	end

end

local function RefreshDropdownData()
	dropdownData = {
		[AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_BAG] = {
			choices = dataBags.showNames,
			choicesValues = dataBags.values,
			choicesTooltips = dataBags.tooltips,
		},

		[AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE] = {
			choices = dataCurrentRules_BagView.showNames,
			choicesValues = dataCurrentRules_BagView.values,
			choicesTooltips = dataCurrentRules_BagView.tooltips,
		},

		[AutoCategory.AddonMenu.DROPDOWN_ADDRULE_TAG] = {
			choices = dataTags.values, 
			choicesValues = dataTags.values,
			choicesTooltips = dataTags.values,
		},

		[AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE] = {
			choices = dataCurrentRules_AddRule.showNames,
			choicesValues = dataCurrentRules_AddRule.values,
			choicesTooltips = dataCurrentRules_AddRule.tooltips,
		},

		[AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG] = {
			choices = dataTags.values, 
			choicesValues = dataTags.values,
			choicesTooltips = dataTags.values,
		},

		[AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE] = {
			choices = dataCurrentRules_EditRule.showNames,
			choicesValues =  dataCurrentRules_EditRule.values,
			choicesTooltips =  dataCurrentRules_EditRule.tooltips,
		},
	}  
end
 
local function UpdateDropDownMenu(name)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(name, "")
	RefreshDropdownData()
	local data = dropdownData[name]

	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, data.choicesTooltips) 
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

function AutoCategory.AddonMenu.Init()
	AutoCategory.UpdateCurrentSavedVars()
	RefreshCache() 
	RefreshDropDownSelection()
	RefreshCurrentRules()
 
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
			RefreshDropDownSelection()
			RefreshCurrentRules()
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
		    controls = {
				{		
					type = "dropdown",
					name = "Bag",
					tooltip = "Select a bag to modify rules that apply on",
					choices = dataBags.showNames,
					choicesValues = dataBags.values,
					choicesTooltips = dataBags.tooltips,
					
					getFunc = function() 
						return selectedBag_BagViewTab 
					end,
					setFunc = function(value) 			
						selectedBag_BagViewTab = value
						RefreshCurrentRules()
						RefreshDropDownSelection()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
					end, 
					width = "half",
					reference = AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_BAG
				},
				{		
					type = "dropdown",
					name = "Groups",
					choices = dataCurrentRules_BagView.showNames,
					choicesValues = dataCurrentRules_BagView.values,
					choicesTooltips = dataCurrentRules_BagView.tooltips,
					
					getFunc = function() 
						return selectedRule_BagViewTab 
					end,
					setFunc = function(value) 			
						selectedRule_BagViewTab = value
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
					end, 
					disabled = function() return #dataCurrentRules_BagView == 0 end,
					width = "half",
					reference = AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE
				},
				{
					type = "button",
					name = "Remove",
					tooltip = "Remove selected rule from bag",
					func = function()  
						local ruleName = selectedRule_BagViewTab
						local removedIndex = RemoveRuleFromBag(ruleName, selectedBag_BagViewTab)
						local rules = AutoCategory.curSavedVars.bags[selectedBag_BagViewTab].rules
						if #rules == 0 then
							selectedRule_BagViewTab = ""
						else
							if removedIndex >= #rules then
								removedIndex = #rules - 1
							end
							selectedRule_BagViewTab = rules[removedIndex].name
						end
						RefreshCache()
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
					end,
					disabled = function() return #dataCurrentRules_BagView == 0 end,
					width = "full",
				},
				{
					type = "header",
					name = "Edit Group Order",
					width = "full",
				},
				{
					type = "slider",
					name = "Priority",
					tooltip = "Priority determines the order of the group in the bag, higher means more ahead position.",
					min = 0,
					max = 100,
					getFunc = function() 
						if cacheBagEntriesByName[selectedRule_BagViewTab] then
							return cacheBagEntriesByName[selectedRule_BagViewTab].priority
						end
						return 0
					end, 
					setFunc = function(value) 
						if cacheBagEntriesByName[selectedRule_BagViewTab] then
							cacheBagEntriesByName[selectedRule_BagViewTab].priority = value 
							RefreshCache()
							RefreshCurrentRules()
							UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
						end
					end,
					disabled = function() 
						if selectedRule_BagViewTab == "" then
							return true
						end
						if not cacheBagEntriesByName[selectedRule_BagViewTab] then
							return true
						end
						return false
					end,
					width = "full",
				},
				{
					type = "header",
					name = "Add Group",
					width = "full",
				},
				{		
					type = "dropdown",
					name = "Tag",
					choices = dataTags.values, 
					choicesValues = dataTags.values,
					choicesTooltips = dataTags.values,
					
					getFunc = function() 
						return selectedTag_BagAddRuleTab 
					end,
					setFunc = function(value) 			
						selectedTag_BagAddRuleTab = value
						RefreshCurrentRules()
						RefreshDropDownSelection()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE)
					end, 
					width = "half",
					disabled = function() return #dataTags.values == 0 end,
					reference = AutoCategory.AddonMenu.DROPDOWN_ADDRULE_TAG
				},
				{		
					type = "dropdown",
					name = "Rule",
					choices = dataCurrentRules_AddRule.showNames,
					choicesValues = dataCurrentRules_AddRule.values,
					choicesTooltips = dataCurrentRules_AddRule.tooltips,
					
					getFunc = function() 
						return selectedRule_BagAddRuleTab 
					end,
					setFunc = function(value) 			
						selectedRule_BagAddRuleTab = value
					end, 
					disabled = function() return #dataCurrentRules_AddRule.values == 0 end,
					width = "half",
					reference = AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE
				},
				{
					type = "button",
					name = "Add",
					tooltip = "Add selected rule to the bag",
					func = function()  
						local ruleName = selectedRule_BagAddRuleTab
						local entry = CreateNewBagRuleEntry(ruleName)
						table.insert(AutoCategory.curSavedVars.bags[selectedBag_BagViewTab], entry) 
						selectedRule_BagViewTab = ruleName
						RefreshCache()
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
					end,
					disabled = function() return #dataCurrentRules_AddRule.values == 0 end,
					width = "full",
				},
				
		    },
		},
		{
			type = "submenu",
		    name = "|c0066FF[Rule Setting]|r", -- or string id or function returning a string
		    controls = {
				{		
					type = "dropdown",
					name = "Tag",
					tooltip = "Tag the rule and make them organized.",
					choices = dataTags.values, 
					choicesValues = dataTags.values,
					choicesTooltips = dataTags.values,
					
					getFunc = function() 
						return selectedTag_RuleEditTab 
					end,
					setFunc = function(value) 			
						selectedTag_RuleEditTab = value
						selectedRule_RuleEditTab = ""
						RefreshCurrentRules()
						RefreshDropDownSelection()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE)
					end, 
					width = "half",
					disabled = function() return #dataTags.values == 0 end,
					reference = AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG
				},
				{		
					type = "dropdown",
					name = "Rule", 
					choices = dataCurrentRules_EditRule.showNames,
					choicesValues =  dataCurrentRules_EditRule.values,
					choicesTooltips =  dataCurrentRules_EditRule.tooltips,
					
					getFunc = function() 
						return selectedRule_RuleEditTab 
					end,
					setFunc = function(value) 			
						selectedRule_RuleEditTab = value
					end, 
					disabled = function() return #dataCurrentRules_EditRule.values == 0 end,
					width = "half",
					reference = AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE
				},
				{
					type = "button",
					name = "New",
					tooltip = "Create a new rule",
					func = function() 
						local newName = GetUsableRuleName("NewRule")
						local tag = selectedTag_RuleEditTab
						if tag == "" then
							tag = AC_EMPTY_TAG_NAME
						end
						local newRule = CreateNewRule(newName, tag)
						table.insert(AutoCategory.curSavedVars.rules, newRule)
											
						selectedRule_RuleEditTab = newName
						selectedTag_RuleEditTab = newRule.tag
						--d("tag:"..selectedTag_RuleEditTab)
						RefreshCache()
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE)
					end,
					width = "full",
				},
				{
					type = "button",
					name = "Delete",
					tooltip = "Delete selected rule",
					func = function()  
						local num = #AutoCategory.curSavedVars.rules
						for i = 1, num do
							if selectedRule_RuleEditTab == AutoCategory.curSavedVars.rules[i].name then
								table.remove(AutoCategory.curSavedVars.rules, i)
								break
							end
						end 

						--find the one after delete
						local lastIndex = -1
						num = #dataCurrentRules_EditRule.values
						for i = 1, num do
							if dataCurrentRules_EditRule.values[i] == selectedRule_RuleEditTab then			
								table.remove(dataCurrentRules_EditRule.values, i)
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
						
						--last one deleted
						if lastIndex == 0 then
							selectedRule_RuleEditTab = ""
							selectedTag_RuleEditTab = ""	
						else
							selectedRule_RuleEditTab = dataCurrentRules_EditRule.values[lastIndex]
						end
						RefreshCache()  
						RefreshDropDownSelection()
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE)
					end,
					width = "full",
					disabled = function() return #dataCurrentRules_EditRule.values == 0 end,
				},
				{
					type = "header",
					name = "Edit Rule",
					width = "full",
				},
				{
					type = "editbox",
					name = "Name",
					tooltip = "Name cannot be duplicated.",
					getFunc = function()  
						if cacheRulesByName[selectedRule_RuleEditTab] then
							return cacheRulesByName[selectedRule_RuleEditTab].name
						end
						return "" 
					end,
					warning = function()
						return warningDuplicatedName.warningMessage
					end,
					setFunc = function(value) 
						local oldName = cacheRulesByName[selectedRule_RuleEditTab].name
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
						local control = WINDOW_MANAGER:GetControlByName(AutoCategory.AddonMenu.EDITBOX_EDITRULE_NAME, "")
						control.editbox:SetText(value)

						cacheRulesByName[selectedRule_RuleEditTab].name = value  				
						selectedRule_RuleEditTab = value 

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
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE)
					end,
					isMultiline = false,
					disabled = function() return #dataCurrentRules_EditRule.values == 0 end,
					width = "half",
					reference = AutoCategory.AddonMenu.EDITBOX_EDITRULE_NAME,
				},
				{
					type = "editbox",
					name = "Tag",
					tooltip = "The rule is visible only when you select its tag. <Empty> will be applied if leave the name blank.",
					getFunc = function()  
						if cacheRulesByName[selectedRule_RuleEditTab] then
							return cacheRulesByName[selectedRule_RuleEditTab].tag
						end
						return "" 
					end, 
				 	setFunc = function(value) 
						if value == "" then
							value = AC_EMPTY_TAG_NAME
						end
						local control = WINDOW_MANAGER:GetControlByName(AutoCategory.AddonMenu.EDITBOX_EDITRULE_TAG, "")
						control.editbox:SetText(value)

						local oldGroup = cacheRulesByName[selectedRule_RuleEditTab].tag
						cacheRulesByName[selectedRule_RuleEditTab].tag = value

						RefreshCache()
						--If using this group, change selected group to new one.
						if selectedTag_BagAddRuleTab == oldGroup then
							selectedTag_BagAddRuleTab = value
						end 
						selectedTag_RuleEditTab = value
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_ADDRULE_TAG)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_TAG)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE)
					 
					end,
					isMultiline = false,
					disabled = function() return #dataCurrentRules_EditRule.values == 0 end,
					width = "half",
					reference = AutoCategory.AddonMenu.EDITBOX_EDITRULE_TAG,
				},
				{
					type = "editbox",
					name = "Description",
					tooltip = "Description",
					getFunc = function() 
						if cacheRulesByName[selectedRule_RuleEditTab] then
							return cacheRulesByName[selectedRule_RuleEditTab].description
						end
						return "" 
					end, setFunc = function(value) 
						cacheRulesByName[selectedRule_RuleEditTab].description = value 
						RefreshCache()
						RefreshCurrentRules()
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_BAGVIEW_RULE)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_EDITRULE_RULE)
						UpdateDropDownMenu(AutoCategory.AddonMenu.DROPDOWN_ADDRULE_RULE)
					end,
					isMultiline = false,
					isExtraWide = true,
					disabled = function() return #dataCurrentRules_EditRule.values == 0 end,
					width = "full",
				},
				{
					type = "editbox",
					name = "Rule",
					tooltip = "Rules will be applied to bags to categorize items",
					getFunc = function() 
						if cacheRulesByName[selectedRule_RuleEditTab] then
							return cacheRulesByName[selectedRule_RuleEditTab].rule
						end
						return "" 
					end, setFunc = function(value) cacheRulesByName[selectedRule_RuleEditTab].rule = value end,
					isMultiline = true,
					isExtraWide = true,
					disabled = function() return #dataCurrentRules_EditRule.values == 0 end,
					width = "full",
				},
				
		    },
		},
		
	}
	LAM:RegisterAddonPanel("AC_CATEGORY_SETTINGS", panelData)
	LAM:RegisterOptionControls("AC_CATEGORY_SETTINGS", optionsTable)
	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshPanel)
end