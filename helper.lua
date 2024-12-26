ConROC.RaidBuffs = {};
ConROC.WarningFlags = {};

-- Global cooldown spell id
-- GlobalCooldown = 61304;

local INF = 2147483647;

function ConROC:TalentChosen(spec, talent)
	local name, _, tier, _, currentRank, maxRank = GetTalentInfo(spec, talent);
	if currentRank >= 1 then
		return true, currentRank, maxRank, name, tier;
	end
	return false, 0, 0, 0, 0;
end

function ConROC:currentSpec()
    local numTabs  = GetNumTalentTabs();
    local currentSpecName, currentSpecID = false, 0;
    local maxPoints = 0;
    for tab = 1, numTabs do
        local numTalents = GetNumTalents(tab);
        local pointsSpent = 0;
        for talent = 1, numTalents do
            local _, _, _, _, spent = GetTalentInfo(tab, talent);
            pointsSpent = pointsSpent + spent;
        end
        if pointsSpent > maxPoints then
            maxPoints = pointsSpent;
            currentSpecID, currentSpecName = GetTalentTabInfo(tab);
        end
    end
	return currentSpecName, currentSpecID;
end

function ConROC:PopulateTalentIDs()
    local numTabs = GetNumTalentTabs()
    for tabIndex = 1, numTabs do
        local tabName = GetTalentTabInfo(tabIndex)
        tabName = string.gsub(tabName, "[^%w]", "") .. "_Talent" -- Remove spaces from tab name
        print("ids."..tabName.." = {")
        local numTalents = GetNumTalents(tabIndex)
        for talentIndex = 1, numTalents do
            local name, _, _, _, _ = GetTalentInfo(tabIndex, talentIndex)
            if name then
                local talentID = string.gsub(name, "[^%w]", "") -- Remove spaces from talent name
                    print(talentID .." = ", talentIndex ..",")
            end
        end
        print("}")
    end
end

function ConROC:IsPvP()
	local _is_PvP = UnitIsPVP('player');
	local _is_Arena, _is_Registered = IsActiveBattlefieldArena();
	local _Flagged = false;
		if _is_PvP or _is_Arena then
			_Flagged = true;
		end
	return _Flagged;
end

function ConROC:PlayerSpeed()
	local speed  = (GetUnitSpeed("player") / 7) * 100;
	local moving = false;
		if speed > 0 then
			moving = true;
		else
			moving = false;
		end
	return moving;
end

ConROC.EnergyList = {
	[0]	= 'Mana',
	[1] = 'Rage',
	[2]	= 'Focus',
	[3] = 'Energy',
	[4]	= 'Combo',
	[6] = 'RunicPower',
	[7]	= 'SoulShards',
	[8] = 'LunarPower',
	[9] = 'HolyPower',
	[11] = 'Maelstrom',
	[12] = 'Chi',
	[13] = 'Insanity',
	[16] = 'ArcaneCharges',
	[17] = 'Fury',
	[19] = 'Essence',
}

function ConROC:PlayerPower(_EnergyType)
	local resource;

	for k, v in pairs(ConROC.EnergyList) do
		if v == _EnergyType then
			resource = k;
			break
		end
	end

	local _Resource = UnitPower('player', resource);
	local _Resource_Max	= UnitPowerMax('player', resource);
	local _Resource_Percent = math.max(0, _Resource) / math.max(1, _Resource_Max) * 100;

	return _Resource, _Resource_Max, _Resource_Percent;
end

local defaultEnemyNameplates
local defaultNameplateMinAlpha
local defaultNameplateMaxAlpha
local defaultNameplateNotSelectedAlpha
local defaultNameplateSelectedAlpha
function ConROC:forceNameplates()
	defaultEnemyNameplates = GetCVar("nameplateShowEnemies")
	if defaultEnemyNameplates ~= 1 then
		defaultNameplateMinAlpha = GetCVar("nameplateMinAlpha")
		defaultNameplateMaxAlpha = GetCVar("nameplateMaxAlpha")
		defaultNameplateSelectedAlpha = GetCVar("nameplateSelectedAlpha")
  		--SetCVar("nameplateOtherMinAlpha", ConROC.db.profile.nameplatesMinAlpha)
		--SetCVar("nameplateOtherMaxAlpha", ConROC.db.profile.nameplatesMaxAlpha)
		SetCVar("nameplateNotSelectedAlpha", ConROC.db.profile.nameplateNotSelectedAlpha)
		SetCVar("nameplateSelectedAlpha", ConROC.db.profile.nameplateSelectedAlpha)
  		SetCVar("nameplateShowEnemies", 1)
  	end
end

function ConROC:restoreNameplates()
	-- Restore default settings 
	--SetCVar("nameplateMinAlpha", defaultNameplateMinAlpha) 
	--SetCVar("nameplateMaxAlpha", defaultNameplateMaxAlpha)
	SetCVar("nameplateNotSelectedAlpha", defaultNameplateSelectedAlpha)
	SetCVar("nameplateSelectedAlpha", defaultNameplateSelectedAlpha)
	SetCVar('nameplateShowEnemies', defaultEnemyNameplates)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Leaving combat

frame:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_REGEN_DISABLED" then
    ConROC:forceNameplates()
  elseif event == "PLAYER_REGEN_ENABLED" then
    ConROC:restoreNameplates()
  end
end)

function ConROC:Targets(spellID)
	local target_in_range = false;
	local number_in_range = 0;
	local minRange, maxRange = false, false;
		if spellID == "Melee" then
			if UnitReaction("player", "target") ~= nil then
				if UnitReaction("player", "target") <= 4 and UnitExists("target") then
					_, maxRange = ConROC.rc:getRange("target");
					if maxRange then
						if tonumber(maxRange) <= 5 then
							target_in_range = true;
						end
					end
				end
			end

			for i = 1, 15 do
				if UnitReaction("player", 'nameplate' .. i) ~= nil then
					if UnitReaction("player", 'nameplate' .. i) <= 4 and UnitExists('nameplate' .. i) and UnitAffectingCombat('nameplate' .. i) then
						_, maxRange = ConROC.rc:getRange('nameplate' .. i);
						if maxRange then
							if tonumber(maxRange) <= 5 then
								number_in_range = number_in_range + 1
							end
						end
					end
				end
			end
		elseif spellID == "10" then
			if UnitReaction("player", "target") ~= nil then
				if UnitReaction("player", "target") <= 4 and UnitExists("target") then
					_, maxRange = ConROC.rc:getRange("target");
					if maxRange then
						if tonumber(maxRange) <= 10 then
							target_in_range = true;
						end
					end
				end
			end

			for i = 1, 15 do
				if UnitReaction("player", 'nameplate' .. i) ~= nil then
					if UnitReaction("player", 'nameplate' .. i) <= 4 and UnitExists('nameplate' .. i) and UnitAffectingCombat('nameplate' .. i) then
						_, maxRange = ConROC.rc:getRange('nameplate' .. i);
						if maxRange then
							if tonumber(maxRange) <= 10 then
								number_in_range = number_in_range + 1
							end
						end
					end
				end
			end
		elseif spellID == "20" then
			if UnitReaction("player", "target") ~= nil then
				if UnitReaction("player", "target") <= 4 and UnitExists("target") then
					_, maxRange = ConROC.rc:getRange("target");
					if maxRange then
						if tonumber(maxRange) <= 20 then
							target_in_range = true;
						end
					end
				end
			end

			for i = 1, 15 do
				if UnitReaction("player", 'nameplate' .. i) ~= nil then
					if UnitReaction("player", 'nameplate' .. i) <= 4 and UnitExists('nameplate' .. i) and UnitAffectingCombat('nameplate' .. i) then
						_, maxRange = ConROC.rc:getRange('nameplate' .. i);
						if maxRange then
							if tonumber(maxRange) <= 20 then
								number_in_range = number_in_range + 1
							end
						end
					end
				end
			end
		elseif spellID == "30" then
			if UnitReaction("player", "target") ~= nil then
				if UnitReaction("player", "target") <= 4 and UnitExists("target") then
					_, maxRange = ConROC.rc:getRange("target");
					if maxRange then
						if tonumber(maxRange) <= 30 then
							target_in_range = true;
						end
					end
				end
			end

			for i = 1, 15 do
				if UnitReaction("player", 'nameplate' .. i) ~= nil then
					if UnitReaction("player", 'nameplate' .. i) <= 4 and UnitExists('nameplate' .. i) and UnitAffectingCombat('nameplate' .. i) then
						_, maxRange = ConROC.rc:getRange('nameplate' .. i);
						if maxRange then
							if tonumber(maxRange) <= 30 then
								number_in_range = number_in_range + 1
							end
						end
					end
				end
			end
		elseif spellID == "40" then
			if UnitReaction("player", "target") ~= nil then
				if UnitReaction("player", "target") <= 4 and UnitExists("target") then
					_, maxRange = ConROC.rc:getRange("target");
					if maxRange then
						if tonumber(maxRange) <= 40 then
							target_in_range = true;
						end
					end
				end
			end

			for i = 1, 15 do
				if UnitReaction("player", 'nameplate' .. i) ~= nil then
					if UnitReaction("player", 'nameplate' .. i) <= 4 and UnitExists('nameplate' .. i) and UnitAffectingCombat('nameplate' .. i) then
						_, maxRange = ConROC.rc:getRange('nameplate' .. i);
						if maxRange then
							if tonumber(maxRange) <= 40 then
								number_in_range = number_in_range + 1
							end
						end
					end
				end
			end
		else
			if ConROC:IsSpellInRange(spellID, "target") then
				target_in_range = true;
			end

			for i = 1, 15 do
				if UnitExists('nameplate' .. i) and UnitAffectingCombat('nameplate' .. i) and ConROC:IsSpellInRange(spellID, 'nameplate' .. i) then
					number_in_range = number_in_range + 1
				end
			end
		end
	--print(number_in_range)
	return number_in_range, target_in_range;
end

function ConROC:UnitAura(spellID, timeShift, unit, filter, isWeapon)
	timeShift = timeShift or 0;
	local spellName = GetSpellInfo(spellID);
	local alreadyUp = false;

	-- Handling weapon enchants
	if isWeapon == "Weapon" then
		local hasMainHandEnchant, mainHandExpiration, _, mainBuffId, hasOffHandEnchant, offHandExpiration, _, offBuffId = GetWeaponEnchantInfo()
		if hasMainHandEnchant and mainBuffId == spellID then
			if mainHandExpiration and (mainHandExpiration / 1000) > timeShift then
				local dur = (mainHandExpiration / 1000) - timeShift;
				return true, 0, dur;  -- No count information for weapon enchants
			end
		elseif hasOffHandEnchant and offBuffId == spellID then
			if offHandExpiration and (offHandExpiration / 1000) > timeShift then
				local dur = (offHandExpiration / 1000) - timeShift;
				return true, 0, dur;  -- No count information for weapon enchants
			end
		end
	else
		-- Iterating through unit auras
		for i = 1, 40 do
			local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
			if not aura then
				break  -- No more auras to check
			end

			if aura.name == spellName then
				alreadyUp = true;
			end

			if aura.spellId == spellID then
				local expirationTime = aura.expirationTime
				if expirationTime and (expirationTime - GetTime()) > timeShift then
					local dur = expirationTime - GetTime() - timeShift
					return true, aura.applications or 1, dur, alreadyUp;
				end
			end
		end
	end
	return false, 0, 0, alreadyUp;
end

function ConROC:Form(spellID)
	for i = 1, 40 do
		local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL");
		if aura and aura.spellId == spellID then
			return true, aura.applications or 1;
			end
	end
	return false, 0;
end

function ConROC:PersistentDebuff(spellID)
	for i = 1, 40 do
		local aura = C_UnitAuras.GetAuraDataByIndex("target", i, "PLAYER|HARMFUL");
		if aura and aura.spellId == spellID then
			return true, aura.applications or 1;
		end
	end
	return false, 0;
end

function ConROC:Aura(spellID, timeShift, filter)
	return self:UnitAura(spellID, timeShift, 'player', filter);
end

function ConROC:TargetAura(spellID, timeShift)
	return self:UnitAura(spellID, timeShift, 'target', 'PLAYER|HARMFUL');
end

function ConROC:AnyTargetAura(spellID)
	local haveBuff = false;
	local count = 0;

	-- Iterate over nameplates
	for i = 1, 15 do
		if UnitExists('nameplate' .. i) then
			-- Iterate over auras on the current nameplate
			for x = 1, 40 do
				local aura = C_UnitAuras.GetAuraDataByIndex('nameplate' .. i, x, 'PLAYER|HARMFUL')
				if not aura then
					break  -- No more auras to check
				end

				if aura.spellId == spellID then
					haveBuff = true;
					count = count + 1;
					break;  -- No need to check further auras on this nameplate
				end
			end
		end
	end

	return haveBuff, count;
end

function ConROC:Purgable()
	local purgable = false;
	for i = 1, 40 do
		local aura = C_UnitAuras.GetAuraDataByIndex("target", i, "HELPFUL");
		if aura and aura.isStealable then
			purgable = true;
			break;
		end
	end
	return purgable;
end

function ConROC:Heroism()
	local _Bloodlust = 2825;
	local _TimeWarp	= 80353;
	local _Heroism = 32182;
	local _AncientHysteria = 90355;
	local _Netherwinds = 160452;
	local _DrumsofFury = 120257;
	local _DrumsofFuryBuff = 178207;
	local _DrumsoftheMountain = 142406;
	local _DrumsoftheMountainBuff = 230935;

	local _Exhaustion = 57723;
	local _Sated = 57724;
	local _TemporalDisplacement = 80354;
	local _Insanity = 95809;
	local _Fatigued = 160455;
	
	local buffed = false;
	local sated = false;
	
		local hasteBuff = {
			bl = ConROC:Aura(_Bloodlust, timeShift);
			tw = ConROC:Aura(_TimeWarp, timeShift);
			hero = ConROC:Aura(_Heroism, timeShift);
			ah = ConROC:Aura(_AncientHysteria, timeShift);
			nw = ConROC:Aura(_Netherwinds, timeShift);
			dof = ConROC:Aura(_DrumsofFuryBuff, timeShift);
			dotm = ConROC:Aura(_DrumsoftheMountainBuff, timeShift);
		}
		local satedDebuff = {
			ex = UnitDebuff('player', _Exhaustion);
			sated = UnitDebuff('player', _Sated);
			td = UnitDebuff('player', _TemporalDisplacement);
			ins = UnitDebuff('player', _Insanity);
			fat = UnitDebuff('player', _Fatigued);
		}
		local hasteCount = 0;
			for k, v in pairs(hasteBuff) do
				if v then
					hasteCount = hasteCount + 1;
				end
			end
				
		if hasteCount > 0 then
			buffed = true;
		end
		
		local satedCount = 0;
			for k, v in pairs(satedDebuff) do
				if v then
					satedCount = satedCount + 1;
				end
			end
				
		if satedCount > 0 then
			sated = true;
		end
			
	return buffed, sated;
end

function ConROC:InRaid()
	local numGroupMembers = GetNumGroupMembers();
	if numGroupMembers >= 6 then
		return true;
	else
		return false;
	end
end

function ConROC:InParty()
	local numGroupMembers = GetNumGroupMembers();
	if numGroupMembers >= 2 and numGroupMembers <= 5 then
		return true;
	else
		return false;
	end
end

function ConROC:IsSolo()
	local numGroupMembers = GetNumGroupMembers();
	if numGroupMembers <= 1 then
		return true;
	else
		return false;
	end
end

function ConROC:RaidBuff(spellID)
	local selfhasBuff = false;
	local haveBuff = false;
	local buffedRaid = false;

	local numGroupMembers = GetNumGroupMembers();
		if numGroupMembers >= 6 then
			for i = 1, numGroupMembers do -- For each raid member
				local unit = "raid" .. i;
				if UnitExists(unit) then
					for x=1, 16 do
						local spell = select(10, UnitAura(unit, x, 'HELPFUL'));
						if spell == spellID then
							haveBuff = true;
							break;
						end
					end
					if not haveBuff then
						break;
					end
				end
			end
		elseif numGroupMembers >= 2 and numGroupMembers <= 5 then
			for i = 1, 4 do -- For each party member
				local unit = "party" .. i;
				if UnitExists(unit) then
					for x=1, 40 do
						local spell = select(10, UnitAura(unit, x, 'HELPFUL'));
						if spell == spellID then
							haveBuff = true;
							break;
						end
					end
					if not haveBuff then
						break;
					end
				end
			end
			for x=1, 40 do
				local spell = select(10, UnitAura('player', x, 'HELPFUL')); 
				if spell == spellID then
					selfhasBuff = true;
					break;
				end
			end
		elseif numGroupMembers <= 1 then
			for x=1, 40 do
				local spell = select(10, UnitAura('player', x, 'HELPFUL')); 
				if spell == spellID then
					selfhasBuff = true;
					haveBuff = true;
					break;
				end
			end
		end
		if selfhasBuff and haveBuff then
			buffedRaid = true;
		end
--	self:Print(self.Colors.Info .. numGroupMembers);	
	return buffedRaid;
end

function ConROC:OneBuff(spellID)
	local selfhasBuff = false;
	local haveBuff = false;
	local someoneHas = false;

	local numGroupMembers = GetNumGroupMembers();
		if numGroupMembers >= 6 then
			for i = 1, numGroupMembers do -- For each raid member
				local unit = "raid" .. i;
				if UnitExists(unit) then
					for x=1, 16 do
						local spell = select(10, UnitAura(unit, x, 'PLAYER|HELPFUL'));
						if spell == spellID then
							haveBuff = true;
							break;
						end
					end
					if haveBuff then
						break;
					end
				end
			end
		elseif numGroupMembers >= 2 and numGroupMembers <= 5 then
			for x=1, 16 do
				local spell = select(10, UnitAura('player', x, 'PLAYER|HELPFUL')); 
				if spell == spellID then
					selfhasBuff = true;
					break;
				end
			end
			if not selfhasBuff then
				for i = 1, 4 do -- For each party member
					local unit = "party" .. i;
					if UnitExists(unit) then
						for x=1, 16 do
							local spell = select(10, UnitAura(unit, x, 'PLAYER|HELPFUL'));
							if spell == spellID then
								haveBuff = true;
								break;
							end
						end
						if haveBuff then
							break;
						end					
					end
				end
			end
		elseif numGroupMembers <= 1 then
			for x=1, 16 do
				local spell = select(10, UnitAura('player', x, 'PLAYER|HELPFUL')); 
				if spell == spellID then
					selfhasBuff = true;
					break;
				end
			end
		end
		if selfhasBuff or haveBuff then
			someoneHas = true;
		end
--	self:Print(self.Colors.Info .. numGroupMembers);		
	return someoneHas;
end

function ConROC:EndCast(target)
	target = target or 'player';
	local t = GetTime();
	local c = t * 1000;
	local gcd = 0;
	local _, _, _, _, endTime, _, _, _, spellId = CastingInfo('player');

	-- we can only check player global cooldown
	if target == 'player' then
		local gstart, gduration = GetSpellCooldown(29515);
		gcd = gduration - (t - gstart);

		if gcd < 0 then
			gcd = 0;
		end;
	end

	if not endTime then
		return gcd, nil, gcd;
	end

	local timeShift = (endTime - c) / 1000;
	if gcd > timeShift then
		timeShift = gcd;
	end

	return timeShift, spellId, gcd;
end

function ConROC:SameSpell(spell1, spell2)
	local spellName1 = GetSpellInfo(spell1);
	local spellName2 = GetSpellInfo(spell2);
	return spellName1 == spellName2;
end

function ConROC:IsOverride(spellID)
	local _OverriddenBy = C_Spell.GetOverrideSpell(spellID);
	return _OverriddenBy;
end

--[[
0 = ammo
1 = head
2 = neck
3 = shoulder
4 = shirt
5 = chest
6 = belt
7 = legs
8 = feet
9 = wrist
10 = gloves
11 = finger 1
12 = finger 2
13 = trinket 1
14 = trinket 2
15 = back
16 = main hand
17 = off hand
18 = ranged
19 = tabard
20 = first bag (the rightmost one)
21 = second bag
22 = third bag
23 = fourth bag (the leftmost one)
]]

function ConROC:RuneEquipped(spellID, equipSlot)
	local _Slot = _;
	local _EquipmentID = {
		[1] = "head",
		[5] = "chest",
		[6] = "waist",
		[7] = "legs",
		[8] = "feet",
		[9] = "wrist",
		[10] = "hands",
		[15] = "back",
		}
	for k, v in pairs(_EquipmentID) do
		if v == equipSlot then
			_Slot = k;
			break
		end
	end

	local _Engraving_Info = C_Engraving.GetRuneForEquipmentSlot(_Slot);
	local _Item_Enchanted = false;
	if _Engraving_Info ~= nil then
		if _Engraving_Info.itemEnchantmentID ~= nil then
			if _Engraving_Info.itemEnchantmentID == spellID then
				_Item_Enchanted = true;
			end
		end
	end
	return _Item_Enchanted;
end

function ConROC:TarYou()
	local tarYou = false;
	local targettarget = UnitName('targettarget');
	local targetplayer = UnitName('player');
	if targettarget == targetplayer then
		tarYou = true;
	end
	return tarYou;
end

function ConROC:TarHostile()
	local isEnemy = UnitReaction("player","target");
	local isDead = UnitIsDead("target");
		if isEnemy ~= nil then
			if isEnemy <= 4 and not isDead then
				return true;
			else
				return false;
			end
		end
	return false;
end

function ConROC:PercentHealth(target_unit)
	local unit = target_unit or 'target';
	local health = UnitHealth(unit);
	local healthMax = UnitHealthMax(unit);
	if health <= 0 or healthMax <= 0 then
		return 101;
	end
	return (health/healthMax)*100;
end

ConROC.Spellbook = {};
function ConROC:FindSpellInSpellbook(spellID)
	local spellName = GetSpellInfo(spellID);
	if ConROC.Spellbook[spellName] then
		return ConROC.Spellbook[spellName];
	end

	local _, _, offset, numSpells = GetSpellTabInfo(2);
	local booktype = 'spell';

	for index = offset + 1, numSpells + offset do
		local spellID = select(2, GetSpellBookItemInfo(index, booktype));
		if spellID and spellName == GetSpellBookItemName(index, booktype) then
			ConROC.Spellbook[spellName] = index;
			return index;
		end
	end

	return nil;
end

function ConROC:IsMeleeRange()
	local minRange, maxRange = ConROC.rc:getRange("target");
	if maxRange and self:TarHostile() then
		--print("Max range: ", maxRange);
		if tonumber(maxRange) <= 5 then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

function ConROC:IsSpellInRange(spellid, target_unit)
	local unit = target_unit or 'target';
	local range = false;
	local known = IsPlayerSpell(spellid);

	if known and ConROC:TarHostile() then
		-- Use C_Spell.IsSpellInRange instead of IsSpellInRange
		local inRange = C_Spell.IsSpellInRange(spellid, unit);

		if inRange == nil then
			local myIndex = nil
            local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(2) -- Get skill line info for the second tab

            if skillLineInfo then
                local offset = skillLineInfo.itemIndexOffset
                local numSpells = skillLineInfo.numSpellBookItems
                local booktype = Enum.SpellBookSpellBank.Player

                if offset and numSpells then
					for index = offset + 1, numSpells + offset do
						local spellBookInfo = C_SpellBook.GetSpellBookItemInfo(index, booktype)
                        if spellBookInfo and spellid == spellBookInfo.spellID then
                            myIndex = index
                            break
						end
					end
				end
			else
                -- Handle case where skillLineInfo is nil
                print("Error: Unable to retrieve skill line information.")
            end

			local numPetSpells, _ = C_SpellBook.HasPetSpells()
            if not myIndex and numPetSpells then
                local booktype = Enum.SpellBookSpellBank.Pet
				for index = 1, numPetSpells do
					local spellBookInfo = C_SpellBook.GetSpellBookItemInfo(index, booktype)
                    if spellBookInfo and spellid == spellBookInfo.spellID then
                        myIndex = index
                        break
					end
				end
			end

			if myIndex then
				inRange = C_Spell.IsSpellInRange(myIndex, unit)
            end
		end

		if inRange == true then
            range = true
        end
    end

  return range;
end

function ConROC:AbilityReady(spellid, timeShift, spelltype)
	local _CD, _MaxCD = ConROC:Cooldown(spellid, timeShift);
	local known = IsPlayerSpell(spellid) or IsSpellKnownOrOverridesKnown(spellid);
	local usable, notEnough = C_Spell.IsSpellUsable(spellid);
	local castTimeMilli = C_Spell.GetSpellInfo(spellid).castTime;
	local castTime = 0;
	local rdy = false;
		if spelltype == 'pet' then
			known = IsSpellKnown(spellid, true);
		end
		if known and usable and _CD <= 0 and not notEnough then
			rdy = true;
		else
			rdy = false;
		end
		if castTimeMilli ~= nil then
			castTime = castTimeMilli/1000;
		end
	return spellid, rdy, _CD, _MaxCD, castTime;
end

function ConROC:ItemReady(itemid, timeShift)
	local cd, maxCooldown = ConROC:ItemCooldown(itemid, timeShift);
	local equipped = IsEquippedItem(itemid);
	local rdy = false;
		if equipped and cd <= 0 then
			rdy = true;
		else
			rdy = false;
		end
	return rdy, cd, maxCooldown;
end

function ConROC:SpellCharges(spellid)
	local currentCharges, maxCharges, cooldownStart, maxCooldown = GetSpellCharges(spellid);
	local currentCooldown = 10000;
		if currentCharges ~= nil and currentCharges < maxCharges then
			currentCooldown = (maxCooldown - (GetTime() - cooldownStart));
		end
	return currentCharges, maxCharges, currentCooldown, maxCooldown;
end

function ConROC:Raidmob()
	local classification = UnitClassification("target")
	local tlvl = UnitLevel("target")
	local plvl = UnitLevel("player")
	local strong = false
	
		if classification == "worldboss" or classification == "rareelite" or classification == "elite" then
			strong = true;
		elseif tlvl == -1 or tlvl > plvl + 2 then
			strong = true;
		end
		
	return strong
end

function ConROC:CreatureType(creatureCheck)
	local creatureType = UnitCreatureType("target");
	local locale = GetLocale();
--[[ 	* Beast
		* Dragonkin
		* Demon
		* Elemental
		* Giant
		* Undead
		* Humanoid
		* Critter
		* Mechanical
		* Not specified
		* Totem
		* Non-combat Pet
		* Gas Cloud ]]
	if creatureType ~= nil then
		if locale ~= "enUS" then
			if creatureType == "Wildtier" or creatureType == "Bestia" or creatureType == "Bête" or creatureType == "Fera" or creatureType == "Животное" or creatureType == "야수" or creatureType == "野兽" or creatureType == "野獸" then
				creatureType = "Beast";
			end
			--Critter
			if creatureType == "Dämon" or creatureType == "Demonio" or creatureType == "Démon" or creatureType == "Demone" or creatureType == "Demônio" or creatureType == "Демон" or creatureType == "악마" or creatureType == "恶魔" or creatureType == "惡魔" then
				creatureType = "Demon";
			end
			--Dragonkin
			if creatureType == "Elementar" or creatureType == "Élémentaire" or creatureType == "Elementale" or creatureType == "Элементаль" or creatureType == "정령" or creatureType == "元素生物" or creatureType == "元素生物" then
				creatureType = "Elemental";
			end
			--Giant
			--Humanoid
			if creatureType == "Mechanisch" or creatureType == "Mecánico" or creatureType == "Machine" or creatureType == "Meccanic" or creatureType == "Mecânic" or creatureType == "Механизм" or creatureType == "기계" or creatureType == "机械" or creatureType == "機械" then
				creatureType = "Mechanical";
			end
			if creatureType == "Untoter" or creatureType == "No-muerto" or creatureType == "Mort-vivant" or creatureType == "Non Morto" or creatureType == "Renegado" or creatureType == "Нежить" or creatureType == "언데드" or creatureType == "亡灵" or creatureType == "不死族" then
				creatureType = "Undead";
			end
		end

		if creatureCheck == creatureType then
			return true;
		end
	end
	return false;
end

function ConROC:ExtractTooltip(spell, pattern)
	local _pattern = gsub(pattern, "%%s", "([%%d%.,]+)");

	if not TDSpellTooltip then
		CreateFrame('GameTooltip', 'TDSpellTooltip', UIParent, 'GameTooltipTemplate');
		TDSpellTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end
	TDSpellTooltip:SetSpellByID(spell);

	for i = 2, 4 do
		local line = _G['TDSpellTooltipTextLeft' .. i];
		local text = line:GetText();

		if text then
			local cost = strmatch(text, _pattern);
			if cost then
				cost = cost and tonumber((gsub(cost, "%D", "")));
				return cost;
			end
		end
	end

	return 0;
end

function ConROC:GlobalCooldown()
	local _, duration, enabled = GetSpellCooldown(29515);
		return duration;
end

function ConROC:Cooldown(spellid, timeShift)
	local start, maxCooldown, enabled = GetSpellCooldown(spellid);
	if enabled and maxCooldown == 0 and start == 0 then
		return 0, maxCooldown;
	elseif enabled then
		return (maxCooldown - (GetTime() - start) - (timeShift or 0)), maxCooldown;
	else
		return 100000, maxCooldown;
	end;
end

function ConROC:ItemCooldown(itemid, timeShift)
	local start, maxCooldown, enabled = GetItemCooldown(itemid);
	if enabled and maxCooldown == 0 and start == 0 then
		return 0, maxCooldown;
	elseif enabled then
		return (maxCooldown - (GetTime() - start) - (timeShift or 0)), maxCooldown;
	else
		return 100000, maxCooldown;
	end;
end

--[[function ConROC:Interrupt()
	local targetName = UnitName("target") -- Get the name of the target
    if not targetName then
        return false -- No target or invalid target
    end

    local spellName, _, _, _, _, _, castEndTime, spellNotInterruptible, spellId = UnitCastingInfo("target")
    local channeledSpellName, _, _, _, _, _, channeledEndTime, _, _, channeledSpellId = UnitChannelInfo("target")

    --print("spellName", spellName, spellId, spellNotInterruptible)
    if spellName then
        local isInterruptible = IsSpellInterruptible(spellId) -- Check if the spell is interruptible
        return isInterruptible
    elseif channeledSpellName then
        local isInterruptible = IsSpellInterruptible(channeledSpellId) -- Check if the channeled spell is interruptible
        return isInterruptible
    end

    return false
end]]
function ConROC:Interrupt()				--Classic Broke
	if UnitCanAttack ('player', 'target') then
		local tarchan, _, _, _, _, _, cnotInterruptible = UnitChannelInfo("target");
		local tarcast, _, _, _, _, _, _, notInterruptible = UnitCastingInfo("target");
		
		if tarcast and not notInterruptible then
			return true;
		elseif tarchan and not cnotInterruptible then
			return true;
		else
			return false;
		end
	end
end

function ConROC:CallPet()
	local petout = IsPetActive();
	local mounted = IsMounted();
	local summoned = true;
		if not petout and not mounted then
			summoned = false;
		end
	return summoned;
end
	
function ConROC:PetAssist()
	local mounted = IsMounted();
	local affectingCombat = IsPetAttackActive();
	local attackstate = true;
	local passive = false;
		for i = 1, 24 do
			local name, _, _, isActive = GetPetActionInfo(i)
			if name == 'PET_MODE_PASSIVE' and isActive then
				passive = true;
			end
		end
		if not affectingCombat and passive and not mounted then
			attackstate = false;
		end
	return attackstate;
end

function ConROC:Equipped(itemType, slotName)
	local slotID = GetInventorySlotInfo(slotName);
	local itemID = GetInventoryItemID("player", slotID);
	if itemID ~= nil then
		local wpn, subType, _, _, _, _, typeID, subclassID = select(6,GetItemInfo(itemID));
		
		if itemType == "wpn" then
			--print("wpn", wpn, "typeID", typeID)
			if typeID == 2 then
				return true;
			end
			return false;
		end
		if type(itemType) == "table" then
			for _, id in ipairs(itemType) do
				if id == subclassID then
					return true
				end
			end
		else
			if itemType == subType or itemType == subclassID or itemType == wpn then
				return true;
			end
		end
		return false;
	end
end
--[[function ConROC:TierPieces(tier, bonus) --function to check for Tire Piece bonuses
  local pieceCount = 0
  for i = 1, 19 do
        local item = GetInventoryItemID("player", i)
        if item  then
            local itemName, itemLink, _, _, _, _, _, _, _, _, _, _, _, _, _, itemDesc = GetItemInfo(item)
            if itemDesc and string.find(itemName, tier) then
                pieceCount = pieceCount + 1
            
            end
        end
    end
  if pieceCount >= 2 then
    return true, pieceCount, tier
  else 
    return false
  end
end--]]

function ConROC:IsGlyphActive(glyphSpellID)
    for i = 1, 6 do
        local enabled, _, spellID = GetGlyphSocketInfo(i)
        if enabled and spellID == glyphSpellID then
            return true
        end
    end
    return false
end

function ConROC:CheckBox(checkBox)
	local boxChecked = false;
		if checkBox ~= nil then
			boxChecked = checkBox:GetChecked();
		end
	return boxChecked;
end

function ConROC:FormatTime(left)
	local seconds = left >= 0        and math.floor((left % 60)    / 1   ) or 0;
	local minutes = left >= 60       and math.floor((left % 3600)  / 60  ) or 0;
	local hours   = left >= 3600     and math.floor((left % 86400) / 3600) or 0;
	local days    = left >= 86400    and math.floor((left % 31536000) / 86400) or 0;
	local years   = left >= 31536000 and math.floor( left / 31536000) or 0;

	if years > 0 then
		return string.format("%d [Y] %d [D] %d:%d:%d [H]", years, days, hours, minutes, seconds);
	elseif days > 0 then
		return string.format("%d [D] %d:%d:%d [H]", days, hours, minutes, seconds);
	elseif hours > 0 then
		return string.format("%d:%d:%d [H]", hours, minutes, seconds);
	elseif minutes > 0 then
		return string.format("%d:%d [M]", minutes, seconds);
	else
		return string.format("%d [S]", seconds);
	end
end

function ConROC:Warnings(_Message, _Condition)
	if self.WarningFlags[_Message] == nil then
		self.WarningFlags[_Message] = 0;
	end
	if _Condition then
		self.WarningFlags[_Message] = self.WarningFlags[_Message] + 1;
		if self.WarningFlags[_Message] == 1 then
		--print("_Message", _Message);
			UIErrorsFrame:AddExternalErrorMessage(_Message);
		elseif self.WarningFlags[_Message] == 15 then
			self.WarningFlags[_Message] = 0;
		end
	else
		self.WarningFlags[_Message] = 0;
	end
end

function ConROC:DisplayErrorMessage(message, displayTime, fadeInTime, fadeOutTime, holdTime)
  UIErrorsFrame:AddExternalErrorMessage(message, displayTime, fadeInTime, fadeOutTime, holdTime)
end
