ConROC.Spells = {};
ConROC.SuggestedSpells = {};
ConROC.SuggestedDefSpells = {};
ConROC.Keybinds = {};
ConROC.DefSpells = {};
ConROC.Flags = {};
ConROC.SpellsGlowing = {};
ConROC.DefGlowing = {};
ConROC.DamageFramePool = {};
ConROC.DamageFrames = {};
ConROC.DefenseFramePool = {};
ConROC.DefenseFrames = {};
ConROC.InterruptFramePool = {};
ConROC.InterruptFrames = {};
ConROC.CoolDownFramePool = {};
ConROC.CoolDownFrames = {};
ConROC.PurgableFramePool = {};
ConROC.PurgableFrames = {};
ConROC.RaidBuffsFramePool = {};
ConROC.RaidBuffsFrames = {};
ConROC.MovementFramePool = {};
ConROC.MovementFrames = {};
ConROC.TauntFramePool = {};
ConROC.TauntFrames = {};
local optionsOpened = false;

function ConROCTTOnEnter(self)
	local ttFrameName = self:GetName();
	GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )

	if ttFrameName == "ConROCSpellmenuFrame_OpenButton" or "ConROCSpellmenuFrame_Title" then
		GameTooltip:SetText("ConROC Rotation options")  -- This sets the top line of text, in gold.
		if ttFrameName == "ConROCSpellmenuFrame_OpenButton" then
			GameTooltip:AddLine('Click to show/hide options.', 1, 1, 1, true)
			GameTooltip:AddLine(" ", 1, 1, 1, true)
		end
		GameTooltip:AddLine('/ConROCUL to lock/unlock', 1, 1, 1, true)
	end
	if ttFrameName == "ConROCSpellmenuFrame_LockButton" then
		GameTooltip:SetText("ConROC Rotation options")  -- This sets the top line of text, in gold.
		if ttFrameName == "ConROCSpellmenuFrame_OpenButton" then
			GameTooltip:AddLine('Click to show/hide options.', 1, 1, 1, true)
			GameTooltip:AddLine(" ", 1, 1, 1, true)
		end
		GameTooltip:AddLine('Click to lock/unlock', 1, 1, 1, true)
	end

	if ttFrameName == "ConROC_SingleButton" then --Single target rotation button
		GameTooltip:SetText("ConROC Target Toggle")  -- This sets the top line of text, in gold.
		GameTooltip:AddLine('MACRO = "/ConROCToggle"', 1, 1, 1, true)
		GameTooltip:AddLine(" ", 1, 1, 1, true)
		GameTooltip:AddLine("Single", .2, 1, .2)
		GameTooltip:AddLine("This is for single target fights.", 1, 1, 1, true)
		GameTooltip:AddLine("AoE", 1, .2, .2)
		GameTooltip:AddLine("Can be used for trash or Boss fights with frequent adds.", 1, 1, 1, true)
		GameTooltip:AddLine(" ", 1, 1, 1, true)
		GameTooltip:AddLine('"This can be toggled during combat as phases change."', 1, 1, 0, true)
	end

	if ttFrameName == "ConROCWindow" or ttFrameName == "ConROCWindow2" or ttFrameName == "ConROCWindow3" then
		GameTooltip:SetText("ConROC Window")  -- This sets the top line of text, in gold.
		GameTooltip:AddLine("", .2, 1, .2)
		GameTooltip:AddLine("This window displays up to the next three(3) suggested abilities in your rotation.", 1, 1, 1, true)
	end

	if ttFrameName == "ConROCDefenseWindow" then
		GameTooltip:SetText("ConROC Defense Window")  -- This sets the top line of text, in gold.
		GameTooltip:AddLine("", .2, 1, .2)
		GameTooltip:AddLine("This window displays the next suggested defense ability in your rotation.", 1, 1, 1, true)
	end

	if ttFrameName == "ConROCInterruptWindow" then
		GameTooltip:SetText("ConROC Interrupt Flash")  -- This sets the top line of text, in gold.
		GameTooltip:AddLine("", .2, 1, .2)
			GameTooltip:AddLine("This flash displays that you can interrupt.", 1, 1, 1, true)

		local color = ConROC.db.profile._Interrupt_Overlay_Color;
		ConROCInterruptWindow:SetSize(ConROC.db.profile.flashIconSize * .75, ConROC.db.profile.flashIconSize * .75);
		ConROCInterruptWindow.texture:SetVertexColor(color.r, color.g, color.b);
	end

	if ttFrameName == "ConROCPurgeWindow" then
		GameTooltip:SetText("ConROC Purge Flash")  -- This sets the top line of text, in gold.
		GameTooltip:AddLine("", .2, 1, .2)
			GameTooltip:AddLine("This flash displays that you can purge.", 1, 1, 1, true)

		local color = ConROC.db.profile._Purge_Overlay_Color;
		ConROCPurgeWindow:SetSize(ConROC.db.profile.flashIconSize * .75, ConROC.db.profile.flashIconSize * .75);
		ConROCPurgeWindow.texture:SetVertexColor(color.r, color.g, color.b);
	end

	GameTooltip:Show()
end

function ConROCTTOnLeave(self)
	local ttFrameName = self:GetName();

	if ttFrameName == "ConROCInterruptWindow" then
		ConROCInterruptWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
		ConROCInterruptWindow.texture:SetVertexColor(.1, .1, .1);
	end

	if ttFrameName == "ConROCPurgeWindow" then
		ConROCPurgeWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
		ConROCPurgeWindow.texture:SetVertexColor(.1, .1, .1);
	end

	GameTooltip:Hide()
end

function ConROC:UpdateLockTexture()
    local lockButton = ConROCSpellmenuFrame_LockButton
    if ConROC.db.profile._Unlock_ConROC then
    	lockButton.lockTexture:SetTexture("Interface\\AddOns\\ConROC\\images\\padlock_open")
    else
    	lockButton.lockTexture:SetTexture("Interface\\AddOns\\ConROC\\images\\padlock_closed")
    end

end

function ConROC:SlashUnlock()
	if not ConROC.db.profile._Unlock_ConROC then
		ConROC.db.profile._Unlock_ConROC = true;
	else
		ConROC.db.profile._Unlock_ConROC = false;
	end
	ConROC:UpdateLockTexture()

	if IsAddOnLoaded("ConROC_Rogue") or IsAddOnLoaded("ConROC_Shaman") then
		if ConROC.db.profile._Unlock_ConROC then
        	ConROCApplyPoisonFrame_DragFrame:Show();
	    else
        	ConROCApplyPoisonFrame_DragFrame:Hide();
	    end
	end

	ConROCWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
	ConROCDefenseWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
	ConROCInterruptWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
	ConROCPurgeWindow:EnableMouse(ConROC.db.profile._Unlock_ConROC);
	ConROCInterruptWindow:SetMovable(ConROC.db.profile._Unlock_ConROC);
	ConROCPurgeWindow:SetMovable(ConROC.db.profile._Unlock_ConROC);

	if ConROC.db.profile._Unlock_ConROC and ConROC.db.profile.enableInterruptWindow then
		ConROCInterruptWindow:Show();
	else
		ConROCInterruptWindow:Hide();
	end

	if ConROC.db.profile._Unlock_ConROC and ConROC.db.profile.enablePurgeWindow then
		ConROCPurgeWindow:Show();
	else
		ConROCPurgeWindow:Hide();
	end

	if ConROCSpellmenuMover ~= nil then
		ConROCSpellmenuMover:EnableMouse(ConROC.db.profile._Unlock_ConROC);
		if ConROC.db.profile._Unlock_ConROC then
			ConROCSpellmenuMover:Show();
		else
			ConROCSpellmenuMover:Hide();
		end
	end

	if ConROCToggleMover ~= nil then
		ConROCToggleMover:EnableMouse(ConROC.db.profile._Unlock_ConROC);
		if ConROC.db.profile._Unlock_ConROC then
			ConROCToggleMover:Show();
		else
			ConROCToggleMover:Hide();
		end
	end
end

local printTalentsMode = false

SLASH_CONROC1 = '/ConROC'
SLASH_CONROCUNLOCK1 = '/ConROCUL'
SlashCmdList["CONROC"] = function() Settings.OpenToCategory('ConROC'); Settings.OpenToCategory('ConROC'); end
SlashCmdList["CONROCUNLOCK"] = function() ConROC:SlashUnlock() end
-- Slash command for printing talent tree with talent names and ID numbers
SLASH_CONROCPRINTTALENTS1 = "/ConROCPT"
SlashCmdList["CONROCPRINTTALENTS"] = function()
    printTalentsMode = not printTalentsMode
    ConROC:PopulateTalentIDs()
end

function ConROC:DisplayToggleFrame()
	local _, Class = UnitClass("player")
	local Color = RAID_CLASS_COLORS[Class]

	local mframe = CreateFrame("Frame", "ConROCToggleMover", UIParent)
		mframe:SetMovable(true)
		mframe:SetClampedToScreen(true)
		mframe:RegisterForDrag("LeftButton")
		mframe:SetScript("OnDragStart", function(self)
			if ConROC.db.profile._Unlock_ConROC then
				mframe:StartMoving()
			end
		end)
		mframe:SetScript("OnDragStop", mframe.StopMovingOrSizing)
		mframe:EnableMouse(ConROC.db.profile._Unlock_ConROC)

		mframe:SetPoint("CENTER", 250, -50)
		mframe:SetSize(10, 10)
		mframe:SetFrameStrata('MEDIUM');
		mframe:SetFrameLevel('4')
		mframe:SetAlpha(1)

		local t = mframe.texture;
			if not t then
				t = mframe:CreateTexture(nil, "ARTWORK")
				t:SetTexture('Interface\\AddOns\\ConROC\\images\\magiccircle-purge');
				t:SetBlendMode('BLEND');
				t:SetAlpha(1);
				t:SetVertexColor(.1, .1, .1);
				mframe.texture = t;
			end

		t:SetAllPoints(mframe)

		if ConROC.db.profile._Unlock_ConROC then
			mframe:Show();
		else
			mframe:Hide();
		end

	local frame = CreateFrame("Frame", "ConROCButtonFrame", UIParent,"BackdropTemplate")
		frame:SetClampedToScreen(true)
		frame:SetPoint("TOPRIGHT", mframe, "BOTTOMLEFT", 5, 5)
		frame:SetSize(54, 30);
		frame:SetScale(ConROC.db.profile.toggleButtonSize)
		frame:SetFrameStrata('MEDIUM');
		frame:SetFrameLevel('4')
		frame:SetAlpha(1)

		frame:SetBackdrop( {
			bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileSize = 8,
			edgeSize = 20,
			insets = {left = 4, right = 4, top = 4, bottom = 4}
			})
		frame:SetBackdropColor(0, 0, 0, .75)
		frame:SetBackdropBorderColor(Color.r, Color.g, Color.b, .75)


	local otbutton = CreateFrame("Button", 'ConROC_SingleButton', frame)
		otbutton:SetFrameStrata('MEDIUM')
		otbutton:SetFrameLevel('6')
		otbutton:SetPoint("CENTER");
		otbutton:SetSize(40, 16);
		otbutton:Show()
		otbutton:SetAlpha(1)

		otbutton:SetText("Single")
		otbutton:SetNormalFontObject("GameFontHighlightSmall")

		otbutton:SetScript("OnEnter", ConROCTTOnEnter)
		otbutton:SetScript("OnLeave", ConROCTTOnLeave)

	local ontex = otbutton:CreateTexture()
		ontex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonUp")
		ontex:SetTexCoord(0, 0.625, 0, 0.6875)
		ontex:SetVertexColor(Color.r, Color.g, Color.b, 1)
		ontex:SetAllPoints()
		otbutton:SetNormalTexture(ontex)

	local ohtex = otbutton:CreateTexture()
		ohtex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonHighlight")
		ohtex:SetTexCoord(0, 0.625, 0, 0.6875)
		ohtex:SetAllPoints()
		otbutton:SetHighlightTexture(ohtex)

	local optex = otbutton:CreateTexture()
		optex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonDown")
		optex:SetTexCoord(0, 0.625, 0, 0.6875)
		optex:SetVertexColor(Color.r, Color.g, Color.b, 1)
		optex:SetAllPoints()
		otbutton:SetPushedTexture(optex)

		otbutton:SetScript("OnMouseUp", function (self, otbutton, up)
				self:Hide();
				ConROC_AoEButton:Show();
		end)

	local tbutton = CreateFrame("Button", 'ConROC_AoEButton', ConROCButtonFrame)
		tbutton:SetFrameStrata('MEDIUM');
		tbutton:SetFrameLevel('6');
		tbutton:SetPoint("CENTER");
		tbutton:SetSize(40, 16);
		tbutton:Hide();
		tbutton:SetAlpha(1);

		tbutton:SetText("AoE");
		tbutton:SetNormalFontObject("GameFontHighlightSmall");

		tbutton:SetScript("OnEnter", TTOnEnter)
		tbutton:SetScript("OnLeave", TTOnLeave)

	local ntex = tbutton:CreateTexture()
		ntex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonUp")
		ntex:SetTexCoord(0, 0.625, 0, 0.6875)
		ntex:SetVertexColor(.50, .50, .50, 1)
		ntex:SetAllPoints()
		tbutton:SetNormalTexture(ntex)

	local htex = tbutton:CreateTexture()
		htex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonHighlight")
		htex:SetTexCoord(0, 0.625, 0, 0.6875)
		htex:SetAllPoints()
		tbutton:SetHighlightTexture(htex)

	local ptex = tbutton:CreateTexture()
		ptex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonDown")
		ptex:SetTexCoord(0, 0.625, 0, 0.6875)
		ptex:SetVertexColor(.50, .50, .50, 1)
		ptex:SetAllPoints()
		tbutton:SetPushedTexture(ptex)

		tbutton:SetScript("OnMouseUp", function (self, tbutton, up)
				self:Hide();
				ConROC_SingleButton:Show();
		end)
end

function ConROC:DisplayWindowFrame()
	local frame = CreateFrame("Frame", "ConROCWindow", UIParent)
		frame:SetMovable(true)
		frame:SetClampedToScreen(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnEnter", ConROCTTOnEnter)
		frame:SetScript("OnLeave", ConROCTTOnLeave)
		frame:SetScript("OnDragStart", function(self)
			if ConROC.db.profile._Unlock_ConROC then
				frame:StartMoving()
			end
		end)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:EnableMouse(ConROC.db.profile._Unlock_ConROC)

		frame:SetPoint("CENTER", -200, 100)
		frame:SetSize(ConROC.db.profile.windowIconSize, ConROC.db.profile.windowIconSize)
		frame:SetFrameStrata('MEDIUM');
		frame:SetFrameLevel('73');
		frame:SetAlpha(ConROC.db.profile.transparencyWindow);
		if ConROC.db.profile.combatWindow or ConROC:HealSpec() then
			frame:Hide();
		elseif not ConROC.db.profile.enableWindow then
			frame:Hide();
		else
			frame:Show();
		end
	local t = frame.texture;
		if not t then
			t = frame:CreateTexture(nil, "ARTWORK")
			t:SetTexture('Interface\\AddOns\\ConROC\\images\\Bigskull');
			t:SetBlendMode('BLEND');
			frame.texture = t;
		end

		t:SetAllPoints(frame)

	local fontstring = frame.font;
		if not fontstring then
			fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontstring:SetText(" ");
			local _, Class = UnitClass("player");
			local Color = RAID_CLASS_COLORS[Class];
			fontstring:SetTextColor(Color.r, Color.g, Color.b, 1);
			fontstring:SetPoint('BOTTOM', frame, 'TOP', 0, 2);
			fontstring:SetWidth(ConROC.db.profile.windowIconSize / 1.25 + 30);
			fontstring:SetHeight(ConROC.db.profile.windowIconSize / 1.25);
			fontstring:SetJustifyV("BOTTOM");
			frame.font = fontstring;
		end

		if ConROC.db.profile.enableWindowSpellName then
			fontstring:Show();
		else
			fontstring:Hide();
		end

	local fontkey = frame.fontkey;
		if not fontkey then
			fontkey = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontkey:SetText(" ");
			fontkey:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 3, -2);
			fontkey:SetFont("Fonts\\FRIZQT__.TTF",11,"OUTLINE");
			fontkey:SetTextColor(1, 1, 1, 1);
			frame.fontkey = fontkey;
		end
		if ConROC.db.profile.enableWindowKeybinds then
			fontkey:Show();
		else
			fontkey:Hide();
		end

	local cd = CreateFrame("Cooldown", "ConROCWindowCooldown", frame, "CooldownFrameTemplate")
		cd:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
		cd:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		cd:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
		cd:RegisterEvent("UNIT_SPELLCAST_SENT");
		cd:RegisterEvent("UNIT_SPELLCAST_START");
		cd:RegisterEvent("UNIT_SPELLCAST_DELAYED");
		cd:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        cd:RegisterEvent("UNIT_SPELLCAST_FAILED");
		cd:RegisterEvent("UNIT_SPELLCAST_START");
		cd:RegisterEvent("UNIT_SPELLCAST_STOP");

		cd:SetAllPoints(frame);
		cd:SetFrameStrata('MEDIUM');
		cd:SetFrameLevel('74');
		if ConROC.db.profile.enableWindowCooldown then
			cd:SetScript("OnEvent",function(self)
				local gcdStart, gcdDuration = GetSpellCooldown(29515);
				local _, _, _, startTimeMS, endTimeMS = UnitCastingInfo('player');
				local _, _, _, startTimeMSchan, endTimeMSchan = UnitChannelInfo('player');
				if not (endTimeMS or endTimeMSchan) then
					cd:SetCooldown(gcdStart, gcdDuration)
				elseif endTimeMSchan then
					local chanStart  = startTimeMSchan / 1000;
					local chanDuration = endTimeMSchan/1000 - GetTime();
					cd:SetCooldown(chanStart, chanDuration)
				else
					local spStart  = startTimeMS / 1000;
					local spDuration = endTimeMS/1000 - GetTime();
					cd:SetCooldown(spStart, spDuration)
				end
			end)
		end

	local frame2 = CreateFrame("Frame", "ConROCWindow2", UIParent);
		frame2:SetMovable(false);
		frame2:SetClampedToScreen(true);
		frame2:SetScript("OnEnter", ConROCTTOnEnter);
		frame2:SetScript("OnLeave", ConROCTTOnLeave);
		frame2:SetAlpha(ConROC.db.profile.transparencyWindow);

		frame2:SetPoint("BOTTOM" .. ConROC.db.profile._Reverse_Direction1, frame, "BOTTOM" .. ConROC.db.profile._Reverse_Direction2, ConROC.db.profile._Reverse_Direction3, 0);
		frame2:SetSize(ConROC.db.profile.windowIconSize/1.20, ConROC.db.profile.windowIconSize/1.20);
		if ConROC.db.profile.combatWindow or ConROC:HealSpec() then
			frame2:Hide();
		elseif not ConROC.db.profile.enableNextWindow then
			frame2:Hide();
		else
			frame2:Show();
		end

	local t2 = frame2.texture;
		if not t2 then
			t2 = frame2:CreateTexture("ARTWORK");
			t2:SetTexture('Interface\\AddOns\\ConROC\\images\\Bigskull');
			t2:SetBlendMode('BLEND');
			frame2.texture = t2;
		end

		t2:SetAllPoints(frame2)

	local fontkey2 = frame2.fontkey;
		if not fontkey2 then
			fontkey2 = frame2:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontkey2:SetText(" ");
			fontkey2:SetPoint('TOPRIGHT', frame2, 'TOPRIGHT', 3, -2);
			fontkey2:SetFont("Fonts\\FRIZQT__.TTF",11,"OUTLINE");
			fontkey2:SetTextColor(1, 1, 1, 1);
			frame2.fontkey = fontkey2;
		end
		if ConROC.db.profile.enableWindowKeybinds then
			fontkey2:Show();
		else
			fontkey2:Hide();
		end

	local frame3 = CreateFrame("Frame", "ConROCWindow3", UIParent);
		frame3:SetMovable(false);
		frame3:SetClampedToScreen(true);
		frame3:SetScript("OnEnter", ConROCTTOnEnter);
		frame3:SetScript("OnLeave", ConROCTTOnLeave);
		frame3:SetAlpha(ConROC.db.profile.transparencyWindow);

		frame3:SetPoint("BOTTOM" .. ConROC.db.profile._Reverse_Direction1, frame2, "BOTTOM" .. ConROC.db.profile._Reverse_Direction2, ConROC.db.profile._Reverse_Direction3, 0);
		frame3:SetSize(ConROC.db.profile.windowIconSize/1.20, ConROC.db.profile.windowIconSize/1.20);
		if ConROC.db.profile.combatWindow or ConROC:HealSpec() then
			frame3:Hide();
		elseif not ConROC.db.profile.enableNextWindow then
			frame3:Hide();
		else
			frame3:Show();
		end

	local t3 = frame3.texture;
		if not t3 then
			t3 = frame3:CreateTexture("ARTWORK");
			t3:SetTexture('Interface\\AddOns\\ConROC\\images\\Bigskull');
			t3:SetBlendMode('BLEND');
			frame3.texture = t3;
		end

		t3:SetAllPoints(frame3)

	local fontkey3 = frame3.fontkey;
		if not fontkey3 then
			fontkey3 = frame3:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontkey3:SetText(" ");
			fontkey3:SetPoint('TOPRIGHT', frame3, 'TOPRIGHT', 3, -2);
			fontkey3:SetFont("Fonts\\FRIZQT__.TTF",11,"OUTLINE");
			fontkey3:SetTextColor(1, 1, 1, 1);
			frame3.fontkey = fontkey3;
		end
		if ConROC.db.profile.enableWindowKeybinds then
			fontkey3:Show();
		else
			fontkey3:Hide();
		end
end

function ConROC:DefenseWindowFrame()
	local frame = CreateFrame("Frame", "ConROCDefenseWindow", UIParent);
		frame:SetMovable(true);
		frame:SetClampedToScreen(true);
		frame:RegisterForDrag("LeftButton");
		frame:SetScript("OnEnter", ConROCTTOnEnter);
		frame:SetScript("OnLeave", ConROCTTOnLeave);
		frame:SetScript("OnDragStart", function(self)
			if ConROC.db.profile._Unlock_ConROC then
				frame:StartMoving()
			end
		end)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:EnableMouse(ConROC.db.profile._Unlock_ConROC);

		frame:SetPoint("CENTER", -280, -50);
		frame:SetSize(ConROC.db.profile.windowIconSize * .75, ConROC.db.profile.windowIconSize * .75);
		frame:SetFrameStrata('MEDIUM');
		frame:SetFrameLevel('73');
		frame:SetAlpha(ConROC.db.profile.transparencyWindow);
		if ConROC.db.profile.combatWindow then
			frame:Hide();
		elseif not ConROC.db.profile.enableDefenseWindow then
			frame:Hide();
		else
			frame:Show();
		end

	local t = frame.texture;
		if not t then
			t = frame:CreateTexture(nil, "ARTWORK")
			t:SetTexture('Interface\\AddOns\\ConROC\\images\\shield2');
			t:SetBlendMode('BLEND');
			local color = ConROC.db.profile._Defense_Overlay_Color;
			t:SetVertexColor(color.r, color.g, color.b);
			frame.texture = t;
		end

		t:SetAllPoints(frame)

	local fontstring = frame.font;
		if not fontstring then
			fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontstring:SetText(" ");
			local _, Class = UnitClass("player");
			local Color = RAID_CLASS_COLORS[Class];
			fontstring:SetTextColor(Color.r, Color.g, Color.b, 1);
			fontstring:SetPoint('BOTTOM', frame, 'TOP', 0, 2);
			fontstring:SetWidth(ConROC.db.profile.windowIconSize / 1.25 + 30);
			fontstring:SetHeight(ConROC.db.profile.windowIconSize / 1.25);
			fontstring:SetJustifyV("BOTTOM");
			frame.font = fontstring;
		end

		if ConROC.db.profile.enableWindowSpellName then
			fontstring:Show();
		else
			fontstring:Hide();
		end

	local fontkey = frame.fontkey;
		if not fontkey then
			fontkey = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontkey:SetText(" ");
			fontkey:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 3, -2);
			fontkey:SetFont("Fonts\\FRIZQT__.TTF",11,"OUTLINE");
			fontkey:SetTextColor(1, 1, 1, 1);
			frame.fontkey = fontkey;
		end
		if ConROC.db.profile.enableWindowKeybinds then
			fontkey:Show();
		else
			fontkey:Hide();
		end

	local cd = CreateFrame("Cooldown", "ConROCDefWindowCooldown", frame, "CooldownFrameTemplate")
		cd:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
		cd:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		cd:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
		cd:RegisterEvent("UNIT_SPELLCAST_SENT");
		cd:RegisterEvent("UNIT_SPELLCAST_START");
		cd:RegisterEvent("UNIT_SPELLCAST_DELAYED");
		cd:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        cd:RegisterEvent("UNIT_SPELLCAST_FAILED");
		cd:RegisterEvent("UNIT_SPELLCAST_START");
		cd:RegisterEvent("UNIT_SPELLCAST_STOP");

		cd:SetAllPoints(frame);
		cd:SetFrameStrata('MEDIUM');
		cd:SetFrameLevel('74');
		if ConROC.db.profile.enableWindowCooldown then
			cd:SetScript("OnEvent",function(self)
				local gcdStart, gcdDuration = GetSpellCooldown(29515);
				local _, _, _, startTimeMS, endTimeMS = UnitCastingInfo('player');
				local _, _, _, startTimeMSchan, endTimeMSchan = UnitChannelInfo('player');
				if not (endTimeMS or endTimeMSchan) then
					cd:SetCooldown(gcdStart, gcdDuration)
				elseif endTimeMSchan then
					local chanStart  = startTimeMSchan / 1000;
					local chanDuration = endTimeMSchan/1000 - GetTime();
					cd:SetCooldown(chanStart, chanDuration)
				else
					local spStart  = startTimeMS / 1000;
					local spDuration = endTimeMS/1000 - GetTime();
					cd:SetCooldown(spStart, spDuration)
				end
			end)
		end
end

function ConROC:InterruptWindowFrame()
	local frame = CreateFrame("Frame", "ConROCInterruptWindow", UIParent);
		frame:SetMovable(true);
		frame:SetClampedToScreen(true);
		frame:RegisterForDrag("LeftButton");
		frame:SetScript("OnEnter", ConROCTTOnEnter);
		frame:SetScript("OnLeave", ConROCTTOnLeave);
		frame:SetScript("OnDragStart", function(self)
			if ConROC.db.profile._Unlock_ConROC then
				frame:StartMoving()
			end
		end)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:EnableMouse(ConROC.db.profile._Unlock_ConROC);

		frame:SetPoint(ConROC.db.profile._Reverse_Direction2, "ConROCWindow", "TOP" .. ConROC.db.profile._Reverse_Direction1, ConROC.db.profile._Reverse_Direction4, 0);
		frame:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
		frame:SetFrameStrata('MEDIUM');
		frame:SetFrameLevel('5');
		if ConROC.db.profile.enableInterruptWindow == true and ConROC.db.profile._Unlock_ConROC == true then
			frame:Show();
		else
			frame:Hide();
		end

	local t = frame.texture;
		if not t then
			t = frame:CreateTexture(nil, "ARTWORK")
			t:SetTexture('Interface\\AddOns\\ConROC\\images\\lightning-interrupt');
			t:SetBlendMode('BLEND');
			t:SetAlpha(ConROC.db.profile.transparencyWindow);
			t:SetVertexColor(.1, .1, .1);
			frame.texture = t;
		end

		t:SetAllPoints(frame)
end

function ConROC:PurgeWindowFrame()
	local frame = CreateFrame("Frame", "ConROCPurgeWindow", UIParent);
		frame:SetMovable(true);
		frame:SetClampedToScreen(true);
		frame:RegisterForDrag("LeftButton");
		frame:SetScript("OnEnter", ConROCTTOnEnter);
		frame:SetScript("OnLeave", ConROCTTOnLeave);
		frame:SetScript("OnDragStart", function(self)
			if ConROC.db.profile._Unlock_ConROC then
				frame:StartMoving()
			end
		end)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:EnableMouse(ConROC.db.profile._Unlock_ConROC);

		frame:SetPoint(ConROC.db.profile._Reverse_Direction2, "ConROCWindow", "BOTTOM" .. ConROC.db.profile._Reverse_Direction1, ConROC.db.profile._Reverse_Direction4, 0);
		frame:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
		frame:SetFrameStrata('MEDIUM');
		frame:SetFrameLevel('5');
		if ConROC.db.profile.enablePurgeWindow == true and ConROC.db.profile._Unlock_ConROC == true then
			frame:Show();
		else
			frame:Hide();
		end

	local t = frame.texture;
		if not t then
			t = frame:CreateTexture(nil, "ARTWORK")
			t:SetTexture('Interface\\AddOns\\ConROC\\images\\magiccircle-purge');
			t:SetBlendMode('BLEND');
			t:SetAlpha(ConROC.db.profile.transparencyWindow);
			t:SetVertexColor(.1, .1, .1);
			frame.texture = t;
		end

		t:SetAllPoints(frame)
end

function ConROC:SpellmenuFrame()
	local _, Class, classId = UnitClass("player")
	local Color = RAID_CLASS_COLORS[Class]
	local frame = CreateFrame("Frame", "ConROCSpellmenuFrame", UIParent,"BackdropTemplate")
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('4')
	frame:SetSize((90) + 14, (15) + 14)
		if ConROC.db.profile._Hide_Spellmenu then
			frame:SetAlpha(0);
			else
			frame:SetAlpha(1);
		end

	frame:SetBackdrop( {
		bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 20,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
	frame:SetBackdropColor(0, 0, 0, .75)
	frame:SetBackdropBorderColor(Color.r, Color.g, Color.b, .75)

	frame:SetPoint("CENTER", 500, 300)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if ConROC.db.profile._Unlock_ConROC then
			frame:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetScript("OnEnter", function(self)
		frame:SetAlpha(1);
	end)
	frame:SetScript("OnLeave", function(self)
		if not MouseIsOver(frame) then
			if ConROC.db.profile._Hide_Spellmenu then
				frame:SetAlpha(0);
				else
				frame:SetAlpha(1);
			end
		end
	end)

	local frameTitle = CreateFrame("Frame", "ConROCSpellmenuFrame_Title", frame)
	frameTitle:SetFrameStrata('MEDIUM');
	frameTitle:SetFrameLevel('5');
	frameTitle:SetSize(180, 20);
	frameTitle:SetAlpha(1);

	frameTitle:SetPoint("TOP", frame, "TOP", 0, -8);
	frameTitle:Hide();

	frameTitle:SetScript("OnEnter", ConROCTTOnEnter)
	frameTitle:SetScript("OnLeave", ConROCTTOnLeave)
	--frameTitle:EnableMouse(false)

	frameTitle:RegisterForDrag("LeftButton")
	frameTitle:SetScript("OnDragStart", function(self)
		if ConROC.db.profile._Unlock_ConROC then
			self:GetParent():StartMoving()
		end
	end)
	frameTitle:SetScript("OnDragStop", function(self)
		self:GetParent():StopMovingOrSizing()
	end) --, frameTitle:GetParent().StopMovingOrSizing)

	local fonttitle = frameTitle:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	--fonttitle:SetText(ConROC.Classes[classId] .. " Spells");
	fonttitle:SetText(select(1, GetClassInfo(classId)) .. " Spells");
	fonttitle:SetPoint('TOP', frameTitle, 'TOP', 0, 0);

	local otbutton = CreateFrame("Button", 'ConROCSpellmenuFrame_OpenButton', frame);
	otbutton:SetFrameStrata('MEDIUM');
	otbutton:SetFrameLevel('6');
	otbutton:SetPoint("CENTER", frame, "CENTER");
	otbutton:SetSize(90, 15);
	otbutton:Show();
	otbutton:SetAlpha(1);

		--otbutton:SetText(ConROC.Classes[classId] .. " Spells");
		otbutton:SetText(select(1, GetClassInfo(classId)) .. " Spells");
		otbutton:SetNormalFontObject("GameFontHighlightSmall");
		otbutton:SetScript("OnEnter", ConROCTTOnEnter)
		otbutton:SetScript("OnLeave", ConROCTTOnLeave)

		local ontex = otbutton:CreateTexture();
		ontex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonUp");
		ontex:SetTexCoord(0, 0.625, 0, 0.6875);
		ontex:SetVertexColor(Color.r, Color.g, Color.b, 1);
		ontex:SetAllPoints();
		otbutton:SetNormalTexture(ontex);

		local ohtex = otbutton:CreateTexture()
		ohtex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonHighlight")
		ohtex:SetTexCoord(0, 0.625, 0, 0.6875)
		ohtex:SetAllPoints()
		otbutton:SetHighlightTexture(ohtex)

		local optex = otbutton:CreateTexture()
		optex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonDown")
		optex:SetTexCoord(0, 0.625, 0, 0.6875)
		optex:SetVertexColor(Color.r, Color.g, Color.b, 1)
		optex:SetAllPoints()
		otbutton:SetPushedTexture(optex)

		otbutton:SetScript("OnMouseDown", function (self, otbutton, up)
			if ConROC.db.profile._Unlock_ConROC then
					frame:StartMoving()
			end
		end)

		otbutton:SetScript("OnMouseUp", function (self, otbutton, up)
			if ConROC.db.profile._Unlock_ConROC then
				frame:StopMovingOrSizing();
			end
		--if not (IsAltKeyDown()) then
			self:Hide();
			frameTitle:Show();
			frame:SetSize(210, 300);
			ConROCSpellmenuClass:Show();
			optionsOpened = true;
			ConROCSpellmenuFrame_CloseButton:Show();
			ConROC:SpellMenuUpdate();
		--	end
		end)

	local tbutton = CreateFrame("Button", 'ConROCSpellmenuFrame_CloseButton', frame)
		tbutton:SetFrameStrata('MEDIUM')
		tbutton:SetFrameLevel('6')
		tbutton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
		tbutton:SetSize(12, 12)
		tbutton:Hide()
		tbutton:SetAlpha(1)
		tbutton:SetText("X")
		tbutton:SetNormalFontObject("GameFontHighlightSmall")

		local ntex = tbutton:CreateTexture()
			ntex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonUp")
			ntex:SetTexCoord(0, 0.625, 0, 0.6875)
			ntex:SetVertexColor(1, .1, .1, 1)
			ntex:SetAllPoints()
			tbutton:SetNormalTexture(ntex)

		local htex = tbutton:CreateTexture()
			htex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonHighlight")
			htex:SetTexCoord(0, 0.625, 0, 0.6875)
			htex:SetAllPoints()
			tbutton:SetHighlightTexture(htex)

		local ptex = tbutton:CreateTexture()
			ptex:SetTexture("Interface\\AddOns\\ConROC\\images\\buttonDown")
			ptex:SetTexCoord(0, 0.625, 0, 0.6875)
			ptex:SetVertexColor(1, .1, .1, 1)
			ptex:SetAllPoints()
			tbutton:SetPushedTexture(ptex)

		tbutton:SetScript("OnMouseUp", function (self, tbutton, up)
			self:Hide();
			frameTitle:Hide();
			ConROCSpellmenuClass:Hide();
			frame:SetSize((90) + 14, (15) + 14);
			ConROCSpellmenuFrame_OpenButton:Show();
			optionsOpened = false;
		end)

	local lockButton = CreateFrame("Button", 'ConROCSpellmenuFrame_LockButton', frame)
    lockButton:SetFrameStrata('MEDIUM')
    lockButton:SetFrameLevel('6')
    lockButton:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -5, 11)
    lockButton:SetSize(18, 18)
    lockButton:SetAlpha(0.5)

    local lockTexture = lockButton:CreateTexture(nil, "OVERLAY")
    lockTexture:SetAllPoints()
    lockButton.lockTexture = lockTexture

    lockButton:SetScript("OnEnter", function(self)
	    ConROCTTOnEnter(self)
	    self:SetAlpha(1) -- Set alpha to max on hover
	end)

	lockButton:SetScript("OnLeave", function(self)
	    ConROCTTOnLeave(self)
	    self:SetAlpha(0.5) -- Reset alpha to half on mouse out
	end)

    lockButton:SetScript("OnClick", function()
        -- Toggle the _Unlock_ConROC status
        ConROC:SlashUnlock()
    end)

    -- Initialize the lock texture based on initial _Unlock_ConROC status
    ConROC:UpdateLockTexture();
    lockButton:Show();
	ConROCSpellmenuFrame:Hide();
end

function ConROC:closeSpellmenu()
	ConROCSpellmenuFrame_CloseButton:Hide();
	ConROCSpellmenuFrame_Title:Hide();
	ConROCSpellmenuClass:Hide();
	ConROCSpellmenuFrame:SetSize((90) + 14, (15) + 14);
	ConROCSpellmenuFrame_OpenButton:Show();
	optionsOpened = false;
end

local bindingSubs = {
    { "CTRL%-", "C" },
    { "ALT%-", "A" },
    { "SHIFT%-", "S" },
    { "STRG%-", "ST" },
    { "%s+", "" },
    { "NUMPAD", "N" },
    { "PLUS", "+" },
    { "MINUS", "-" },
    { "MULTIPLY", "*" },
    { "DIVIDE", "/" },
    { "BUTTON", "M" },
    { "MOUSEWHEELUP", "MwU" },
    { "MOUSEWHEELDOWN", "MwD" },
    { "MOUSEWHEEL", "Mw" },
    { "DOWN", "Dn" },
    { "UP", "Up" },
    { "PAGE", "Pg" },
    { "BACKSPACE", "BkSp" },
    { "DECIMAL", "." },
    { "CAPSLOCK", "CAPS" },
}

function ConROC:improvedGetBindingText(binding)
    if not binding then return "" end

    for i, rep in ipairs(bindingSubs) do
        binding = binding:gsub( rep[1], rep[2] )
    end

    return binding
end

function ConROC:FindKeybinding(id,caller)
	local keybind;
	if self.Keybinds[id] ~= nil then
		for k, button in pairs(self.Keybinds[id]) do
			for i = 1, 12 do
				if button == 'ActionButton' .. i then
					button = 'ACTIONBUTTON' .. i;
				elseif button == 'MultiBarBottomLeftButton' .. i then
					button = 'MULTIACTIONBAR1BUTTON' .. i;
				elseif button == 'MultiBarBottomRightButton' .. i then
					button = 'MULTIACTIONBAR2BUTTON' .. i;
				elseif button == 'MultiBarRightButton' .. i then
					button = 'MULTIACTIONBAR3BUTTON' .. i;
				elseif button == 'MultiBarLeftButton' .. i then
					button = 'MULTIACTIONBAR4BUTTON' .. i;
				elseif button == 'MultiBar5Button' .. i then
					button = 'MULTIACTIONBAR5BUTTON' .. i;
				elseif button == 'MultiBar6Button' .. i then
					button = 'MULTIACTIONBAR6BUTTON' .. i;
				elseif button == 'MultiBar7Button' .. i then
					button = 'MULTIACTIONBAR7BUTTON' .. i;
				end

				keybind = GetBindingKey(button);

				if keybind ~= nil then
					return keybind;
				end
			end
		end
	end

	return keybind;

	--[[local btn;
	local binding;
	for k, button in pairs(self.Keybinds[id]) do
		if _G["Bartender4"] then
			for actionBarNumber = 1, 10 do
                local bar = _G["BT4Bar" .. actionBarNumber]
                print("button",button)
                for keyNumber = 1, 12 do
                    local actionBarButtonId = (actionBarNumber - 1) * 12 + keyNumber
                    local bindingKeyName = "ACTIONBUTTON" .. keyNumber
                    if string.find(string.lower(button),string.lower("SHAPESHIFTBUTTON")) then
                    	bindingKeyName = "BT4StanceButton" .. keyNumber
                    	--return GetBindingKey(bindingKeyName);
                    elseif string.find(string.lower(button),string.lower("ACTIONBUTTON")) then
                    	bindingKeyName = "CLICK BT4Button" .. keyNumber
                    	--return GetBindingKey(bindingKeyName);
                    end
                    -- If bar is disabled assume paging / stance switching on bar 1
                    if actionBarNumber > 1 and bar and not bar.disabled then
                        bindingKeyName = "CLICK BT4Button" .. actionBarButtonId .. ":LeftButton"
                    end
                    binding = bindingKeyName.bindstring or bindingKeyName.keyBoundTarget or ( "CLICK " .. bindingKeyName:GetName() .. ":LeftButton" )
	                		
                    print("button",button)
                    print("GetBindingKey( actionBarButtonId )",GetBindingKey( binding ))
                    return GetBindingKey(bindingKeyName);
                end
            end
        -- Use ElvUI's actionbars only if they are actually enabled.
        if _G["ElvUI"] and _G[ "ElvUI_Bar1Button1" ] then
			for a = 1, 10 do
                for b = 1, 12 do
                	if string.find(string.lower(button),string.lower("SHAPESHIFTBUTTON")) then
                		btn = "SHAPESHIFTBUTTON" .. b
                		if button == btn then
	                		return GetBindingKey( button )
						end
                	else
                		btn = _G["ElvUI_Bar" .. a .. "Button" .. b]
                		if button == btn:GetName() then
	                		binding = btn.bindstring or btn.keyBoundTarget or ( "CLICK " .. btn:GetName() .. ":LeftButton" )
	                		
		                    if a > 6 then
			                    -- Checking whether bar is active.
			                    local bar = _G["ElvUI_Bar" .. a]

			                    if not bar or not bar.db.enabled then
			                        binding = "ACTIONBUTTON" .. b
			                    end
			                end
			                return GetBindingKey(binding);
						end
                	end
                end
            end
		else
			for i = 1, 12 do
				if string.find(string.lower(button),string.lower("SHAPESHIFTBUTTON")) then
            		btn = "SHAPESHIFTBUTTON" .. i
            		if button == btn then
                		return GetBindingKey( button )
					end
            	else
					if string.lower(button) == string.lower("ACTIONBUTTON" .. i) then
						return GetBindingKey('ACTIONBUTTON' .. i)
					elseif string.lower(button) == string.lower("MultiBarBottomLeftButton" .. i) then
						return GetBindingKey('MULTIACTIONBAR1BUTTON' .. i)
					elseif string.lower(button) == string.lower("MultiBarBottomRightButton" .. i) then
						return GetBindingKey('MULTIACTIONBAR2BUTTON' .. i)
					elseif string.lower(button) == string.lower("MultiBarRightButton" .. i) then
						return GetBindingKey('MULTIACTIONBAR3BUTTON' .. i)
					elseif string.lower(button) == string.lower("MultiBarLeftButton" .. i) then
						return GetBindingKey('MultiActionBar4Button' .. i)
					elseif string.lower(button) == string.lower("ElvUI_Bar2Button" .. i) then
						return GetBindingKey('ELVUIBAR2BUTTON' .. i)
					end					
				end
			end
		end
	end
	--print('keybind', keybind);
	--return keybind;]]
end

function ConROC:CreateDamageOverlay(parent, id)
	local frame = tremove(self.DamageFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_DamageOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6');
	frame:SetPoint('CENTER', 0, 5);
	frame:SetWidth(parent:GetWidth() * 1.6);
	frame:SetHeight(parent:GetHeight() * 1.8);
	frame:SetScale(ConROC.db.profile.overlayScale);
	local alpha = 0;
	local alphaSet = ConROC.db.profile.damageOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('GlowDamageOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\skull');
		t:SetBlendMode('ADD');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile.damageOverlayColor;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.DamageFrames, frame);
	return frame;
end

function ConROC:CreateDefenseOverlay(parent, id)
	local frame = tremove(self.DefenseFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_DefenseOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, 0);
	frame:SetWidth(parent:GetWidth() * 1.6);
	frame:SetHeight(parent:GetHeight() * 1.5);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.defenseOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('GlowDefenseOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\shield2');
		t:SetBlendMode('ADD');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile._Defense_Overlay_Color;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.DefenseFrames, frame);
	return frame;
end

function ConROC:CreateInterruptOverlay(parent, id)
	local frame = tremove(self.InterruptFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_InterruptOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, 0);
	frame:SetWidth(parent:GetWidth() * 1.8);
	frame:SetHeight(parent:GetHeight() * 1.8);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.notifierOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('AbilityInterruptOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\lightning');
		t:SetBlendMode('BLEND');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile._Interrupt_Overlay_Color;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.InterruptFrames, frame);
	return frame;
end

function ConROC:CreatePurgableOverlay(parent, id)
	local frame = tremove(self.PurgableFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_PurgableOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, 0);
	frame:SetWidth(parent:GetWidth() * 2);
	frame:SetHeight(parent:GetHeight() * 2);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.notifierOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('AbilityPurgeOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\magiccircle');
		t:SetBlendMode('BLEND');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile._Purge_Overlay_Color;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.PurgableFrames, frame);
	return frame;
end

function ConROC:CreateTauntOverlay(parent, id)
	local frame = tremove(self.TauntFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_TauntOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, 0);
	frame:SetWidth(parent:GetWidth() * 1.5);
	frame:SetHeight(parent:GetHeight() * 1.5);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.defenseOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('AbilityTauntOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\rage');
		t:SetBlendMode('BLEND');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile.tauntOverlayColor;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.TauntFrames, frame);
	return frame;
end

function ConROC:CreateRaidBuffsOverlay(parent, id)
	local frame = tremove(self.RaidBuffsFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_RaidBuffsOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, 0);
	frame:SetWidth(parent:GetWidth() * 1.5);
	frame:SetHeight(parent:GetHeight() * 1.65);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.notifierOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('AbilityRaidBuffsOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\plus');
		t:SetBlendMode('BLEND');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile.raidbuffsOverlayColor;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.RaidBuffsFrames, frame);
	return frame;
end

function ConROC:CreateMovementOverlay(parent, id)
	local frame = tremove(self.MovementFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_MovementOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, -3);
	frame:SetWidth(parent:GetWidth() * 1.65);
	frame:SetHeight(parent:GetHeight() * 1.85);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.notifierOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('AbilityMovementOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\arrow');
		t:SetBlendMode('BLEND');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile.movementOverlayColor;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.MovementFrames, frame);
	return frame;
end

function ConROC:CreateCoolDownOverlay(parent, id)
	local frame = tremove(self.CoolDownFramePool);
	if not frame then
		frame = CreateFrame('Frame', 'ConROC_CoolDownOverlay_' .. id, parent);
	end

	frame:SetParent(parent);
	frame:SetFrameStrata('MEDIUM');
	frame:SetFrameLevel('6')
	frame:SetPoint('CENTER', 0, 0);
	frame:SetWidth(parent:GetWidth() * 2);
	frame:SetHeight(parent:GetHeight() * 2);
	frame:SetScale(ConROC.db.profile.overlayScale)
	local alpha = 0;
	local alphaSet = ConROC.db.profile.damageOverlayAlpha;
		if alphaSet == true then
			alpha = 1;
		end
	frame:SetAlpha(alpha);

	local t = frame.texture;
	if not t then
		t = frame:CreateTexture('AbilityBurstOverlay', 'OVERLAY');
		t:SetTexture('Interface\\AddOns\\ConROC\\images\\starburst');
		t:SetBlendMode('ADD');
		frame.texture = t;
	end

	t:SetAllPoints(frame);
	local color = ConROC.db.profile.cooldownOverlayColor;
	t:SetVertexColor(color.r, color.g, color.b);
	t:SetAlpha(color.a);

	tinsert(self.CoolDownFrames, frame);
	return frame;
end

function ConROC:DestroyDamageOverlays()
	local frame;
	for key, frame in pairs(self.DamageFrames) do
		frame:GetParent().ConROCDamageOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.DamageFrames) do
		tinsert(self.DamageFramePool, frame);
		self.DamageFrames[key] = nil;
	end
end

function ConROC:DestroyInterruptOverlays()
	local frame;
	for key, frame in pairs(self.InterruptFrames) do
		frame:GetParent().ConROCInterruptOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.InterruptFrames) do
		tinsert(self.InterruptFramePool, frame);
		self.InterruptFrames[key] = nil;
	end
end

function ConROC:DestroyPurgableOverlays()
	local frame;
	for key, frame in pairs(self.PurgableFrames) do
		frame:GetParent().ConROCPurgableOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.PurgableFrames) do
		tinsert(self.PurgableFramePool, frame);
		self.PurgableFrames[key] = nil;
	end
end

function ConROC:DestroyTauntOverlays()
	local frame;
	for key, frame in pairs(self.TauntFrames) do
		frame:GetParent().ConROCTauntOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.TauntFrames) do
		tinsert(self.TauntFramePool, frame);
		self.TauntFrames[key] = nil;
	end
end

function ConROC:DestroyRaidBuffsOverlays()
	local frame;
	for key, frame in pairs(self.RaidBuffsFrames) do
		frame:GetParent().ConROCRaidBuffsOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.RaidBuffsFrames) do
		tinsert(self.RaidBuffsFramePool, frame);
		self.RaidBuffsFrames[key] = nil;
	end
end

function ConROC:DestroyMovementOverlays()
	local frame;
	for key, frame in pairs(self.MovementFrames) do
		frame:GetParent().ConROCMovementOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.MovementFrames) do
		tinsert(self.MovementFramePool, frame);
		self.MovementFrames[key] = nil;
	end
end

function ConROC:DestroyCoolDownOverlays()
	local frame;
	for key, frame in pairs(self.CoolDownFrames) do
		frame:GetParent().ConROCCoolDownOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.CoolDownFrames) do
		tinsert(self.CoolDownFramePool, frame);
		self.CoolDownFrames[key] = nil;
	end
end

function ConROC:DestroyDefenseOverlays()
	local frame;
	for key, frame in pairs(self.DefenseFrames) do
		frame:GetParent().ConROCDefenseOverlays = nil;
		frame:ClearAllPoints();
		frame:Hide();
		frame:SetParent(UIParent);
		frame.width = nil;
		frame.height = nil;
		frame.alpha = nil;
	end
	for key, frame in pairs(self.DefenseFrames) do
		tinsert(self.DefenseFramePool, frame);
		self.DefenseFrames[key] = nil;
	end
end

function ConROC:UpdateButtonGlow()
	local LAB;
	local LBG;
	local origShow;
	local noFunction = function() end;

	if IsAddOnLoaded('ElvUI') then
		LAB = LibStub:GetLibrary('LibActionButton-1.0-ElvUI');
		LBG = LibStub:GetLibrary('LibCustomGlow-1.0'); --LibStub:GetLibrary('LibButtonGlow-1.0');
		origShow = LBG.ShowOverlayGlow;
	elseif IsAddOnLoaded('Bartender4') then
		LAB = LibStub:GetLibrary('LibActionButton-1.0');
	end

	if self.db.profile.disableButtonGlow then
		ActionBarActionEventsFrame:UnregisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW');
		if LAB then
			LAB.eventFrame:UnregisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW');
		end

		if LBG then
			LBG.ShowOverlayGlow = noFunction;
		end
	else
		ActionBarActionEventsFrame:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW');
		if LAB then
			LAB.eventFrame:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW');
		end

		if LBG then
			LBG.ShowOverlayGlow = origShow;
		end
	end
end

function ConROC:DamageGlow(button, id)
	if button.ConROCDamageOverlays and button.ConROCDamageOverlays[id] then
		button.ConROCDamageOverlays[id]:Show();
	else
		if not button.ConROCDamageOverlays then
			button.ConROCDamageOverlays = {};
		end

		button.ConROCDamageOverlays[id] = self:CreateDamageOverlay(button, id);
		button.ConROCDamageOverlays[id]:Show();
	end
end

function ConROC:DefenseGlow(button, id)
	if button.ConROCDefenseOverlays and button.ConROCDefenseOverlays[id] then
		button.ConROCDefenseOverlays[id]:Show();
	else
		if not button.ConROCDefenseOverlays then
			button.ConROCDefenseOverlays = {};
		end

		button.ConROCDefenseOverlays[id] = self:CreateDefenseOverlay(button, id);
		button.ConROCDefenseOverlays[id]:Show();
	end
end

function ConROC:InterruptGlow(button, id)
	if button.ConROCInterruptOverlays and button.ConROCInterruptOverlays[id] then
		button.ConROCInterruptOverlays[id]:Show();
	else
		if not button.ConROCInterruptOverlays then
			button.ConROCInterruptOverlays = {};
		end

		button.ConROCInterruptOverlays[id] = self:CreateInterruptOverlay(button, id);
		button.ConROCInterruptOverlays[id]:Show();
	end
end

function ConROC:PurgableGlow(button, id)
	if button.ConROCPurgableOverlays and button.ConROCPurgableOverlays[id] then
		button.ConROCPurgableOverlays[id]:Show();
	else
		if not button.ConROCPurgableOverlays then
			button.ConROCPurgableOverlays = {};
		end

		button.ConROCPurgableOverlays[id] = self:CreatePurgableOverlay(button, id);
		button.ConROCPurgableOverlays[id]:Show();
	end
end

function ConROC:TauntGlow(button, id)
	if button.ConROCTauntOverlays and button.ConROCTauntOverlays[id] then
		button.ConROCTauntOverlays[id]:Show();
	else
		if not button.ConROCTauntOverlays then
			button.ConROCTauntOverlays = {};
		end

		button.ConROCTauntOverlays[id] = self:CreateTauntOverlay(button, id);
		button.ConROCTauntOverlays[id]:Show();
	end
end

function ConROC:RaidBuffsGlow(button, id)
	if button.ConROCRaidBuffsOverlays and button.ConROCRaidBuffsOverlays[id] then
		button.ConROCRaidBuffsOverlays[id]:Show();
	else
		if not button.ConROCRaidBuffsOverlays then
			button.ConROCRaidBuffsOverlays = {};
		end

		button.ConROCRaidBuffsOverlays[id] = self:CreateRaidBuffsOverlay(button, id);
		button.ConROCRaidBuffsOverlays[id]:Show();
	end
end

function ConROC:MovementGlow(button, id)
	if button.ConROCMovementOverlays and button.ConROCMovementOverlays[id] then
		button.ConROCMovementOverlays[id]:Show();
	else
		if not button.ConROCMovementOverlays then
			button.ConROCMovementOverlays = {};
		end

		button.ConROCMovementOverlays[id] = self:CreateMovementOverlay(button, id);
		button.ConROCMovementOverlays[id]:Show();
	end
end

function ConROC:CoolDownGlow(button, id)
	if button.ConROCCoolDownOverlays and button.ConROCCoolDownOverlays[id] then
		button.ConROCCoolDownOverlays[id]:Show();
	else
		if not button.ConROCCoolDownOverlays then
			button.ConROCCoolDownOverlays = {};
		end

		button.ConROCCoolDownOverlays[id] = self:CreateCoolDownOverlay(button, id);
		button.ConROCCoolDownOverlays[id]:Show();
	end
end

function ConROC:HideDamageGlow(button, id)
	if button.ConROCDamageOverlays and button.ConROCDamageOverlays[id] then
		button.ConROCDamageOverlays[id]:Hide();
	end
end

function ConROC:HideDefenseGlow(button, id)
	if button.ConROCDefenseOverlays and button.ConROCDefenseOverlays[id] then
		button.ConROCDefenseOverlays[id]:Hide();
	end
end

function ConROC:HideCoolDownGlow(button, id)
	if button.ConROCCoolDownOverlays and button.ConROCCoolDownOverlays[id] then
		button.ConROCCoolDownOverlays[id]:Hide();
	end
end

function ConROC:HideInterruptGlow(button, id)
	if button.ConROCInterruptOverlays and button.ConROCInterruptOverlays[id] then
		button.ConROCInterruptOverlays[id]:Hide();
	end
end

function ConROC:HidePurgableGlow(button, id)
	if button.ConROCPurgableOverlays and button.ConROCPurgableOverlays[id] then
		button.ConROCPurgableOverlays[id]:Hide();
	end
end

function ConROC:HideTauntGlow(button, id)
	if button.ConROCTauntOverlays and button.ConROCTauntOverlays[id] then
		button.ConROCTauntOverlays[id]:Hide();
	end
end

function ConROC:HideRaidBuffsGlow(button, id)
	if button.ConROCRaidBuffsOverlays and button.ConROCRaidBuffsOverlays[id] then
		button.ConROCRaidBuffsOverlays[id]:Hide();
	end
end

function ConROC:HideMovementGlow(button, id)
	if button.ConROCMovementOverlays and button.ConROCMovementOverlays[id] then
		button.ConROCMovementOverlays[id]:Hide();
	end
end

function ConROC:UpdateRotation()
	self = ConROC;

	self:FetchBlizzard();

	if IsAddOnLoaded('Bartender4') then
		self:FetchBartender4();
	end

	if IsAddOnLoaded('ButtonForge') then
		self:FetchButtonForge();
	end

	if IsAddOnLoaded('ElvUI') then
		self:FetchElvUI();
	end

	if IsAddOnLoaded('Dominos') then
		self:FetchDominos();
	end

    if IsAddOnLoaded('DiabolicUI') then
        self:FetchDiabolic();
    end

    if IsAddOnLoaded('AzeriteUI') then
        self:FetchAzeriteUI();
    end
end

function ConROC:UpdateDefRotation()
	self = ConROC;

	self:DefFetchBlizzard();

	if IsAddOnLoaded('Bartender4') then
		self:DefFetchBartender4();
	end

	if IsAddOnLoaded('ButtonForge') then
		self:DefFetchButtonForge();
	end

	if IsAddOnLoaded('ElvUI') then
		self:DefFetchElvUI();
	end

	if IsAddOnLoaded('Dominos') then
		self:DefFetchDominos();
	end

    if IsAddOnLoaded('DiabolicUI') then
        self:DefFetchDiabolic();
    end

    if IsAddOnLoaded('AzeriteUI') then
        self:DefFetchAzeriteUI();
    end
end

function ConROC:AddButton(spellID, button, hotkey)
	if spellID then
		if self.Spells[spellID] == nil then
			self.Spells[spellID] = {};
		end
		tinsert(self.Spells[spellID], button);

		if self.Keybinds[spellID] == nil then
			self.Keybinds[spellID] = {};
		end

		tinsert(self.Keybinds[spellID], hotkey);
	end
end

function ConROC:AddStandardButton(button, hotkey)
	local type = button:GetAttribute('type');
	if type then
		local actionType = button:GetAttribute(type);
		local id;
		local spellId;

        if type == 'action' then
            local slot = button:GetAttribute('action')
			if not slot or slot == 0 then
                slot = ActionButton_GetPagedID(button);
            end
            if not slot or slot == 0 then
                slot = ActionButton_CalculateAction(button);
            end
            if HasAction(slot) then
                type, id = GetActionInfo(slot);
            else
                return;
            end
        end

        if type == 'macro' then
			spellId = GetMacroSpell(actionType);
            if not spellId then
                local slot = button:GetAttribute('action')
				if not slot or slot == 0 then
					slot = ActionButton_GetPagedID(button);
				end
				if not slot or slot == 0 then
					slot = ActionButton_CalculateAction(button);
				end
                local macroName = GetActionText(slot)
                id = GetMacroIndexByName(macroName)
                spellId = GetMacroSpell(id)
            end
        elseif type == 'item' then
            spellId = C_Item.GetItemSpell(id)
        elseif type == 'spell' then
			local spellInfo = C_Spell.GetSpellInfo(id)
            spellId = spellInfo and spellInfo.spellID
        end

		if spellId then
            self:AddButton(spellId, button, hotkey)
        end
    end

	if not type and button and button.HasAction then
		local id, _, HasAction, spellID = button:HasAction()
		if spellID then
			self:AddButton(spellID, button)
		end
	end
end

function ConROC:DefAddButton(spellID, button, hotkey)
	if spellID then
		if self.DefSpells[spellID] == nil then
			self.DefSpells[spellID] = {};
		end
		tinsert(self.DefSpells[spellID], button);

		if self.Keybinds[spellID] == nil then
			self.Keybinds[spellID] = {};
		end

		tinsert(self.Keybinds[spellID], hotkey);
	end
end

function ConROC:DefAddStandardButton(button, hotkey)
	local buttonType = button:GetAttribute('type');
	if buttonType then
		local id;
		local spellId;
		local actionType;

        if buttonType == 'action' then
            local slot = button:GetAttribute('action');
            if not slot or slot == 0 then
                slot = ActionButton_GetPagedID(button);
            end
            if not slot or slot == 0 then
                slot = ActionButton_CalculateAction(button);
            end

            if HasAction(slot) then
                actionType, id = GetActionInfo(slot);
				if actionType == 'spell' then
					spellId = id;
				elseif actionType == 'macro' then
					local macroSpellId = GetMacroSpell(id);
					if macroSpellId then
						spellId = macroSpellId;
					else
						return;  -- No spell associated with this macro
					end
				elseif actionType == 'item' then
					spellId = id;
				else
					return;  -- Unsupported action type
				end
			else
				return;  -- Action slot is empty
			end
		elseif buttonType == 'macro' then
			local slot = button:GetAttribute('action');
            if not slot or slot == 0 then
                slot = ActionButton_GetPagedID(button);
            end
            if not slot or slot == 0 then
                slot = ActionButton_CalculateAction(button);
            end
			local macroName = GetActionText(slot);
			id = GetMacroIndexByName(macroName);
			
            spellId = GetMacroSpell(id);
            if not spellId then
                return;  -- No spell associated with this macro
            end
		elseif buttonType == 'item' then
			spellId = id;
		elseif buttonType == 'spell' then
            spellId = select(7, GetSpellInfo(id));
        end

		if spellId then
			self:DefAddButton(spellId, button, hotkey);
		end
	end
end

function ConROC:Fetch()
	self = ConROC;
	if self.rotationEnabled then
		self:DisableRotationTimer();
	end
	self.Spell = nil;

	self:GlowClear();
	self.Spells = {};
	self.Keybinds = {};
	self.Flags = {};
	self.SpellsGlowing = {};

	self:FetchBlizzard();

	if IsAddOnLoaded('Bartender4') then
		self:FetchBartender4();
	end

	if IsAddOnLoaded('ButtonForge') then
		self:FetchButtonForge();
	end

	if IsAddOnLoaded('ElvUI') then
		self:FetchElvUI();
	end

	if IsAddOnLoaded('Dominos') then
		self:FetchDominos();
	end

    if IsAddOnLoaded('DiabolicUI') then
        self:FetchDiabolic();
    end

    if IsAddOnLoaded('AzeriteUI_Classic') then
        self:FetchAzeriteUI();
    end

	if self.rotationEnabled then
		self:EnableRotationTimer();
		self:InvokeNextSpell();
	end
end

function ConROC:FetchDef()
	self = ConROC;
	if self.defenseEnabled then
		self:DisableDefenseTimer();
	end
	self.Def = nil;

	self:GlowClearDef();
	self.DefSpells = {};
	self.Flags = {};
	self.DefGlowing = {};

	self:DefFetchBlizzard();

	if IsAddOnLoaded('Bartender4') then
		self:DefFetchBartender4();
	end

	if IsAddOnLoaded('ButtonForge') then
		self:DefFetchButtonForge();
	end

	if IsAddOnLoaded('ElvUI') then
		self:DefFetchElvUI();
	end

	if IsAddOnLoaded('Dominos') then
		self:DefFetchDominos();
	end

	if IsAddOnLoaded('DiabolicUI') then
        self:DefFetchDiabolic();
    end

    if IsAddOnLoaded('AzeriteUI_Classic') then
        self:DefFetchAzeriteUI();
    end

	if self.defenseEnabled then
		self:EnableDefenseTimer();
		self:InvokeNextDef();
	end
end

function ConROC:FetchBlizzard()
	local ActionBarsBlizzard = {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft', 'Stance', 'PetAction'};
	for _, barName in pairs(ActionBarsBlizzard) do
		if barName == 'Stance' then
			local x = GetNumShapeshiftForms();
			for i = 1, x do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'SHAPESHIFTBUTTON' .. i;
				local spellID = select(4, GetShapeshiftFormInfo(i));
				self:AddButton(spellID, button, hotkey);
			end
		elseif barName == 'PetAction' then
			for i = 1, 10 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = barName .. 'Button' .. i;
				local spellID = select(7, GetPetActionInfo(i));
				self:AddButton(spellID, button, hotkey);
			end
		else
			for i = 1, 12 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = barName .. 'Button' .. i;
				self:AddStandardButton(button, hotkey);
			end
		end
	end
end

function ConROC:DefFetchBlizzard()
	local ActionBarsBlizzard = {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft', 'Stance', 'PetAction'};
	for _, barName in pairs(ActionBarsBlizzard) do
		if barName == 'Stance' then
			local x = GetNumShapeshiftForms();
			for i = 1, x do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'SHAPESHIFTBUTTON' .. i;
				local spellID = select(4, GetShapeshiftFormInfo(i));
				self:DefAddButton(spellID, button, hotkey);
			end
		elseif barName == 'PetAction' then
			for i = 1, 10 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = barName .. 'Button' .. i;
				local spellID = select(7, GetPetActionInfo(i));
				self:DefAddButton(spellID, button, hotkey);
			end
		else
			for i = 1, 12 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = barName .. 'Button' .. i;
				self:DefAddStandardButton(button, hotkey);
			end
		end
	end
end

function ConROC:FetchDominos()
	for i = 1, 60 do
		local button = _G['DominosActionButton' .. i];
		if button then
			local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute('action') or 0;
			if HasAction(slot) then
				local spellID, _;
				local actionType, id = GetActionInfo(slot);
				if actionType == 'macro' then id = GetMacroSpell(id) end
				if actionType == 'item' then
					spellID = id;
				elseif actionType == 'spell' or (actionType == 'macro' and id) then
					spellID = id;
				end
				if spellID then
					if self.Spells[spellID] == nil then
						self.Spells[spellID] = {};
					end

					tinsert(self.Spells[spellID], button);

					if self.Keybinds[spellID] == nil then
						self.Keybinds[spellID] = {};
					end

					tinsert(self.Keybinds[spellID], 'DominosActionButton' .. i);

				end
			end
		end
	end
end

function ConROC:DefFetchDominos()
	for i = 1, 60 do
		local button = _G['DominosActionButton' .. i];
		if button then
			local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute('action') or 0;
			if HasAction(slot) then
				local spellID, _;
				local actionType, id = GetActionInfo(slot);
				if actionType == 'macro' then
					id = GetMacroSpell(id)
				end
				if actionType == 'item' then
					spellID = id;
				elseif actionType == 'spell' or (actionType == 'macro' and id) then
					spellID = id;
				end
				if spellID then
					if self.DefSpells[spellID] == nil then
						self.DefSpells[spellID] = {};
					end

					tinsert(self.DefSpells[spellID], button);

					if self.Keybinds[spellID] == nil then
						self.Keybinds[spellID] = {};
					end

					tinsert(self.Keybinds[spellID], 'DominosActionButton' .. i);

				end
			end
		end
	end
end

function ConROC:FetchButtonForge()
	local i = 1;
	while true do
		local button = _G['ButtonForge' .. i];
		if not button then
			break;
		end
		i = i + 1;

		local type = button:GetAttribute('type');
		if type then
			local actionType = button:GetAttribute(type);
			local id;
			local spellId;
			if type == 'macro' then
				local id = GetMacroSpell(actionType);
				if id then
					spellId = select(7, GetSpellInfo(id));
				end
			elseif type == 'item' then
				actionName = GetItemInfo(actionType);
			elseif type == 'spell' then
				spellId = select(7, GetSpellInfo(actionType));
			end
			if spellId then
				if self.Spells[spellId] == nil then
					self.Spells[spellId] = {};
				end

				tinsert(self.Spells[spellId], button);

				if self.Keybinds[spellId] == nil then
					self.Keybinds[spellId] = {};
				end

				tinsert(self.Keybinds[spellId], 'ButtonForge' .. i);

			end
		end
	end
end

function ConROC:DefFetchButtonForge()
	local i = 1;
	while true do
		local button = _G['ButtonForge' .. i];
		if not button then
			break;
		end
		i = i + 1;

		local type = button:GetAttribute('type');
		if type then
			local actionType = button:GetAttribute(type);
			local id;
			local spellId;
			if type == 'macro' then
				local id = GetMacroSpell(actionType);
				if id then
					spellId = select(7, GetSpellInfo(id));
				end
			elseif type == 'item' then
				actionName = GetItemInfo(actionType);
			elseif type == 'spell' then
				spellId = select(7, GetSpellInfo(actionType));
			end
			if spellId then
				if self.DefSpells[spellId] == nil then
					self.DefSpells[spellId] = {};
				end

				tinsert(self.DefSpells[spellId], button);

				if self.Keybinds[spellId] == nil then
					self.Keybinds[spellId] = {};
				end

				tinsert(self.Keybinds[spellId], 'ButtonForge' .. i);

			end
		end
	end
end

function ConROC:FetchElvUI()
	local ret = false;
	for x = 0, 10 do
		for i = 1, 12 do
			local button = _G['ElvUI_Bar' .. x .. 'Button' .. i];
			if button then
				local spellId = button:GetSpellId();
				if spellId then
					local actionName, _ = GetSpellInfo(spellId);
					if spellId then
						if self.Spells[spellId] == nil then
							self.Spells[spellId] = {};
						end
						ret = true;
						tinsert(self.Spells[spellId], button);

						if self.Keybinds[spellId] == nil then
							self.Keybinds[spellId] = {};
						end

						tinsert(self.Keybinds[spellId], 'ElvUI_Bar' .. x .. 'Button' .. i);
					end
				end
			end
		end
	end
	return ret;
end

function ConROC:DefFetchElvUI()
	local ret = false;
	for x = 1, 10 do
		for i = 1, 12 do
			local button = _G['ElvUI_Bar' .. x .. 'Button' .. i];
			if button then
				local spellId = button:GetSpellId();
				if spellId then
					local actionName, _ = GetSpellInfo(spellId);
					if spellId then
						if self.DefSpells[spellId] == nil then
							self.DefSpells[spellId] = {};
						end
						ret = true;
						tinsert(self.DefSpells[spellId], button);

						if self.Keybinds[spellId] == nil then
							self.Keybinds[spellId] = {};
						end

						tinsert(self.Keybinds[spellId], 'ElvUI_Bar' .. x .. 'Button' .. i);

					end
				end
			end
		end
	end
	return ret;
end

function ConROC:FetchBartender4()
	local ActionBarsBartender4 = {'BT4','BT4Stance', 'BT4Pet'};
	for _, barName in pairs(ActionBarsBartender4) do
		if barName == 'BT4Stance' then
			local x = GetNumShapeshiftForms();
			for i = 1, x do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'CLICK BT4StanceButton' .. i .. ':LeftButton';
				local spellID = select(4, GetShapeshiftFormInfo(i));
				self:AddButton(spellID, button, hotkey);
			end
		elseif barName == 'BT4Pet' then
			for i = 1, 10 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'CLICK BT4PetButton' .. i .. ':LeftButton';
				local spellID = select(7, GetPetActionInfo(i));
				self:AddButton(spellID, button, hotkey);
			end
		else
			for i = 1, 120 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'CLICK BT4Button' .. i .. ':LeftButton';
				if button then
					self:AddStandardButton(button, hotkey);
				end
			end
		end
	end
end

function ConROC:DefFetchBartender4()
	local ActionBarsBartender4 = {'BT4','BT4Stance', 'BT4Pet'};
	for _, barName in pairs(ActionBarsBartender4) do
		if barName == 'BT4Stance' then
			local x = GetNumShapeshiftForms();
			for i = 1, x do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'CLICK BT4StanceButton' .. i .. ':LeftButton';
				local spellID = select(4, GetShapeshiftFormInfo(i));
				self:DefAddButton(spellID, button, hotkey);
			end
		elseif barName == 'BT4Pet' then
			for i = 1, 10 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'CLICK BT4PetButton' .. i .. ':LeftButton';
				local spellID = select(7, GetPetActionInfo(i));
				self:DefAddButton(spellID, button, hotkey);
			end
		else
			for i = 1, 120 do
				local button = _G[barName .. 'Button' .. i];
				local hotkey = 'CLICK BT4Button' .. i .. ':LeftButton';
				if button then
					self:DefAddStandardButton(button, hotkey);
				end
			end
		end
	end
end

function ConROC:FetchDiabolic()
    local ActionBarsDiabolic = {'EngineBar1', 'EngineBar2', 'EngineBar3', 'EngineBar4', 'EngineBar5'};
    for _, barName in pairs(ActionBarsDiabolic) do
        for i = 1, 12 do
            local button = _G[barName .. 'Button' .. i];
            if button then
                self:AddStandardButton(button);
            end
        end
    end
end

function ConROC:DefFetchDiabolic()
    local ActionBarsDiabolic = {'EngineBar1', 'EngineBar2', 'EngineBar3', 'EngineBar4', 'EngineBar5'};
    for _, barName in pairs(ActionBarsDiabolic) do
        for i = 1, 12 do
            local button = _G[barName .. 'Button' .. i];
            if button then
                self:AddStandardButton(button);
            end
        end
    end
end

function ConROC:FetchAzeriteUI()
    for i = 1, 24 do
        local button = _G['AzeriteUI_ClassicActionButton' .. i];
        if button then
            self:AddStandardButton(button);
        end
    end
end

function ConROC:DefFetchAzeriteUI()
    for i = 1, 24 do
        local button = _G['AzeriteUI_ClassicActionButton' .. i];
        if button then
            self:AddStandardButton(button);
        end
    end
end

function ConROC:Dump()
	local s = '';
	for k, v in pairs(self.Spells) do
		s = s .. ', ' .. k;
	end
	print(s);
end

function ConROC:FindSpell(spellID)
	return self.Spells[spellID];
end

function ConROC:AbilityBurstIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:CoolDownGlow(button, _Spell_ID);
		end
	end
end

function ConROC:AbilityInterruptIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:InterruptGlow(button, _Spell_ID);
		end
	end
end

function ConROC:AbilityPurgeIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:PurgableGlow(button, _Spell_ID);
		end
	end
end

function ConROC:AbilityTauntIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:TauntGlow(button, _Spell_ID);
		end
	end
end

function ConROC:AbilityRaidBuffsIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:RaidBuffsGlow(button, _Spell_ID);
		end
	end
end

function ConROC:AbilityMovementIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:MovementGlow(button, _Spell_ID);
		end
	end
end

function ConROC:ClearAbilityBurstIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:HideCoolDownGlow(button, _Spell_ID);
		end
	end
end

function ConROC:ClearAbilityInterruptIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:HideInterruptGlow(button, _Spell_ID);
		end
	end
end

function ConROC:ClearAbilityPurgeIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:HidePurgableGlow(button, _Spell_ID);
		end
	end
end

function ConROC:ClearAbilityTauntIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:HideTauntGlow(button, _Spell_ID);
		end
	end
end

function ConROC:ClearAbilityRaidBuffsIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:HideRaidBuffsGlow(button, _Spell_ID);
		end
	end
end

function ConROC:ClearAbilityMovementIndependent(_Spell_ID)
	if self.Spells[_Spell_ID] ~= nil then
		for k, button in pairs(self.Spells[_Spell_ID]) do
			self:HideMovementGlow(button, _Spell_ID);
		end
	end
end

function ConROC:AbilityBurst(_Spell, _Condition)
	local incombat = UnitAffectingCombat('player');

	if self.Flags[_Spell] == nil then
		self.Flags[_Spell] = false;
	end
	if _Condition and incombat then
		self.Flags[_Spell] = true;
		self:AbilityBurstIndependent(_Spell);
	else
		self.Flags[_Spell] = false;
		self:ClearAbilityBurstIndependent(_Spell);
	end
end

function ConROC:AbilityInterrupt(_Spell, _Condition)
	local color = ConROC.db.profile._Interrupt_Overlay_Color;
	if self.Flags[_Spell] == nil then
		self.Flags[_Spell] = false;
		self:ClearAbilityInterruptIndependent(_Spell);
		ConROCInterruptWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
		ConROCInterruptWindow.texture:SetVertexColor(.1, .1, .1);
		if UIFrameIsFlashing(ConROCInterruptWindow) then
			UIFrameFlashStop(ConROCInterruptWindow);
			if ConROC.db.profile._Unlock_ConROC == true and ConROC.db.profile.enableInterruptWindow == true then
				ConROCInterruptWindow:Show();
			end
		end
	end
	if _Condition then
		if not self.Flags[_Spell] then
			ConROCInterruptWindow:SetSize(ConROC.db.profile.flashIconSize * .75, ConROC.db.profile.flashIconSize * .75);
			ConROCInterruptWindow.texture:SetVertexColor(color.r, color.g, color.b);
			if not UIFrameIsFlashing(ConROCInterruptWindow) and ConROC.db.profile.enableInterruptWindow then
				UIFrameFlash(ConROCInterruptWindow, 0.25, 0.25, -1);
			end
		end
		self.Flags[_Spell] = true;
		self:AbilityInterruptIndependent(_Spell);
	else
		if self.Flags[_Spell] then
			ConROCInterruptWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
			ConROCInterruptWindow.texture:SetVertexColor(.1, .1, .1);
			if UIFrameIsFlashing(ConROCInterruptWindow) then
				UIFrameFlashStop(ConROCInterruptWindow);
				if ConROC.db.profile._Unlock_ConROC == true and ConROC.db.profile.enableInterruptWindow == true then
					ConROCInterruptWindow:Show();
				end
			end
		end
		self.Flags[_Spell] = false;
		self:ClearAbilityInterruptIndependent(_Spell);
	end
end

function ConROC:AbilityPurge(_Spell, _Condition)
	local color = ConROC.db.profile._Purge_Overlay_Color;
	if self.Flags[_Spell] == nil then
		self.Flags[_Spell] = false;
		self:ClearAbilityPurgeIndependent(_Spell);
		ConROCPurgeWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
		ConROCPurgeWindow.texture:SetVertexColor(.1, .1, .1);
		if UIFrameIsFlashing(ConROCPurgeWindow) then
			UIFrameFlashStop(ConROCPurgeWindow);
			if ConROC.db.profile._Unlock_ConROC == true and ConROC.db.profile.enablePurgeWindow == true then
				ConROCPurgeWindow:Show();
			end
		end
	end
	if _Condition then
		if not self.Flags[_Spell] then
			ConROCPurgeWindow:SetSize(ConROC.db.profile.flashIconSize * .75, ConROC.db.profile.flashIconSize * .75);
			ConROCPurgeWindow.texture:SetVertexColor(color.r, color.g, color.b);
			if not UIFrameIsFlashing(ConROCPurgeWindow) and ConROC.db.profile.enablePurgeWindow then
				UIFrameFlash(ConROCPurgeWindow, 0.25, 0.25, -1);
			end
		end
		self.Flags[_Spell] = true;
		self:AbilityPurgeIndependent(_Spell);
	else
		if self.Flags[_Spell] then
			ConROCPurgeWindow:SetSize(ConROC.db.profile.flashIconSize * .25, ConROC.db.profile.flashIconSize * .25);
			ConROCPurgeWindow.texture:SetVertexColor(.1, .1, .1);
			if UIFrameIsFlashing(ConROCPurgeWindow) then
				UIFrameFlashStop(ConROCPurgeWindow);
				if ConROC.db.profile._Unlock_ConROC == true and ConROC.db.profile.enablePurgeWindow == true then
					ConROCPurgeWindow:Show();
				end
			end
		end
		self.Flags[_Spell] = false;
		self:ClearAbilityPurgeIndependent(_Spell);
	end
end

function ConROC:AbilityTaunt(_Spell, _Condition)
	if self.Flags[_Spell] == nil then
		self.Flags[_Spell] = false;
	end
	if _Condition then
		self.Flags[_Spell] = true;
		self:AbilityTauntIndependent(_Spell);
	else
		self.Flags[_Spell] = false;
		self:ClearAbilityTauntIndependent(_Spell);
	end
end

function ConROC:AbilityRaidBuffs(_Spell, _Condition)
	if self.Flags[_Spell] == nil then
		self.Flags[_Spell] = false;
	end
	if _Condition then
		self.Flags[_Spell] = true;
		self:AbilityRaidBuffsIndependent(_Spell);
	else
		self.Flags[_Spell] = false;
		self:ClearAbilityRaidBuffsIndependent(_Spell);
	end
end

function ConROC:AbilityMovement(_Spell, _Condition)
	if self.Flags[_Spell] == nil then
		self.Flags[_Spell] = false;
	end
	if _Condition then
		self.Flags[_Spell] = true;
		self:AbilityMovementIndependent(_Spell);
	else
		self.Flags[_Spell] = false;
		self:ClearAbilityMovementIndependent(_Spell);
	end
end

local swapSpells = {
	Toast = 26008,
	AutoAttack = 6603,
	AutoShot = 75,
}

ConROCSwapSpells = ConROCSwapSpells or swapSpells;

function ConROC:GlowSpell(spellID)
	local spellName;
	local spellRank = "";
	local spellInfo = C_Spell.GetSpellInfo(spellID);
		spellName = spellInfo and spellInfo.name
	local _IsSwapSpell = false;

	for k, swapSpellID in pairs(ConROCSwapSpells) do
		if spellID == swapSpellID then
			_IsSwapSpell = true;
			break;
		end
	end

	for tab = 1, GetNumSpellTabs() do
		local _, _, tabOffset, numEntries = GetSpellTabInfo(tab);
		for i = tabOffset + 1, tabOffset + numEntries do
		 local sName, sSubName, sID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
			if sName == spellName and sID == spellID then
				spellRank = sSubName;
			end
		end
	end

	if self.Spells[spellID] ~= nil then
		for k, button in pairs(self.Spells[spellID]) do
			self:DamageGlow(button, 'next');
		end
		self.SpellsGlowing[spellID] = 1;
	else
		if UnitAffectingCombat('player') and not _IsSwapSpell then
			if spellName ~= nil then
				self:Print(self.Colors.Error .. 'Spell not found on action bars: ' .. ' ' .. spellName .. ' ' .. spellRank .. ' ' .. '(' .. spellID .. ')' .. ' Check your spellbook.');
			else
				local itemName = GetItemInfo(spellID);
				if itemName ~= nil then
					self:Print(self.Colors.Error .. 'Item not found on action bars: ' .. ' ' .. itemName .. ' ' .. '(' .. spellID .. ')');
				end
			end
		end
		ConROC:ButtonFetch();
	end
end

function ConROC:GlowDef(spellID)
	local spellName;
	local spellRank = "";
	local spellInfo = C_Spell.GetSpellInfo(spellID);
		spellName = spellInfo and spellInfo.name;

	for tab = 1, GetNumSpellTabs() do
		local _, _, tabOffset, numEntries = GetSpellTabInfo(tab);
		for i = tabOffset + 1, tabOffset + numEntries do
		 local sName, sSubName, sID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
			if sName == spellName and sID == spellID then
				spellRank = sSubName;
			end
		end
	end

	if self.DefSpells[spellID] ~= nil then
		for k, button in pairs(self.DefSpells[spellID]) do
			self:DefenseGlow(button, 'nextdef');
		end
		self.DefGlowing[spellID] = 1;
	else
		if UnitAffectingCombat('player') then
			if spellName ~= nil then
				self:Print(self.Colors.Error .. 'Spell not found on action bars: ' .. ' ' .. spellName .. ' ' .. spellRank .. ' ' .. '(' .. spellID .. ')' .. ' Check your spellbook.');
			else
				local itemName = GetItemInfo(spellID);
				if itemName ~= nil then
					self:Print(self.Colors.Error .. 'Item not found on action bars: ' .. ' ' .. itemName .. ' ' .. '(' .. spellID .. ')');
				end
			end
		end
		ConROC:ButtonFetch();
	end
end

function ConROC:GlowNextSpell(spellID)
	self:GlowClear();
	self:GlowSpell(spellID);
end

function ConROC:GlowNextDef(spellID)
	self:GlowClearDef();
	self:GlowDef(spellID);
end

function ConROC:GlowClear()
	for spellID, v in pairs(self.SpellsGlowing) do
		if v == 1 then
			for k, button in pairs(self.Spells[spellID]) do
				self:HideDamageGlow(button, 'next');
			end
			self.SpellsGlowing[spellID] = 0;
		end
	end
end

function ConROC:GlowClearDef()
	for spellID, v in pairs(self.DefGlowing) do
		if v == 1 then
			for k, button in pairs(self.DefSpells[spellID]) do
				self:HideDefenseGlow(button, 'nextdef');
			end
			self.DefGlowing[spellID] = 0;
		end
	end
end