local AceGUI = LibStub('AceGUI-3.0');
local lsm = LibStub('AceGUISharedMediaWidgets-1.0');
local media = LibStub('LibSharedMedia-3.0');
local ADDON_NAME, ADDON_TABLE = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version");
local addoninfo = 'Main Version: ' .. version;

BINDING_HEADER_ConROC = "ConROC Hotkeys"
BINDING_NAME_CONROCUNLOCK = "Lock/Unlock ConROC"

ConROC = LibStub('AceAddon-3.0'):NewAddon('ConROC', 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0');

ConROC.rc = LibStub("LibRangeCheck-3.0");
ConROC.Textures = {
	['Ping'] = 'Interface\\Cooldown\\ping4',
	['Star'] = 'Interface\\Cooldown\\star4',
	['Starburst'] = 'Interface\\Cooldown\\starburst',
	['Shield'] = 'Interface\\AddOns\\ConROC\\images\\shield2',
	['Skull'] = 'Interface\\AddOns\\ConROC\\images\\skull',
	['Caster'] = 'Interface\\AddOns\\ConROC\\images\\role-caster',
	['Caster_disabled'] = 'Interface\\AddOns\\ConROC\\images\\role-caster_disabled',
	['PvP'] = 'Interface\\AddOns\\ConROC\\images\\role-pvp',
	['PvP_disabled'] = 'Interface\\AddOns\\ConROC\\images\\role-pvp_disabled',
	['Melee'] = 'Interface\\AddOns\\ConROC\\images\\role-melee',
	['Melee_disabled'] = 'Interface\\AddOns\\ConROC\\images\\role-melee_disabled',
	['Tank'] = 'Interface\\AddOns\\ConROC\\images\\role-tank',
	['Tank_disabled'] = 'Interface\\AddOns\\ConROC\\images\\role-tank_disabled',
	['Healer'] = 'Interface\\AddOns\\ConROC\\images\\role-healer',
	['Healer_disabled'] = 'Interface\\AddOns\\ConROC\\images\\role-healer_disabled',
	['Ranged'] = 'Interface\\AddOns\\ConROC\\images\\role-range',
	['Ranged_disabled'] = 'Interface\\AddOns\\ConROC\\images\\role-range_disabled',
};
ConROC.FinalTexture = nil;

ConROC.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

ConROC.Seasons ={
	IsWotlk = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC,
	IsEra = ConROC.IsClassic and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason() == Enum.SeasonID.Fresh,
	IsSoD = ConROC.IsClassic and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfDiscovery,
	IsHardcore = C_GameRules and C_GameRules.IsHardcoreActive(),
}

ConROC.Colors = {
	Info = '|cFF1394CC',
	Error = '|cFFF0563D',
	Success = '|cFFBCCF02',
	[1] = '|cFFC79C6E',
	[2] = '|cFFF58CBA',
	[3] = '|cFFABD473',
	[4] = '|cFFFFF569',
	[5] = '|cFFFFFFFF',
	[6] = '|cFFC41F3B',
	[7] = '|cFF0070DE',
	[8] = '|cFF69CCF0',
	[9] = '|cFF9482C9',
	[10] = '|cFF00FF96',
	[11] = '|cFFFF7D0A',
	[12] = '|cFFA330C9',
}

ConROC.Classes = {
	[1] = 'Warrior',
	[2] = 'Paladin',
	[3] = 'Hunter',
	[4] = 'Rogue',
	[5] = 'Priest',
	[6] = 'DeathKnight',
	[7] = 'Shaman',
	[8] = 'Mage',
	[9] = 'Warlock',
	[10] = 'Monk',
	[11] = 'Druid',
	[12] = 'DemonHunter',
}

local defaultOptions = {
	profile = {
		disabledInfo = false,
		enableWindow = true,
		combatWindow = false,
		enableWindowCooldown = true,
		enableNextWindow = true,
		enableWindowSpellName = true,
		enableWindowKeybinds = true,
		_Reverse_Direction = false,
		_Reverse_Direction1 = "RIGHT",
		_Reverse_Direction2 = "LEFT",
		_Reverse_Direction3 = -3,
		_Reverse_Direction4 = 5,
		enableDefenseWindow = true,
		enableInterruptWindow = true,
		enablePurgeWindow = true,
		_Unlock_ConROC = true,
		transparencyWindow = 0.9,
		windowIconSize = 50,
		flashIconSize = 50,
		_Hide_Spellmenu = false,
		toggleButtonSize = 1,
		interval = 0.20,
		overlayScale = 1,
		damageOverlayAlpha = true,
		defenseOverlayAlpha = true,
		notifierOverlayAlpha = true,
		damageOverlayColor = {r = 0.8,g = 0.8,b = 0.8,a = 1},
		cooldownOverlayColor = {r = 1,g = 0.6,b = 0,a = 1},
		_Defense_Overlay_Color = {r = 0,g = 0.7,b = 1,a = 1},
		_Interrupt_Overlay_Color = {r = 1,g = 1,b = 1,a = 1},
		_Purge_Overlay_Color = {r = 0.6,g = 0,b = .9,a = 1},
		raidbuffsOverlayColor = {r = 0,g = 0.6,b = 0, a = 1},
		tauntOverlayColor = {r = 0.8,g = 0,b = 0, a = 1},
		movementOverlayColor = {r = 0.2,g = 0.9,b = 0.2, a = 1},
		nameplateSelectedAlpha = tonumber(GetCVarDefault("nameplateSelectedAlpha")),
		nameplateNotSelectedAlpha = tonumber(GetCVarDefault("nameplateNotSelectedAlpha")),
		nameplatesMinAlpha = tonumber(GetCVarDefault("nameplateMinAlpha")),
		nameplatesMaxAlpha = tonumber(GetCVarDefault("nameplateMaxAlpha")),
	}
}	

local orientations = {
		"Vertical",
		"Horizontal",
}
ConROC.SpellsChanged = false;
--[[
function ConROC:resetClass(classname)
	local addonName = "ConROC_" .. classname
	local variableName = "ConROC" .. classname .. "Spells"
	if IsAddOnLoaded(addonName) then
	    -- Reset the saved variable within the addon
	    if _G[variableName] then
	       _G[variableName] = nil
	       _G[variableName] = {}  -- Optional: Set it to an empty table if necessary
	        print("Saved variable " .. variableName .. " for " .. classname .. " has been reset.")
	    else
	        print("Error: " .. variableName .. " not found in " .. addonName .. ".")
	    end
	else
	    print("Error: " .. addonName .. " addon not found.")
	end
end]]

function ConROC:resetClass(classname)
    local addonName = "ConROC_" .. classname
	local variableName = "ConROC" .. classname .. "Spells"
	if IsAddOnLoaded(addonName) then
	    -- Reset the saved variable within the addon
	    if _G[variableName] then
	       _G[variableName] = nil
    		print("Saved Class Settings for " .. classname .. " has been reset.")
		else
	        print("Error: " .. variableName .. " not found in " .. addonName .. ".")
	    end
	else
	    print("Error: " .. addonName .. " addon not found.")
	end
end

local _, _, classIdv = UnitClass('player');
local cversion = GetAddOnMetadata('ConROC_' .. ConROC.Classes[classIdv], 'Version');
local classinfo = " ";
	if cversion ~= nil then
		classinfo = ConROC.Classes[classIdv] .. ': Ver ' .. cversion;
	end
--print("ConROC.Classes[classIdv]",ConROC.Classes[classIdv])
local options = {
	type = 'group',
	name = '-= |cffFFFFFFConROC  (Conflict Rotation Optimizer Classic)|r =-',
	inline = false,
	args = {
		authorPull = {
			order = 1,
			type = "description",
			width = "full",
			name = "Author: Vae",
		},
		versionPull = {
			order = 2,
			type = "description",
			width = "full",
			name = addoninfo,
		},
		cversionPull = {
			order = 3,
			type = "description",
			width = "full",
			name = classinfo,
		},
		resetClassButton = {
			name = 'Reset '.. ConROC.Classes[classIdv] .. ' Class variables',
			desc = 'Reloads UI after reseting the '.. ConROC.Classes[classIdv] .. ' settings.',
			type = 'execute',
			width = 'full',
			order = 3.5,
			func = function(info)
				ConROC:resetClass(ConROC.Classes[classIdv]);
				ReloadUI();
			end
		},
		spacer4 = {
			order = 4,
			type = "description",
			width = "full",
			name = "\n\n",
		},
		interval = {
			name = 'Interval in seconds',
			desc = 'Sets how frequent rotation updates will be. Low value will result in fps drops.',
			type = 'range',
			order = 5,
			hidden = true,
			min = 0.01,
			max = 2,
			set = function(info,val) ConROC.db.profile.interval = val end,
			get = function(info) return ConROC.db.profile.interval end
		},
		disabledInfo = {
			name = 'Disable info messages',
			desc = 'Enables / disables info messages, if you have issues with addon, make sure to deselect this.',
			type = 'toggle',
			width = 'double',
			order = 6,
			set = function(info, val)
				ConROC.db.profile.disabledInfo = val;
			end,
			get = function(info) return ConROC.db.profile.disabledInfo end
		},
		reloadButton = {
			name = 'ReloadUI',
			desc = 'Reloads UI after making changes that need it.',
			type = 'execute',
			width = 'normal',
			order = 7,
			func = function(info)
				ReloadUI();
			end
		},
		_Unlock_ConROC = {
			name = 'Unlock ConROC',
			desc = 'Make display windows movable.',
			type = 'toggle',
			width = 'normal',
			order = 8,
			set = function(info, val)
				ConROC.db.profile._Unlock_ConROC = val;
				ConROCWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
				ConROCDefenseWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
				ConROCInterruptWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
				ConROCPurgeWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);

				if val == true and ConROC.db.profile.enableInterruptWindow == true then
					ConROCInterruptWindow:Show();
				else
					ConROCInterruptWindow:Hide();
				end
				if val == true and ConROC.db.profile.enablePurgeWindow == true then
					ConROCPurgeWindow:Show();
				else
					ConROCPurgeWindow:Hide();
				end

				if ConROCSpellmenuMover ~= nil then
					ConROCSpellmenuMover:EnableMouse(ConROC.db.profile._Unlock_ConROC);
					if val == true then
						ConROCSpellmenuMover:Show();
					else
						ConROCSpellmenuMover:Hide();
					end
				end
				if ConROCToggleMover ~= nil and ConROCButtonFrame:IsVisible() then
					ConROCToggleMover:EnableMouse(ConROC.db.profile._Unlock_ConROC);
					if val == true then
						ConROCToggleMover:Show();
					else
						ConROCToggleMover:Hide();
					end
				end
			end,
			get = function(info) return ConROC.db.profile._Unlock_ConROC end
		},
		spacer10 = {
			order = 10,
			type = "description",
			width = "full",
			name = "\n\n",
		},
		overlaySettings = {
			type = 'header',
			name = 'Overlay Settings',
			order = 11,
		},
		damageOverlayAlpha = {
			name = 'Show Damage Overlay',
			desc = 'Turn damage overlay on and off.',
			type = 'toggle',
			width = 'default',
			order = 12,
			set = function(info, val)
				ConROC.db.profile.damageOverlayAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.damageOverlayAlpha end
		},
		damageOverlayColor = {
			name = 'Damage Color',
			desc = 'Change damage overlay color.',
			type = 'color',
			hasAlpha = true,
			width = 'default',
			order = 13,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile.damageOverlayColor;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile.damageOverlayColor;
				return t.r, t.g, t.b, t.a;
			end
		},
		cooldownOverlayColor = {
			name = 'Cooldown Color',
			desc = 'Change cooldown burst overlay color.',
			type = 'color',
			hasAlpha = true,
			order = 14,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile.cooldownOverlayColor;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile.cooldownOverlayColor;
				return t.r, t.g, t.b, t.a;
			end
		},
		defenseOverlayAlpha = {
			name = 'Show Defense Overlay',
			desc = 'Turn defense overlay on and off.',
			type = 'toggle',
			width = 'default',
			order = 15,
			set = function(info, val)
				ConROC.db.profile.defenseOverlayAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.defenseOverlayAlpha end
		},
		_Defense_Overlay_Color = {
			name = 'Defense Color',
			desc = 'Change defense overlay color.',
			type = 'color',
			hasAlpha = true,
			order = 16,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile._Defense_Overlay_Color;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile._Defense_Overlay_Color;
				return t.r, t.g, t.b, t.a;
			end
		},
		tauntOverlayColor = {
			name = 'Taunt Color',
			desc = 'Change taunt overlay color.',
			type = 'color',
			hasAlpha = true,
			order = 17,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile.tauntOverlayColor;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile.tauntOverlayColor;
				return t.r, t.g, t.b, t.a;
			end
		},
		notifierOverlayAlpha = {
			name = 'Show Notifier Overlay',
			desc = 'Turn interrupt, raid buff and purge overlays on and off.',
			type = 'toggle',
			width = 'default',
			order = 18,
			set = function(info, val)
				ConROC.db.profile.notifierOverlayAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.notifierOverlayAlpha end
		},
		_Purge_Overlay_Color = {
			name = 'Purgable Color',
			desc = 'Change purge overlay color.',
			type = 'color',
			hasAlpha = true,
			order = 20,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile._Purge_Overlay_Color;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile._Purge_Overlay_Color;
				return t.r, t.g, t.b, t.a;
			end
		},
		spacer21 = {
			order = 21,
			type = "description",
			width = "normal",
			name = "\n\n",
		},
		raidbuffsOverlayColor = {
			name = 'Raid Buffs Color',
			desc = 'Change raid buffs overlay color.',
			type = 'color',
			width = "default",
			hasAlpha = true,
			order = 22,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile.raidbuffsOverlayColor;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile.raidbuffsOverlayColor;
				return t.r, t.g, t.b, t.a;
			end
		},
		movementOverlayColor = {
			name = 'Movement Color',
			desc = 'Change movement overlay color.',
			type = 'color',
			width = "default",
			hasAlpha = true,
			order = 23,
			set = function(info, r, g, b, a)
				local t = ConROC.db.profile.movementOverlayColor;
				t.r, t.g, t.b, t.a = r, g, b, a;
			end,
			get = function(info)
				local t = ConROC.db.profile.movementOverlayColor;
				return t.r, t.g, t.b, t.a;
			end
		},
		overlayScale = {
			name = 'Change Overlay Size',
			desc = 'Sets the scale of the Overlays.',
			type = 'range',
			width = 'normal',
			order = 24,
			min = .5,
			max = 1.5,
			step = .1,
			set = function(info,val)
			ConROC.db.profile.overlayScale = val
			end,
			get = function(info) return ConROC.db.profile.overlayScale end
		},
		spacer30 = {
			order = 30,
			type = "description",
			width = "full",
			name = "\n\n",
		},
		toggleButtonSettings = {
			type = 'header',
			name = 'Toggle Button Settings',
			order = 31,
		},
		toggleButtonSize = {
			name = 'Toggle Button Size',
			desc = 'Sets the scale of the toggle buttons.',
			type = 'range',
			width = 'default',
			order = 35,
			min = 1,
			max = 2,
			step = .1,
			set = function(info,val)
			ConROC.db.profile.toggleButtonSize = val
			ConROCButtonFrame:SetScale(ConROC.db.profile.toggleButtonSize)
			end,
			get = function(info) return ConROC.db.profile.toggleButtonSize end
		},
		spacer36 = {
			order = 36,
			type = "description",
			width = "normal",
			name = "\n\n",
		},
		_Hide_Spellmenu = {
			name = 'Hide Spellmenu',
			desc = 'Hides Spellmenu from view, but they are still operational.',
			type = 'toggle',
			width = 'default',
			order = 37,
			set = function(info, val)
				ConROC.db.profile._Hide_Spellmenu = val;
				if val == true then
					ConROCSpellmenuFrame:SetAlpha(0);
				else
					ConROCSpellmenuFrame:SetAlpha(1);
				end
			end,
			get = function(info) return ConROC.db.profile._Hide_Spellmenu end
		},
		spacer40 = {
			order = 40,
			type = "description",
			width = "full",
			name = "\n\n",
		},
		displayWindowSettings = {
			type = 'header',
			name = 'Display Window Settings',
			order = 41,
		},
		enableWindow = {
			name = 'Enable Display Window',
			desc = 'Show movable display window.',
			type = 'toggle',
			width = 'default',
			order = 42,
			set = function(info, val)
				ConROC.db.profile.enableWindow = val;
				if val == true and not ConROC:HealSpec() then
					ConROCWindow:Show();
				else
					ConROCWindow:Hide();
				end
			end,
			get = function(info) return ConROC.db.profile.enableWindow end
		},
		combatWindow = {
			name = 'Only Display with Hostile',
			desc = 'Show display window only when hostile target selected.',
			type = 'toggle',
			width = 'default',
			order = 43,
			set = function(info, val)
				ConROC.db.profile.combatWindow = val;
				if val == true then
					ConROCWindow:Hide();
					ConROCDefenseWindow:Hide();
				else
					ConROCWindow:Show();
					ConROCDefenseWindow:Show();
				end
			end,
			get = function(info) return ConROC.db.profile.combatWindow end
		},
		enableWindowCooldown = {
			name = 'Enable Cooldown Swirl',
			desc = 'Show cooldown swirl on Display Windows. REQUIRES RELOAD',
			type = 'toggle',
			width = 'normal',
			order = 44,
			set = function(info, val)
				ConROC.db.profile.enableWindowCooldown = val;
			end,
			get = function(info) return ConROC.db.profile.enableWindowCooldown end
		},
		enableNextWindow = {
			name = 'Enable Next Windows',
			desc = 'Show movable future spell windowss.',
			type = 'toggle',
			width = 'default',
			order = 45,
			set = function(info, val)
				ConROC.db.profile.enableNextWindow = val;
				if val == true and not ConROC:HealSpec() then
					ConROCWindow2:Show();
					ConROCWindow3:Show();
				else
					ConROCWindow2:Hide();
					ConROCWindow3:Hide();
				end
			end,
			get = function(info) return ConROC.db.profile.enableNextWindow end
		},
		enableWindowSpellName = {
			name = 'Show Spellname',
			desc = 'Show spellname above Display Windows. REQUIRES RELOAD',
			type = 'toggle',
			width = 'normal',
			order = 46,
			set = function(info, val)
				ConROC.db.profile.enableWindowSpellName = val;
				if val == true then
					ConROCWindow.font:Show();
					ConROCDefenseWindow.font:Show();
				else
					ConROCWindow.font:Hide();
					ConROCDefenseWindow.font:Hide();
				end
			end,
			get = function(info) return ConROC.db.profile.enableWindowSpellName end
		},
		enableWindowKeybinds = {
			name = 'Show Keybind',
			desc = 'Show keybinds below Display Windows. REQUIRES RELOAD',
			type = 'toggle',
			width = 'normal',
			order = 47,
			set = function(info, val)
				ConROC.db.profile.enableWindowKeybinds = val;
				if val == true then
					ConROCWindow.fontkey:Show();
					ConROCWindow2.fontkey:Show();
					ConROCWindow3.fontkey:Show();
					ConROCDefenseWindow.fontkey:Show();
				else
					ConROCWindow.fontkey:Hide();
					ConROCWindow2.fontkey:Hide();
					ConROCWindow3.fontkey:Hide();
					ConROCDefenseWindow.fontkey:Hide();
				end
			end,
			get = function(info) return ConROC.db.profile.enableWindowKeybinds end
		},
		_Reverse_Direction = {
			name = 'Reverse Direction',
			desc = 'Reverse the direction of the next spell frames.',
			type = 'toggle',
			width = 'normal',
			order = 48,
			set = function(info, val)
				ConROC.db.profile._Reverse_Direction = val;
				if val == true then
					ConROC.db.profile._Reverse_Direction1 = "LEFT";
					ConROC.db.profile._Reverse_Direction2 = "RIGHT";
					ConROC.db.profile._Reverse_Direction3 = 3;
					ConROC.db.profile._Reverse_Direction4 = -5;
					ConROCWindow2:ClearAllPoints();
					ConROCWindow3:ClearAllPoints();
					ConROCInterruptWindow:ClearAllPoints();
					ConROCPurgeWindow:ClearAllPoints();
					ConROCWindow2:SetPoint("BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROCWindow, "BOTTOM" .. ConROC.db.profile._Reverse_Direction2, ConROC.db.profile._Reverse_Direction3, 0);
					ConROCWindow3:SetPoint("BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROCWindow2, "BOTTOM" .. ConROC.db.profile._Reverse_Direction2, ConROC.db.profile._Reverse_Direction3, 0);
					ConROCInterruptWindow:SetPoint(ConROC.db.profile._Reverse_Direction2, "ConROCWindow", "TOP" .. ConROC.db.profile._Reverse_Direction1, ConROC.db.profile._Reverse_Direction4, 0);
					ConROCPurgeWindow:SetPoint(ConROC.db.profile._Reverse_Direction2, "ConROCWindow", "BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROC.db.profile._Reverse_Direction4, 0);
				else
					ConROC.db.profile._Reverse_Direction1 = "RIGHT";
					ConROC.db.profile._Reverse_Direction2 = "LEFT";
					ConROC.db.profile._Reverse_Direction3 = -3;
					ConROC.db.profile._Reverse_Direction4 = 5;
					ConROCWindow2:ClearAllPoints();
					ConROCWindow3:ClearAllPoints();
					ConROCInterruptWindow:ClearAllPoints();
					ConROCPurgeWindow:ClearAllPoints();
					ConROCWindow2:SetPoint("BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROCWindow, "BOTTOM" .. ConROC.db.profile._Reverse_Direction2, ConROC.db.profile._Reverse_Direction3, 0);
					ConROCWindow3:SetPoint("BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROCWindow2, "BOTTOM" .. ConROC.db.profile._Reverse_Direction2, ConROC.db.profile._Reverse_Direction3, 0);
					ConROCInterruptWindow:SetPoint(ConROC.db.profile._Reverse_Direction2, "ConROCWindow", "TOP" .. ConROC.db.profile._Reverse_Direction1, ConROC.db.profile._Reverse_Direction4, 0);
					ConROCPurgeWindow:SetPoint(ConROC.db.profile._Reverse_Direction2, "ConROCWindow", "BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROC.db.profile._Reverse_Direction4, 0);
				end
			end,
			get = function(info) return ConROC.db.profile._Reverse_Direction end
		},
		spacer48 = {
			order = 48.5,
			type = "description",
			width = "double",
			name = "\n\n",
		},
		transparencyWindow = {
			name = 'Window Transparency',
			desc = 'Change transparency of your windows and texts. -REQUIRES RELOAD-',
			type = 'range',
			width = 'normal',
			order = 49,
			min = 0,
			max = 1,
			step = 0.01,
			set = function(info, val)
				ConROC.db.profile.transparencyWindow = val;
				ConROCWindow:SetAlpha(val);
				ConROCWindow2:SetAlpha(val);
				ConROCWindow3:SetAlpha(val);
				ConROCDefenseWindow:SetAlpha(val);
				ConROCInterruptWindow:SetAlpha(val);
				ConROCPurgeWindow:SetAlpha(val);
			end,
			get = function(info) return ConROC.db.profile.transparencyWindow end
		},
		windowIconSize = {
			name = 'Display windows Icon size.',
			desc = 'Sets the size of the icon in your display windows. REQUIRES RELOAD',
			type = 'range',
			width = 'normal',
			order = 50,
			min = 20,
			max = 100,
			step = 2,
			set = function(info, val)
				ConROC.db.profile.windowIconSize = val;
			end,
			get = function(info) return ConROC.db.profile.windowIconSize end
		},
		flashIconSize = {
			name = 'Flasher Icon size.',
			desc = 'Sets the size of the icon that flashes for Interrupts and Purges.',
			type = 'range',
			width = 'normal',
			order = 51,
			min = 20,
			max = 100,
			step = 2,
			set = function(info, val)
				ConROC.db.profile.flashIconSize = val;
				ConROCPurgeWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
			end,
			get = function(info) return ConROC.db.profile.flashIconSize end
		},
		enableDefenseWindow = {
			name = 'Enable Defense Window',
			desc = 'Show movable defense window.',
			type = 'toggle',
			width = 'default',
			order = 52,
			set = function(info, val)
				ConROC.db.profile.enableDefenseWindow = val;
				if val == true then
					ConROCDefenseWindow:Show();
				else
					ConROCDefenseWindow:Hide();
				end				
			end,
			get = function(info) return ConROC.db.profile.enableDefenseWindow end
		},
		enableInterruptWindow = {
			name = 'Enable Interrupt Icon',
			desc = 'Show movable interrupt icon.',
			type = 'toggle',
			width = 'default',
			order = 53,
			set = function(info, val)
				ConROC.db.profile.enableInterruptWindow = val;
				if val == true then
					ConROCInterruptWindow:Show();
				else
					ConROCInterruptWindow:Hide();
				end
			end,
			get = function(info) return ConROC.db.profile.enableInterruptWindow end
		},
		enablePurgeWindow = {
			name = 'Enable Purge Window',
			desc = 'Show movable interrupt window.',
			type = 'toggle',
			width = 'default',
			order = 54,
			set = function(info, val)
				ConROC.db.profile.enablePurgeWindow = val;			
				if val == true and ConROC.db.profile._Unlock_ConROC == true then
					ConROCPurgeWindow:Show();
				else
					ConROCPurgeWindow:Hide();
				end	
			end,
			get = function(info) return ConROC.db.profile.enablePurgeWindow end
		},
		spacer53 = {
			order = 55,
			type = "description",
			width = "double",
			name = "\n\n",
		},
		nameplates = {
			type = 'header',
			name = 'Nameplate Settings',
			order = 60,
		},
		nameplateInfo = {
			order = 61,
			type = "description",
			--width = "double",
			name = "To check the number of mobs within range, nameplates must be enabled. If they are disabled when entering combat, ConROC will temporarily turn them on with the specified settings.\nREQUIRES RELOAD for changes to apply\n\n",
			fontSize = "medium",
		},
		nameplateSelectedAlpha = {
			name = 'Target Alpha',
			desc = 'The nameplate transparency of your target. REQUIRES RELOAD to update\nBlizzard default: 1',
			type = 'range',
			width = 'normal',
			order = 62,
			min = 0,
			max = 1,
			step = 0.1,
			set = function(info, val)
				ConROC.db.profile.nameplateSelectedAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.nameplateSelectedAlpha end
		},
		nameplateNotSelectedAlpha = {
			name = 'Not targeted Alpha',
			desc = 'The nameplate transparency of NOT your target. REQUIRES RELOAD to update\nBlizzard default: 0.5',
			type = 'range',
			width = 'normal',
			order = 63,
			min = 0,
			max = 1,
			step = 0.1,
			set = function(info, val)
				ConROC.db.profile.nameplateNotSelectedAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.nameplateNotSelectedAlpha end
		},
		--[[nameplatesMinAlpha = {
			name = 'Min Alpha',
			desc = 'Min transparency of nameplates for units that are not currently targeted.\nBlizzard default: 0.8',
			type = 'range',
			width = 'normal',
			order = 64,
			min = 0,
			max = 1,
			step = 0.1,
			set = function(info, val)
				ConROC.db.profile.nameplatesMinAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.nameplatesMinAlpha end
		},
		nameplatesMaxAlpha = {
			name = 'Max Alpha',
			desc = 'Max transparency of nameplates for units that are not currently targeted.\nBlizzard default: 1',
			type = 'range',
			width = 'normal',
			order = 65,
			min = 0,
			max = 1,
			step = 0.1,
			set = function(info, val)
				ConROC.db.profile.nameplatesMaxAlpha = val;
			end,
			get = function(info) return ConROC.db.profile.nameplatesMaxAlpha end
		},]]
		spacer64 = {
			order = 66,
			type = "description",
			width = "double",
			name = "\n\n",
		},
		resetHeadline = {
			type = 'header',
			name = 'Reset Settings',
			order = 70,
		},
		resetExtraWindows = {
			name = 'Reset Positions',
			desc = ('Windows go back to default spots.'),
			type = 'execute',
			width = 'default',
			order = 71,
			func = function(info)
				ConROCWindow:SetPoint("CENTER", -200, 100);
				ConROCDefenseWindow:SetPoint("CENTER", -280, -50);
				ConROCInterruptWindow:SetPoint("LEFT", "ConROCWindow", "TOPRIGHT", 5, 0);
				ConROCPurgeWindow:SetPoint("LEFT", "ConROCWindow", "BOTTOMRIGHT", 5, 0);
			end
		},
		spacer72 = {
			order = 72,
			type = "description",
			width = "default",
			name = "\n\n",
		},
		resetButton = {
			name = 'Reset Settings',
			desc = 'Resets options back to default. RELOAD REQUIRED',
			type = 'execute',
			width = 'default',
			order = 73,
			confirm = true,
			func = function(info)
				ConROC.db:ResetProfile();
				ConROCWindow:SetPoint("CENTER", -200, 100);
				ConROCDefenseWindow:SetPoint("CENTER", -280, -50);
				ConROCInterruptWindow:SetPoint("LEFT", "ConROCWindow", "TOPRIGHT", 5, 0);
				ConROCPurgeWindow:SetPoint("LEFT", "ConROCWindow", "BOTTOMRIGHT", 5, 0);
				ReloadUI();
			end
		},
		spacer80 = {
			order = 80,
			type = "description",
			width = "double",
			name = "\n\n",
		},
	},
}

function ConROC:GetTexture()
	if self.db.profile.customTexture ~= '' and self.db.profile.customTexture ~= nil then
		self.FinalTexture = self.db.profile.customTexture;
		return self.FinalTexture;
	end

	self.FinalTexture = self.Textures[self.db.profile.texture];
	if self.FinalTexture == '' or self.FinalTexture == nil then
		self.FinalTexture = 'Interface\\Cooldown\\ping4';
	end

	return self.FinalTexture;
end

function ConROC:OnInitialize()
	LibStub('AceConfig-3.0'):RegisterOptionsTable('Conflict Rotation Optimizer Classic Era', options, {'conroc'});
	self.db = LibStub('AceDB-3.0'):New('ConROCPreferences', defaultOptions);
	self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('Conflict Rotation Optimizer Classic Era', 'ConROC');
	self:DisplayToggleFrame();
	self:DisplayWindowFrame();
	self:DefenseWindowFrame();
	self:InterruptWindowFrame();
	self:PurgeWindowFrame();
	self:SpellmenuFrame();

	ConROCToggleMover:Hide();
	ConROCButtonFrame:Hide();

--[[[1] = 'Warrior',
	[2] = 'Paladin',
	[3] = 'Hunter',
	[4] = 'Rogue',
	[5] = 'Priest',
	[6] = 'DeathKnight',
	[7] = 'Shaman',
	[8] = 'Mage',
	[9] = 'Warlock',
	[10] = 'Monk',
	[11] = 'Druid',
	[12] = 'DemonHunter',]]

end

ConROC.DefaultPrint = ConROC.Print;
function ConROC:Print(...)
	if self.db.profile.disabledInfo then
		return;
	end
	ConROC:DefaultPrint(...);
end

function ConROC:EnableRotation()
	if self.NextSpell == nil or self.rotationEnabled then
		self:Print(self.Colors.Error .. 'Failed to enable addon!');
		return;
	end

	self:Fetch();

	if self.ModuleOnEnable then
		self.ModuleOnEnable();
	end

	self:EnableRotationTimer();
	self.rotationEnabled = true;
end

function ConROC:EnableDefense()
	if self.NextDef == nil or self.defenseEnabled then
		self:Print(self.Colors.Error .. 'Failed to enable defense module!');
		return;
	end

	self:FetchDef();

	if self.ModuleOnEnable then
		self.ModuleOnEnable();
	end

	self:EnableDefenseTimer();
	self.defenseEnabled = true;
end

function ConROC:EnableRotationTimer()
	self.RotationTimer = self:ScheduleRepeatingTimer('InvokeNextSpell', self.db.profile.interval);
end

function ConROC:EnableDefenseTimer()
	self.DefenseTimer = self:ScheduleRepeatingTimer('InvokeNextDef', self.db.profile.interval);
end

function ConROC:DisableRotation()
	if not self.rotationEnabled then
		return;
	end

	self:DisableRotationTimer();

	self:DestroyDamageOverlays();
	self:DestroyInterruptOverlays();
	self:DestroyCoolDownOverlays();
	self:DestroyPurgableOverlays();
	self:DestroyRaidBuffsOverlays();
	self:DestroyMovementOverlays();
	self:DestroyTauntOverlays();

	self.Spell = nil;
	self.rotationEnabled = false;
end

function ConROC:DisableDefense()
	if not self.defenseEnabled then
		return;
	end

	self:DisableDefenseTimer();

	self:DestroyDefenseOverlays();

	self.Def = nil;
	self.defenseEnabled = false;
end

function ConROC:DisableRotationTimer()
	if self.RotationTimer then
		self:CancelTimer(self.RotationTimer);
	end
end

function ConROC:DisableDefenseTimer()
	if self.DefenseTimer then
		self:CancelTimer(self.DefenseTimer);
	end
end

function ConROC:OnEnable()
	self:RegisterEvent('PLAYER_TARGET_CHANGED');
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED');
	self:RegisterEvent('PLAYER_REGEN_DISABLED');
	self:RegisterEvent('PLAYER_REGEN_ENABLED');
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	self:RegisterEvent('PLAYER_LEAVING_WORLD');
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM');
	self:RegisterEvent('ACTIONBAR_HIDEGRID');
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED');
	self:RegisterEvent('LEARNED_SPELL_IN_TAB');
	self:RegisterEvent('PLAYER_LEVEL_UP');
	self:RegisterEvent('ENGRAVING_MODE_CHANGED');
	self:RegisterEvent('LOADING_SCREEN_ENABLED');
	self:RegisterEvent('LOADING_SCREEN_DISABLED');

	self:RegisterEvent('CHARACTER_POINTS_CHANGED');
	self:RegisterEvent('UPDATE_MACROS');
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");

	self:RegisterEvent('PLAYER_CONTROL_LOST');
	self:RegisterEvent('PLAYER_CONTROL_GAINED');

	self:Print(self.Colors.Info .. 'Initialized');
end

function ConROC:ACTIONBAR_HIDEGRID()
	ConROC:ButtonFetch();

	self:DestroyInterruptOverlays();
	self:DestroyCoolDownOverlays();
	self:DestroyPurgableOverlays();
	self:DestroyRaidBuffsOverlays();
	self:DestroyMovementOverlays();
	self:DestroyTauntOverlays();
end

function ConROC:PLAYER_CONTROL_LOST()
--	self:Print(self.Colors.Success .. 'Lost Control!');
	self:DisableRotation();
	self:DisableDefense();
end

function ConROC:PLAYER_CONTROL_GAINED()
	self:DisableRotation();
	self:DisableDefense();
	self:EnableRotation();
	self:EnableDefense();
end

function ConROC:PLAYER_LEAVING_WORLD()
	--	self:Print(self.Colors.Success .. 'Lost Control!');
	self:DisableRotation();
	self:DisableDefense();
end

function ConROC:PLAYER_ENTERING_WORLD()
	C_Timer.After(1, function()
		self:UpdateButtonGlow();
		if not self.rotationEnabled then
			self:Print(self.Colors.Success .. 'Auto enable on login!');
			self:Print(self.Colors.Info .. 'Loading '.. self.Classes[classIdv] ..' module');
			self:LoadModule();
			self:EnableRotation();
			self:EnableDefense();
		end
		ConROCSpellmenuFrame:Show();
	end);
end

function ConROC:LOADING_SCREEN_ENABLED()
	--	self:Print(self.Colors.Success .. 'Lost Control!');
	self:DisableRotation();
	self:DisableDefense();
end

function ConROC:LOADING_SCREEN_DISABLED()
	C_Timer.After(1, function()
		self:UpdateButtonGlow();
		if not self.rotationEnabled then
			self:Print(self.Colors.Success .. 'Auto enable on login!');
			self:Print(self.Colors.Info .. 'Loading '.. self.Classes[classIdv] ..' module');
			self:LoadModule();
			self:EnableRotation();
			self:EnableDefense();
		end
		ConROCSpellmenuFrame:Show();
	end);
end

function ConROC:PLAYER_TARGET_CHANGED()
	if self.rotationEnabled then
		if (UnitIsFriend('player', 'target')) then
			return;
		else
			self:DestroyInterruptOverlays();
			self:DestroyPurgableOverlays();
			self:InvokeNextSpell();
			self:InvokeNextDef();
		end
	end

	if ConROC.db.profile.enableWindow and (ConROC.db.profile.combatWindow or ConROC:CheckBox(ConROC_SM_Role_Healer)) and ConROC:TarHostile() then
		ConROCWindow:Show();
	elseif ConROC.db.profile.enableWindow and not (ConROC.db.profile.combatWindow or ConROC:CheckBox(ConROC_SM_Role_Healer)) then
		ConROCWindow:Show();
	else
		ConROCWindow:Hide();
	end

	if ConROC.db.profile.enableDefenseWindow and ConROC.db.profile.combatWindow and ConROC:TarHostile() then
		ConROCDefenseWindow:Show();
	elseif ConROC.db.profile.enableDefenseWindow and not ConROC.db.profile.combatWindow then
		ConROCDefenseWindow:Show();
	else
		ConROCDefenseWindow:Hide();
	end
end

function ConROC:PLAYER_REGEN_DISABLED()
	C_Timer.After(1, function()
		self:UpdateButtonGlow();
		if not self.rotationEnabled then
			self:LoadModule();
			self:EnableRotation();
			self:EnableDefense();
		end
	end);
end

function ConROC:PLAYER_LEVEL_UP()
	ConROC:CR_SPELLS_LEARNED()
end

function ConROC:LEARNED_SPELL_IN_TAB()
	ConROC:CR_SPELLS_LEARNED()
end

function ConROC:ENGRAVING_MODE_CHANGED(self, enabled)
	if not enabled then
		ConROC:CR_SPELLS_LEARNED()
	end
end

function ConROC:PLAYER_EQUIPMENT_CHANGED(self, slotID, beingEquipped)
	local _, _, Class = UnitClass("player")

	if slotID == 18 then
		if Class == 5 or Class == 8 or Class == 9 then
			ConROC:wandEquipmentChanged(slotID);
		end
	end

	ConROC:CR_SPELLS_LEARNED()
end

function ConROC:CR_SPELLS_LEARNED()
	if self.rotationEnabled then
		ConROC:ButtonFetch();
		ConROC:SpellMenuUpdate();
		ConROC:closeSpellmenu();
	end;
end

function ConROC:ACTIONBAR_SLOT_CHANGED()
	self:UpdateButtonGlow();
	ConROC:ButtonFetch()
end

function ConROC:ButtonFetch()
	if self.rotationEnabled then
		if self.fetchTimer then
			self:CancelTimer(self.fetchTimer);
			self:CancelTimer(self.fetchdefTimer);
		end
		self.fetchTimer = self:ScheduleTimer('Fetch', 0.5);
		self.fetchdefTimer = self:ScheduleTimer('FetchDef', 0.5);
	end
end

ConROC.PLAYER_REGEN_ENABLED = ConROC.ButtonFetch;
--ConROC.ACTIONBAR_HIDEGRID = ConROC.ButtonFetch;
ConROC.ACTIONBAR_PAGE_CHANGED = ConROC.ButtonFetch;
ConROC.UPDATE_SHAPESHIFT_FORM = ConROC.ButtonFetch;
ConROC.CHARACTER_POINTS_CHANGED = ConROC.ButtonFetch;
ConROC.UPDATE_MACROS = ConROC.ButtonFetch;

function ConROC:InvokeNextSpell()
	local oldSkill = self.Spell;

	local timeShift, currentSpell, gcd = ConROC:EndCast();
	local iterate = self:NextSpell(timeShift, currentSpell, gcd);
	self.Spell = self.SuggestedSpells[1];

	--ConROC:UpdateRotation();
	--ConROC:UpdateButtonGlow();

	local spellName, spellTexture;

	-- Get info for the first suggested spell
	if self.Spell then
		local spellInfo1 = C_Spell.GetSpellInfo(self.Spell);
		spellName = spellInfo1 and spellInfo1.name;
		spellTexture = spellInfo1 and spellInfo1.originalIconID;
	end

	if self.Spell == 26008 then
		spellName = "Wait";
	end

	local spellTexture2;
	-- Get info for the second suggested spell, only if it exists
	if self.SuggestedSpells[2] then
		local spellInfo2 = C_Spell.GetSpellInfo(self.SuggestedSpells[2]);
		spellTexture2 = spellInfo2 and spellInfo2.originalIconID;
	end

	local spellTexture3;
	-- Get info for the third suggested spell, only if it exists
	if self.SuggestedSpells[3] then
		local spellInfo3 = C_Spell.GetSpellInfo(self.SuggestedSpells[3]);
		spellTexture3 = spellInfo3 and spellInfo3.originalIconID;
	end

	if (oldSkill ~= self.Spell or oldSkill == nil) and self.Spell ~= nil then
		self:GlowNextSpell(self.Spell);
		ConROCWindow.fontkey:SetText(ConROC:improvedGetBindingText(ConROC:FindKeybinding(self.Spell)));
		ConROCWindow2.fontkey:SetText(ConROC:improvedGetBindingText(ConROC:FindKeybinding(self.SuggestedSpells[2])));
		ConROCWindow3.fontkey:SetText(ConROC:improvedGetBindingText(ConROC:FindKeybinding(self.SuggestedSpells[3])));
		if spellName ~= nil then
			ConROCWindow.texture:SetTexture(spellTexture);
			ConROCWindow.font:SetText(spellName);
			ConROCWindow2.texture:SetTexture(spellTexture2);
			ConROCWindow3.texture:SetTexture(spellTexture3);
		else
			local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(self.Spell);
			local _, _, _, _, _, _, _, _, _, itemTexture2 = GetItemInfo(self.SuggestedSpells[2]);
			local _, _, _, _, _, _, _, _, _, itemTexture3 = GetItemInfo(self.SuggestedSpells[3]);
			ConROCWindow.texture:SetTexture(itemTexture);
			ConROCWindow.font:SetText(itemName);
			ConROCWindow2.texture:SetTexture(itemTexture2);
			ConROCWindow3.texture:SetTexture(itemTexture3);
		end
	end

	if self.Spell == nil and oldSkill ~= nil then
		self:GlowClear();
		ConROCWindow.texture:SetTexture('Interface\\AddOns\\ConROC\\images\\Bigskull');
		ConROCWindow.font:SetText(" ");
		ConROCWindow.fontkey:SetText(" ");
		ConROCWindow2.texture:SetTexture('Interface\\AddOns\\ConROC\\images\\Bigskull');
		ConROCWindow2.fontkey:SetText(" ");
		ConROCWindow3.texture:SetTexture('Interface\\AddOns\\ConROC\\images\\Bigskull');
		ConROCWindow3.fontkey:SetText(" ");
	end
end

function ConROC:InvokeNextDef()
	local oldSkill = self.Def;

	local timeShift, currentSpell, gcd = ConROC:EndCast();

	local iterateDef = self:NextDef(timeShift, currentSpell, gcd);
	self.Def = self.SuggestedDefSpells[1];

	local spellName, spellTexture;
	if self.Def then
		local spellInfo = C_Spell.GetSpellInfo(self.Def);
		if spellInfo then
			spellName = spellInfo.name;
			spellTexture = spellInfo.originalIconID;
		end
	end
	local color = ConROC.db.profile._Defense_Overlay_Color;

	if (oldSkill ~= self.Def or oldSkill == nil) and self.Def ~= nil then
		self:GlowNextDef(self.Def);
		ConROCDefenseWindow.texture:SetVertexColor(1, 1, 1);
		ConROCDefenseWindow.fontkey:SetText(ConROC:improvedGetBindingText(ConROC:FindKeybinding(self.Def)));
		if spellName ~= nil then
			ConROCDefenseWindow.texture:SetTexture(spellTexture);
			ConROCDefenseWindow.font:SetText(spellName);
		else
			local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(self.Def);
			ConROCDefenseWindow.texture:SetTexture(itemTexture);
			ConROCDefenseWindow.font:SetText(itemName);
		end
	end

	if self.Def == nil and oldSkill ~= nil then
		self:GlowClearDef();
		ConROCDefenseWindow.texture:SetTexture('Interface\\AddOns\\ConROC\\images\\shield2');
		ConROCDefenseWindow.texture:SetVertexColor(color.r, color.g, color.b);
		ConROCDefenseWindow.font:SetText(" ");
		ConROCDefenseWindow.fontkey:SetText(" ");
	end
end

function ConROC:LoadModule()
	local _, _, classId = UnitClass('player');
		if self.Classes[classId] == nil then
			self:Print(self.Colors.Error, 'Invalid player class, please contact author of addon.');
			return;
		end

	local module = 'ConROC_' .. self.Classes[classId];
	local _, _, _, loadable, reason = C_AddOns.GetAddOnInfo(module);

	if C_AddOns.IsAddOnLoaded(module) then
		self:EnableRotationModule();
		self:EnableDefenseModule();
		return;
	end

	if reason == 'MISSING' or reason == 'DISABLED' then
		self:Print(self.Colors.Error .. 'Could not find class module ' .. module .. ', reason: ' .. reason);
		return;
	end

	C_AddOns.LoadAddOn(module)

	self:EnableRotationModule();
	self:EnableDefenseModule();
	self:Print(self.Colors[classId] .. self.Description);

	if ConROC:currentSpec() then
		self:Print(self.Colors.Info .. "Current spec:", self.Colors.Success ..  ConROC:currentSpec())
	else
		self:Print(self.Colors.Error .. "You do not currently have a spec.")
	end

	self:Print(self.Colors.Info .. 'Finished Loading class module');
	self.ModuleLoaded = true;
end

function ConROC:HealSpec() --Leftover from Retail.
	local _, _, classId = UnitClass('player');
	--local specId = GetSpecialization();
	--[[[1] = 'Warrior',
		[2] = 'Paladin',
		[3] = 'Hunter',
		[4] = 'Rogue',
		[5] = 'Priest',
		[6] = 'DeathKnight',
		[7] = 'Shaman',
		[8] = 'Mage',
		[9] = 'Warlock',
		[10] = 'Monk',
		[11] = 'Druid',
		[12] = 'DemonHunter',]]
		
--[[	if (classId == 2 and specId == 1) or
	(classId == 5 and specId == 2) or
	(classId == 7 and specId == 3) or
	(classId == 10 and specId == 2) or
	(classId == 11 and specId == 4)	then
		return true;
	end]] 
	return false;
end
