--====API====--
function AutoCategory:MatchCategoryRules( bagId, slotIndex, specialType )
	AutoCategory.LazyInit()

	self.checkingItemBagId = bagId
	self.checkingItemSlotIndex = slotIndex
	local bag_type_id
	if specialType then
		bag_type_id = specialType
	else 
		if bagId == BAG_BACKPACK or bagId == BAG_WORN then
			bag_type_id = AC_BAG_TYPE_BACKPACK
		elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
			bag_type_id = AC_BAG_TYPE_BANK
		elseif bagId == BAG_VIRTUAL then
			bag_type_id = AC_BAG_TYPE_CRAFTBAG
		elseif bagId == BAG_GUILDBANK then
			bag_type_id = AC_BAG_TYPE_GUILDBANK
		end
	end
	if not bag_type_id then
		return false, "", 0
	end
	local needCheck = false
	local bag = AutoCategory.curSavedVars.bags[bag_type_id]
	for i = 1, #bag.rules do
		local entry = bag.rules[i] 
		local rule = AutoCategory.GetRuleByName(entry.name)
		if rule then
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
						return true, rule.name .. AutoCategory.AdditionCategoryName, entry.priority
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
	end
	
	return false, "", 0
end
