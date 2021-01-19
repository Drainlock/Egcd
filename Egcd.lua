EgcdRealm = GetRealmName()
EgcdChar = UnitName("player");
CharIndex=EgcdChar.." - "..EgcdRealm
EgcdDB=EgcdDB or {}
EgcdDB["CharsUse"]=EgcdDB["CharsUse"] or {}
EgcdDB["Default"]= EgcdDB["Default"] or { scale = 1, scale2 = 1, hidden = true, hidden2 = true, smart = true, smartPrio=true, prio = false, cols=1, colsPrio=1, arenaOnly=false, bgOnly=false, lock = false, growUp=1, growLeft=1, noCD=false, prioOnly=false,}
EgcdDB[CharIndex] = EgcdDB[CharIndex] or EgcdDB["Default"]--{ scale = 1, scale2=1 , hidden = false, hidden2=false, smart=false, smartPrio=false, prio = false, cols=1, colsPrio=1, arenaOnly=false, bgOnly=false, lock = false, growUp=1, growLeft=1, noCD=false, prioOnly=false,}
for k,v in pairs(EgcdDB) do
	if not (type(EgcdDB[k]) == "table" ) then 
		EgcdDB[k]=nil
	elseif (k=="Position" and (EgcdDB["Position"]["scale2"]==nil)) then 
		EgcdDB[k]=nil
	end
end
if (EgcdDB["CharsUse"][CharIndex]) then
	CharIndex=EgcdDB["CharsUse"][CharIndex]
else
	EgcdDB["CharsUse"][CharIndex]=CharIndex
end

local abilities = {}
local order
local arena=false
local bg=false
local band = bit.band
local spell_table=spell_table

if spell_table==nil then ChatFrame1:AddMessage("NOT LOADED",0,1,0) end
for k,spell in ipairs(spell_table) do
	local name,_,spellicon = GetSpellInfo(spell.spellID)	
	abilities[name] = { icon = spellicon, duration = spell.time }
end

local frame
local bar
local bar2
local x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
local x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
local y2 = 0
local count2 = 0
local count=0
local y = 0
local totalIcons=0
local GetTime = GetTime
local ipairs = ipairs
local pairs = pairs
local select = select
local floor = floor
local band = bit.band
local GetSpellInfo = GetSpellInfo
local GROUP_UNITS = bit.bor(0x00000010, 0x00000400)
local activetimers = {}
local size = 0

local function getsize()
	size = 0
	for k in pairs(activetimers) do
		size = size + 1
	end
end

local function isInBG()
	local a,type = IsInInstance()
	if (type == "pvp") then
		return true
	end
	return false
end

local function isInArena()
	local _,type = IsInInstance()
	if (type == "arena") then
		return true
	end
	return false
	
end
local function isPrio(ability)
	for k,v in ipairs(spell_table) do
		if select(1, GetSpellInfo(v.spellID))==ability then--find ability in table
			return v.prio--return prio status for ability
		end
	end
	return false
end

local function getTotalPrio(from)
	local ret=0
	if EgcdDB[CharIndex].prio or from then
		for _,v in ipairs(spell_table) do
			if v.prio then
				ret=ret+1
			end
		end
	end
	return ret
end

local function getTotalMain()
	local ret=0
	if EgcdDB[CharIndex].prio then
		for _,v in ipairs(spell_table) do
			if not v.prio then
				ret=ret+1
			end
		end
		return ret
	end
	return #(spell_table)
end

local function Egcd_AddIcons()

	for _,ability in ipairs(spell_table) do--for all spells in spell table
		local name,_,_ = GetSpellInfo(ability.spellID)
		local btn = CreateFrame("Frame",nil,bar)
		btn:SetWidth(30)--create the frame and set the dimensions
		btn:SetHeight(30)
		
		if EgcdDB[CharIndex].prio and isPrio(name) then
			btn:SetPoint("CENTER",bar,"CENTER",x2,y2)
		else
			btn:SetPoint("CENTER",bar,"CENTER",x,y)
		end
			
		btn:SetFrameStrata("LOW")
		local cd = CreateFrame("Cooldown",nil,btn)
		cd.noomnicc = not EgcdDB[CharIndex].noCD
		cd.noOCC = not EgcdDB[CharIndex].noCD
		cd.noCooldownCount = not EgcdDB[CharIndex].noCD
		
		cd:SetAllPoints(true)
		cd:SetFrameStrata("LOW")
		cd:Hide()
		
		local texture = btn:CreateTexture(nil,"BACKGROUND")
		texture:SetAllPoints(true)
		texture:SetTexture(abilities[name].icon)
		texture:SetTexCoord(0.07,0.9,0.07,0.90)
	
		local text = cd:CreateFontString(nil,"ARTWORK")
		text:SetFont(STANDARD_TEXT_FONT,18,"OUTLINE")
		text:SetTextColor(1,1,0,1)
		text:SetPoint("LEFT",btn,"LEFT",1,0)
		
		btn.texture = texture
		btn.text = text
		btn.duration = abilities[name].duration
		btn.cd = cd
		
		if EgcdDB[CharIndex].prio and isPrio(name) then
			bar2[name] = btn
			if (EgcdDB[CharIndex].prioOnly and not isPrio(name)) then bar2[name]:Hide() end
			x2 = x2 + 30 * EgcdDB[CharIndex].growLeft
			count2 = count2 + 1
			totalIcons = totalIcons + 1
			if count2 >= EgcdDB[CharIndex].colsPrio and EgcdDB[CharIndex].colsPrio > 0 then
				y2 = y2 - 30 * EgcdDB[CharIndex].growUp
				x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
				count2=0
			end
		else
			bar[name] = btn
			if (EgcdDB[CharIndex].prioOnly and not isPrio(name)) then bar[name]:Hide() end
			x = x + 30 * EgcdDB[CharIndex].growLeft
			count = count + 1
			totalIcons = totalIcons + 1
			if count >= EgcdDB[CharIndex].cols and EgcdDB[CharIndex].cols > 0 then
				y = y - 30 * EgcdDB[CharIndex].growUp
				x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
				count=0
			end
		end
	end
	x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
	count=0
	y=0
	active=0
	x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
	count2=0
	y2=0
end

local function Egcd_AddIcon(ability)
	if (EgcdDB[CharIndex].prioOnly and not isPrio(ability)) then return end
	if EgcdDB[CharIndex].prio and isPrio(ability) then
		if not bar2[ability]:IsVisible() then
			bar2[ability]:SetPoint("CENTER",bar2,x2,y2)
			bar2[ability]:Show()
			x2 = x2 + 30 * EgcdDB[CharIndex].growLeft
			count2 = count2 + 1
			if count2 >= EgcdDB[CharIndex].colsPrio and EgcdDB[CharIndex].colsPrio > 0 then
				y2 = y2 - 30 * EgcdDB[CharIndex].growUp
				x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
				count2=0
			end
		end
	else
		if not bar[ability]:IsVisible() then
			bar[ability]:SetPoint("CENTER",bar,x,y)
			bar[ability]:Show()
			x = x + 30 * EgcdDB[CharIndex].growLeft
			count = count + 1
			if count >= EgcdDB[CharIndex].cols and EgcdDB[CharIndex].cols > 0 then
				y = y - 30 * EgcdDB[CharIndex].growUp
				x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
				count=0
			end
		end
	end
		local main=getTotalMain()
	if EgcdDB[CharIndex].cols == 0 then
		bar:SetWidth(30*main)
	else
		bar:SetWidth(30*EgcdDB[CharIndex].cols)
	end
	local numprio=getTotalPrio()
	if EgcdDB[CharIndex].prio then
		if EgcdDB[CharIndex].colsPrio == 0 then
			bar2:SetWidth(30*numprio)
		else
			bar2:SetWidth(30*EgcdDB[CharIndex].colsPrio)
		end
	end
end


local function Egcd_SavePosition()
	local point, _, relativePoint, xOfs, yOfs = bar:GetPoint()
	if not EgcdDB[CharIndex].Position then 
		EgcdDB[CharIndex].Position = {}
	end
	--first bar
	EgcdDB[CharIndex].Position.point = point
	EgcdDB[CharIndex].Position.relativePoint = relativePoint
	EgcdDB[CharIndex].Position.xOfs = xOfs
	EgcdDB[CharIndex].Position.yOfs = yOfs
	--second bar
	local point, _, relativePoint, xOfs, yOfs = bar2:GetPoint()
	EgcdDB[CharIndex].Position.point2 = point
	EgcdDB[CharIndex].Position.relativePoint2 = relativePoint
	EgcdDB[CharIndex].Position.xOfs2 = xOfs
	EgcdDB[CharIndex].Position.yOfs2 = yOfs
end

local function Egcd_LoadPosition()
	if EgcdDB[CharIndex].Position then
		bar:SetPoint(EgcdDB[CharIndex].Position.point,UIParent,EgcdDB[CharIndex].Position.relativePoint,EgcdDB[CharIndex].Position.xOfs,EgcdDB[CharIndex].Position.yOfs)
	else
		bar:SetPoint("CENTER", UIParent, "CENTER")
	end
	if EgcdDB[CharIndex].Position and EgcdDB[CharIndex].Position.point2 then
		bar2:SetPoint(EgcdDB[CharIndex].Position.point2,UIParent,EgcdDB[CharIndex].Position.relativePoint2,EgcdDB[CharIndex].Position.xOfs2,EgcdDB[CharIndex].Position.yOfs2)
	else
		bar2:SetPoint("CENTER", UIParent, "CENTER")
	end
end

local function Egcd_Repos()
	if (EgcdDB[CharIndex].bgOnly and not bg and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].bgOnly and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].arenaOnly and EgcdDB[CharIndex].bgOnly and not bg) then return end
	if not EgcdDB[CharIndex].smart then
		x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
		count=0
		y=0
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if not (EgcdDB[CharIndex].prio and isPrio(name)) then
				local name,_,_ = GetSpellInfo(v.spellID)
				bar[name]:Hide()
				Egcd_AddIcon(name)
				if EgcdDB[CharIndex].hidden and not activetimers[name] then
					bar[name]:Hide()
				end
			end
		end
	else 
		if EgcdDB[CharIndex].hidden then
			x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
			count=0
			y=0
		end
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if not(isPrio(name) and EgcdDB[CharIndex].prio) then
				bar[name]:Hide()
				if activetimers[name] then
					Egcd_AddIcon(name)
				else 
					if EgcdDB[CharIndex].hidden then
						bar[name]:Hide()
					end
				end
			end
		end
	end
	if EgcdDB[CharIndex].prio then
		if not EgcdDB[CharIndex].smartPrio then
			x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
			count2 = 0
			y2 = 0
			for _,v in ipairs(spell_table) do
			local name, _, _ = GetSpellInfo(v.spellID)
				if EgcdDB[CharIndex].prio and isPrio(name) then
					bar2[name]:Hide()
					Egcd_AddIcon(name)
					if EgcdDB[CharIndex].hidden2 and not activetimers[name] then
						bar2[k]:Hide()
					end
				end
			end
		else
			if EgcdDB[CharIndex].hidden2 then
				x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
				count2 = 0
				y2 = 0
			end
			for _,v in ipairs(spell_table) do
			local name, _, _ = GetSpellInfo(v.spellID)
				if EgcdDB[CharIndex].prio and isPrio(name) and EgcdDB[CharIndex].hidden2 then
					bar2[k]:Hide()
					if activetimers[name] then
						Egcd_AddIcon(name)
					else
						if EgcdDB[CharIndex].hidden2 then
							bar2[name]:Hide()
						end
					end
				end
			end
		end
	end
end

local function Egcd_UpdateBar()
	bar:SetScale(EgcdDB[CharIndex].scale)
	bar2:SetScale(EgcdDB[CharIndex].scale2)
	
	local main=getTotalMain()
	local numprio=getTotalPrio()
	if EgcdDB[CharIndex].cols == 0 then
		bar:SetWidth(30*main)
	else
		bar:SetWidth(30*EgcdDB[CharIndex].cols)
	end
	if EgcdDB[CharIndex].prio then
		if EgcdDB[CharIndex].colsPrio == 0 then
			bar2:SetWidth(30*numprio)
		else
			bar2:SetWidth(30*EgcdDB[CharIndex].colsPrio)
		end
		bar2:Show()
	end
	if not EgcdDB[CharIndex].prio then--if prio was disabled
		for _,v in ipairs(spell_table) do 
		local name, _, _ = GetSpellInfo(v.spellID)
			if isPrio(name) and bar2[name] then--if spell is prio and on currently on bar2
				bar[name]=bar2[name] --move the spell back to bar1
			end
		end
		bar2:Hide()--hide bar2
	elseif EgcdDB[CharIndex].prio and table.getn(bar2) == 0 then--if prio is on and bar2 is empty
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if EgcdDB[CharIndex].prio and isPrio(name) then--if spell is prio and prio is on
				if bar[name] and not bar2[name] then
					bar2[name]=bar[name]--put spell on bar2
				end
			end
		end
	end
	--if bgonly mode is on, and not in a bg, or arenaonly and not in arena, or bgonly and arenaonly modes and not in bg or arena
	if (EgcdDB[CharIndex].bgOnly and not bg and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].bgOnly and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].arenaOnly and EgcdDB[CharIndex].bgOnly and not bg) then 
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if EgcdDB[CharIndex].prio and isPrio(name) then
				bar2[name]:Hide()--hide spells on prio and main bar
			else
				bar[name]:Hide()
			end
		end
		return
	end
	if EgcdDB[CharIndex].hidden or EgcdDB[CharIndex].hidden2 or EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio then
		if EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio then
			x = 15+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].cols/2)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
			count=0
			y=0
			x2 = 15+((EgcdDB[CharIndex].colsPrio/2)*-30*((EgcdDB[CharIndex].growLeft+1)/2))+((EgcdDB[CharIndex].colsPrio/2-1)*-30*((EgcdDB[CharIndex].growLeft-1)/2))
			y2 = 0
			count2 = 0
		end
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if EgcdDB[CharIndex].prio and isPrio(name) then
				if EgcdDB[CharIndex].hidden2 or EgcdDB[CharIndex].smartPrio then
					bar2[name]:Hide()--hide spells on bar2
				else
					bar2[name]:Show()
				end
				bar2[name].cd.noomnicc = not EgcdDB[CharIndex].noCD
				bar2[name].cd.noOCC = not EgcdDB[CharIndex].noCD--set correct flags to enable/disable omniCC 
				bar2[name].cd.noCooldownCount = not EgcdDB[CharIndex].noCD
				bar2[name]:SetParent(bar2)
			else	
				if EgcdDB[CharIndex].hidden or EgcdDB[CharIndex].smart then
					bar[name]:Hide()--hide spells on main bar
				else
					bar[name]:Show()
				end
				bar[name].cd.noomnicc = not EgcdDB[CharIndex].noCD
				bar[name].cd.noOCC = not EgcdDB[CharIndex].noCD--set correct flags to enable/disable omniCC 
				bar[name].cd.noCooldownCount = not EgcdDB[CharIndex].noCD
				bar[name]:SetParent(bar)
			end
		end
	else--if not hidden or smart
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if EgcdDB[CharIndex].prio and isPrio(name) then
				bar2[name]:Show() --show spell
				bar2[name].cd.noomnicc = not EgcdDB[CharIndex].noCD
				bar2[name].cd.noOCC = not EgcdDB[CharIndex].noCD--set correct flags to enable/disable omniCC 
				bar2[name].cd.noCooldownCount = not EgcdDB[CharIndex].noCD
				bar2[name]:SetParent(bar2)
			else
				bar[name]:Show() 
				bar[name].cd.noomnicc = not EgcdDB[CharIndex].noCD
				bar[name].cd.noOCC = not EgcdDB[CharIndex].noCD
				bar[name].cd.noCooldownCount = not EgcdDB[CharIndex].noCD
				bar[name]:SetParent(bar)
			end
		end
	end
	if EgcdDB[CharIndex].prioOnly then--if prio only
		for _,v in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(v.spellID)
			if not isPrio(name) then--hide non-prio spells
				bar[name]:Hide()
			end
		end
	end
	if EgcdDB[CharIndex].lock then--if bar is locked, disable mouse
		bar:EnableMouse(false)
	else--else, enable mouse
		bar:EnableMouse(true)
	end
	if EgcdDB[CharIndex].lockPrio then
		bar2:EnableMouse(false)
	else
		bar2:EnableMouse(true)
	end
end

local function Egcd_CreateBar()
	bar = CreateFrame("Frame", "EgcdMainBar", UIParent)
	bar:SetMovable(true)
	bar:SetWidth(120)
	bar:SetHeight(30)
	bar:SetClampedToScreen(true) 
	bar:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
	bar:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() Egcd_SavePosition() end end)
	bar:Show()

	bar2 = CreateFrame("Frame", "EgcdPrioBar", UIParent)
	bar2:SetMovable(true)
	bar2:SetWidth(120)
	bar2:SetHeight(30)
	bar2:SetClampedToScreen(true) 
	bar2:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
	bar2:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() Egcd_SavePosition() end end)
	bar2:Show()
	
	Egcd_AddIcons()
	Egcd_UpdateBar()
	Egcd_LoadPosition()
end

local function Egcd_UpdateText(text,cooldown)
if  EgcdDB[CharIndex].noCD then return end
	if cooldown < 100 then 
		if cooldown <= 0.5 then
			text:SetText("")
		elseif cooldown < 10 then
			text:SetFormattedText(" %d",cooldown)
		else
			text:SetFormattedText("%d",cooldown)
		end
	else
		local m=floor((cooldown+30)/60)
		text:SetFormattedText("%dm",m)
	end
	if cooldown < 1 then 
		text:SetTextColor(1,0,0,1)
	else 
		text:SetTextColor(1,1,0,1) 
	end
end

local function Egcd_StopAbility(ref,ability)
	if (EgcdDB[CharIndex].hidden2 and isPrio(ability)) or (EgcdDB[CharIndex].hidden and not isPrio(ability)) then
		if ref then
			ref:Hide()
		else
			if isPrio(ability) and EgcdDB[CharIndex].prio then
				ref=bar2[ability]
			else
				ref=bar[ability]	
			end
		end
	end
	if activetimers[ability] then activetimers[ability] = nil end
	if ref then
		ref.text:SetText("")
		ref.cd:Hide()
	end
	if (EgcdDB[CharIndex].hidden or EgcdDB[CharIndex].hidden2) and (EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio) then Egcd_Repos() end
end

local time = 0
local function Egcd_OnUpdate(self, elapsed)
	time = time + elapsed
	if time > 0.25 then
		getsize()
		for ability,ref in pairs(activetimers) do
			ref.cooldown = ref.start + ref.duration - GetTime()
			if ref.cooldown <= 0 then
				Egcd_StopAbility(ref,ability)
			else 
				Egcd_UpdateText(ref.text,floor(ref.cooldown+0.5))
			end
		end
		if size == 0 then frame:SetScript("OnUpdate",nil) end
		time = time - 0.25
	end
end

local function Egcd_StartTimer(ref,ability)
	if (EgcdDB[CharIndex].bgOnly and not bg and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].bgOnly and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].arenaOnly and EgcdDB[CharIndex].bgOnly and not bg) then return end
	if EgcdDB[CharIndex].hidden or EgcdDB[CharIndex].hidden2 or EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio then
		ref:Show()
	end
	local duration
	activetimers[ability] = ref
	ref.cd:Show()
	ref.cd:SetCooldown(GetTime()-0.1,ref.duration) 	--ref.cd:SetCooldown(GetTime()-0.40,ref.duration)
	ref.start = GetTime()
	Egcd_UpdateText(ref.text,ref.duration)
	frame:SetScript("OnUpdate",Egcd_OnUpdate)
end

local function Egcd_COMBAT_LOG_EVENT_UNFILTERED(...)
	local ability, useSecondDuration
	return function(timestamp, event, sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,id,spellName)
if (band(sourceFlags, 0x00000040) == 0x00000040) and (event == "SPELL_CAST_SUCCESS" or eventtype == "SPELL_AURA_APPLIED" or event == "SPELL_DAMAGE" or event == "SPELL_CAST_FAILED") then
			spellID = id
		else
			return
	end
		if (EgcdDB[CharIndex].prioOnly and not isPrio(spellID)) then return end
		if (EgcdDB[CharIndex].bgOnly and not bg and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].bgOnly and EgcdDB[CharIndex].arenaOnly and not arena) or (not EgcdDB[CharIndex].arenaOnly and EgcdDB[CharIndex].bgOnly and not bg) then return end
		local cold_snap={31687,122,45438}
		local prep={26888,36554,26669, 11305}
		local readiness={19263,19503,34490}
		
		--local name,_,_ = GetSpellInfo(spellID)
		if spellID == 11958 then --cold snap 82676 Ring of Frost -- 44572 Deep Freeze -- 45438 Ice Block
			if EgcdDB[CharIndex].prio and isPrio(ability) then
				for _,abil in ipairs(cold_snap) do
				local name = select(1, GetSpellInfo(abil))
					if activetimers[name] then
						Egcd_StopAbility(bar2[name],name)
					end
				end
			else
				for _,abil in ipairs(cold_snap) do
				local name = select(1, GetSpellInfo(abil))
					if activetimers[name] then
						Egcd_StopAbility(bar[name],name)
					end
				end
			end
		elseif spellID == 14185 then --prep
			if EgcdDB[CharIndex].prio and isPrio(ability) then
				for _,abil in ipairs(prep) do
				local name = select(1, GetSpellInfo(abil))
					if activetimers[name] then
						Egcd_StopAbility(bar2[name],name)
					end
				end
			else
				for _,abil in ipairs(prep) do
				local name = select(1, GetSpellInfo(abil))
					if activetimers[name] then
						Egcd_StopAbility(bar[name],name)
					end
				end
			end
			--[[ 1766  Kick 1856  Vanish 36554 Shadowstep 76577 Smoke Bomb 51722 Dismantle
				Non tracked: Sprint, Smoke Bomb]]
		elseif spellID == 23989 then --readiness
			if EgcdDB[CharIndex].prio and isPrio(ability) then
				for _,abil in ipairs(readiness) do
				local name = select(1, GetSpellInfo(abil))
					if activetimers[name] then
						Egcd_StopAbility(bar2[name],name)
					end
				end
			else
				for _,abil in ipairs(readiness) do
				local name = select(1, GetSpellInfo(abil))
					if activetimers[name] then
						Egcd_StopAbility(bar[name],name)
					end
				end
			end
		end
		useSecondDuration = false

		if abilities[spellName] then	
			if useSecondDuration and spellID == 16979 then
				if EgcdDB[CharIndex].prio and isPrio(spellName) then
					bar2[spellName].duration=30
				else
					bar[spellName].duration=30
				end
			elseif spellID == 16979 then
				if EgcdDB[CharIndex].prio and isPrio(spellName) then
					bar2[spellName].duration=15
				else
					bar[spellName].duration=15
				end
			end
			-- trigger CD after all exceptions have been handled
			if EgcdDB[CharIndex].prio and isPrio(spellName) then
				if EgcdDB[CharIndex].smartPrio then Egcd_AddIcon(spellName) end
				Egcd_StartTimer(bar2[spellName],spellName)
			else
				if EgcdDB[CharIndex].smart then Egcd_AddIcon(spellName) end
				Egcd_StartTimer(bar[spellName],spellName)
			end
		end
	end	
end

Egcd_COMBAT_LOG_EVENT_UNFILTERED = Egcd_COMBAT_LOG_EVENT_UNFILTERED()


local function Egcd_ResetAllTimers()
	for _,ability in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(ability.spellID)
		if EgcdDB[CharIndex].prio and isPrio(name) then
			Egcd_StopAbility(bar2[name],name)
		else
			Egcd_StopAbility(bar[name],name)
		end
	end
	if not (EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio) and not ((EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio) and (EgcdDB[CharIndex].hidden or EgcdDB[CharIndex].hidden2)) then
		Egcd_Repos()
	end

end

local function Egcd_Reset()
	EgcdDB[CharIndex] = EgcdDB[CharIndex] or { scale = 1,scale2=1, hidden = false, hidden2=false, smart=false, smartPrio=false, prio = false, cols=1, colsPrio=1, arenaOnly=false, bgOnly=false, lock = false,lockPrio=false, growUp=1,growLeft=-1 ,noCD=false,  prioOnly=false}
	Egcd_ResetAllTimers()
	Egcd_UpdateBar()
	Egcd_LoadPosition()
end

local function Egcd_PLAYER_ENTERING_WORLD(self)
	arena=isInArena()
	bg=isInBG()
	Egcd_Reset()
end

local function Egcd_Test()
	if (EgcdDB[CharIndex].smart or EgcdDB[CharIndex].smartPrio) and (EgcdDB[CharIndex].hidden or EgcdDB[CharIndex].hidden2) then 
		Egcd_Repos()
	end
	if EgcdDB[CharIndex].prioOnly then 
		for _,ability in ipairs(spell_table) do
			local name, _, _ = GetSpellInfo(ability.spellID)
			if isPrio(name) then
				if EgcdDB[CharIndex].smartPrio then Egcd_AddIcon(name) end
				if EgcdDB[CharIndex].prio then
					Egcd_StartTimer(bar2[name],name)
				else
					Egcd_StartTimer(bar[name],name)
				end
			end
		end
	else
		for _,ability in ipairs(spell_table) do
		local name, _, _ = GetSpellInfo(ability.spellID)
			if EgcdDB[CharIndex].prio and isPrio(name) then
				if EgcdDB[CharIndex].smartPrio then Egcd_AddIcon(name) end
				Egcd_StartTimer(bar2[name],bane)
			else
			if EgcdDB[CharIndex].smart then Egcd_AddIcon(name) end
				Egcd_StartTimer(bar[name],name)
			end
		end
	end
end


local cmdfuncs = {
	status = function() 
		ChatFrame1:AddMessage("Scale - Main Bar(1) = "..EgcdDB[CharIndex].scale.."  Prio Bar(2) = "..EgcdDB[CharIndex].scale2,0,1,1)
		local cd="Disabled"
		if (EgcdDB[CharIndex].hidden) then cd="Enabled"; end
		ChatFrame1:AddMessage("Hidden(1) - "..cd,0,1,1)
		cd="Disabled"
		if (EgcdDB[CharIndex].hidden2) then cd="Enabled"; end
		ChatFrame1:AddMessage("Hidden(2) - "..cd,0,1,1)
		cd="Disabled"
		if (EgcdDB[CharIndex].smart) then cd="Enabled"; end
		ChatFrame1:AddMessage("Smart(1) - "..cd,0,1,1)
		cd="Disabled"
		if (EgcdDB[CharIndex].smartPrio) then cd="Enabled"; end
		ChatFrame1:AddMessage("Smart(2) - "..cd,0,1,1)
		cd="unlocked"
		if (EgcdDB[CharIndex].lock) then cd="locked"; end
		ChatFrame1:AddMessage("Locked(1) - "..cd,0,1,1)
		cd="unlocked"
		if (EgcdDB[CharIndex].lockPrio) then cd="locked"; end
		ChatFrame1:AddMessage("Locked(2) - "..cd,0,1,1)
		cd="Disabled"
		if (EgcdDB[CharIndex].prio) then cd="Enabled"; end
		ChatFrame1:AddMessage("Prio - "..cd,0,1,1)
		cd="Disabled"
		if (EgcdDB[CharIndex].arenaOnly) then cd="Enabled"; end
		ChatFrame1:AddMessage("ArenaOnly - "..cd,0,1,1)
		cd="Disabled"
		if (EgcdDB[CharIndex].bgOnly) then cd="Enabled"; end
		ChatFrame1:AddMessage("BGOnly - "..cd,0,1,1)
		cd="growing down"
		if (EgcdDB[CharIndex].growUp==-1) then cd="growing up"; end
		ChatFrame1:AddMessage("Cooldowns are "..cd.." from the anchor",0,1,1)
		cd="Disabled"
		cd="growing right"
		if (EgcdDB[CharIndex].growLeft==-1) then cd="growing left"; end
		ChatFrame1:AddMessage("Cooldowns are "..cd.." from the anchor",0,1,1)
		cd="Disabled"
		if (not EgcdDB[CharIndex].noCD) then cd="Enabled"; end
		ChatFrame1:AddMessage("Egcd cooldown display is "..cd,0,1,1)
		cd="all spell cooldowns"
		if (EgcdDB[CharIndex].prioOnly) then cd="ONLY priority cooldowns"; end
		ChatFrame1:AddMessage("Displaying "..cd.."(PrioOnly mode="..tostring(EgcdDB[CharIndex].prioOnly)..")",0,1,1)
		ChatFrame1:AddMessage("Columns per row:  Main Bar(1) = "..EgcdDB[CharIndex].cols.."  Prio Bar(2) = "..EgcdDB[CharIndex].colsPrio,0,1,1)
	end,
	scale = function(id,v,from) 
		if not id or not v then 
			ChatFrame1:AddMessage("USAGE: scale <bar ID> <number>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			ChatFrame1:AddMessage("Current settings: Main Bar(1) = "..EgcdDB[CharIndex].scale.."  Prio Bar(2) = "..EgcdDB[CharIndex].scale2,0,1,0)
			return
		end
		if ((id == 1 or id == 2) and v >= 0) then 
			if id==1 then
				EgcdDB[CharIndex].scale = v
			elseif id == 2 then
				EgcdDB[CharIndex].scale2=v
			end
			if not from then
				ChatFrame1:AddMessage("Scale for bar"..id.." set to"..v,0,1,0)
			end
			Egcd_UpdateBar()
			return
		end
		if not from then
			ChatFrame1:AddMessage("USAGE: scale <bar ID> <number>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			ChatFrame1:AddMessage("Current settings: Main Bar(1) = "..EgcdDB[CharIndex].scale.."  Prio Bar(2) = "..EgcdDB[CharIndex].scale2,0,1,0)
		end
	end,
	hidden = function(id,from) 
		if not id then 
			ChatFrame1:AddMessage("USAGE: hidden <bar ID>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			return
		end
		if ((id == 1 or id == 2)) then 
			local cd="Disabled"
			if id == 1 then
				EgcdDB[CharIndex].hidden = not EgcdDB[CharIndex].hidden
				if (EgcdDB[CharIndex].hidden) then cd="Enabled"; end
			elseif id == 2 then
				EgcdDB[CharIndex].hidden2 = not EgcdDB[CharIndex].hidden2
				if (EgcdDB[CharIndex].hidden2) then cd="Enabled"; end
			end
			if not from then
				ChatFrame1:AddMessage("Egcd hidden("..id..") mode is now "..cd,0,1,1)
				ChatFrame1:AddMessage("Enabled = Spells are hidden when not on cooldown",0,1,0)
				ChatFrame1:AddMessage("Disabled = Spells are always visible",0,1,0)
				ChatFrame1:AddMessage("Note: If Smart & Hidden mode are enabled, the cooldowns realign to the anchor when off cooldown",0,1,0)
			end
			Egcd_UpdateBar() 
			Egcd_Repos() 
		end
	end,
	smart = function(id,from) 
		if not id then 
			ChatFrame1:AddMessage("USAGE: smart <bar ID>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			return
		end
		local cd="Disabled"
		if ((id == 1 or id == 2)) then 
			if id == 1 then
				EgcdDB[CharIndex].smart = not EgcdDB[CharIndex].smart
				if (EgcdDB[CharIndex].smart) then cd="Enabled"; end
			elseif id == 2 then
				EgcdDB[CharIndex].smartPrio = not EgcdDB[CharIndex].smartPrio
				if (EgcdDB[CharIndex].smartPrio) then cd="Enabled"; end
			end
		end
		if not from then
			ChatFrame1:AddMessage("Egcd smart mode is now "..cd,0,1,1)
			ChatFrame1:AddMessage("Enabled = Spells are only displayed once used and in the order they're used",0,1,0)
			ChatFrame1:AddMessage("Disabled = Spells are always displayed in the same order",0,1,0)
			ChatFrame1:AddMessage("Note: If Smart & Hidden mode are enabled, the cooldowns realign to the anchor when off cooldown",0,1,0)
		end
		Egcd_Reset() 
	end,
	lock = function(id,from) 
		if not id then 
			ChatFrame1:AddMessage("USAGE: lock <bar ID>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			return
		end
		if ((id == 1 or id == 2)) then 
			local cd="unlocked"
			if id == 1 then
				EgcdDB[CharIndex].lock = not EgcdDB[CharIndex].lock
				if (EgcdDB[CharIndex].hidden) then cd="locked"; end
			elseif id == 2 then
				EgcdDB[CharIndex].lockPrio = not EgcdDB[CharIndex].lockPrio
				if (EgcdDB[CharIndex].lockPrio) then cd="locked"; end
			end
			if not from then ChatFrame1:AddMessage("Egcd bar"..id.." is now "..cd,0,1,1) end
		end
		if not from then
			ChatFrame1:AddMessage("Locked = Bars can't be moved",0,1,0)
			ChatFrame1:AddMessage("Unlocked = Bars can be moved",0,1,0)
		end
		Egcd_UpdateBar()
	end,
	prio = function(from) 
		EgcdDB[CharIndex].prio = not EgcdDB[CharIndex].prio
		if not from then
			local cd="Disabled"
			if (EgcdDB[CharIndex].prio) then cd="Enabled"; end
			ChatFrame1:AddMessage("Egcd Prio bar is now "..cd,0,1,1)
			ChatFrame1:AddMessage("Enabled = A second bar is created, displaying priority spells",0,1,0)
			ChatFrame1:AddMessage("Disabled = Egcd displays all spells on the main bar",0,1,0)
		end
		local temp1=EgcdDB[CharIndex].smart
		local temp2=EgcdDB[CharIndex].smartPrio

		Egcd_UpdateBar()
		EgcdDB[CharIndex].smartPrio=false
		EgcdDB[CharIndex].smart=false
		Egcd_Repos() 
		EgcdDB[CharIndex].smart=temp1
		EgcdDB[CharIndex].smartPrio=temp2
		Egcd_UpdateBar()
	end,
	arenaonly = function(from) 
		EgcdDB[CharIndex].arenaOnly = not EgcdDB[CharIndex].arenaOnly
		if not from then 
			local cd="Disabled"
			if (EgcdDB[CharIndex].arenaOnly) then cd="Enabled"; end
			ChatFrame1:AddMessage("Egcd Arena Only mode is now "..cd,0,1,1)
			ChatFrame1:AddMessage("Enabled = Egcd is displayed ONLY in Arenas",0,1,0)
			ChatFrame1:AddMessage("Disabled = Egcd is displayed outside of Arenas",0,1,0)
			ChatFrame1:AddMessage("Note: If BGOnly & ArenaOnly are enabled, it will work in Arenas and BGs",0,1,0)
		end
		Egcd_Reset() 
	end,
	bgonly = function(from) 
		EgcdDB[CharIndex].bgOnly = not EgcdDB[CharIndex].bgOnly
		if not from then 
			local cd="Disabled"
			if (EgcdDB[CharIndex].bgOnly) then cd="Enabled"; end
			ChatFrame1:AddMessage("Egcd BG Only mode is now "..cd,0,1,1)
			ChatFrame1:AddMessage("Enabled = Egcd is displayed ONLY in Battlegrounds",0,1,0)
			ChatFrame1:AddMessage("Disabled = Egcd is displayed outside of Battlegrounds",0,1,0)
			ChatFrame1:AddMessage("Note: If BGOnly & ArenaOnly are enabled, it will work in Arenas and BGs",0,1,0)
		end
		Egcd_Reset() 
	end,
	growup=function(from) 		
		EgcdDB[CharIndex].growUp=EgcdDB[CharIndex].growUp*-1
		if not from then 
			local text="growing down"
			if (EgcdDB[CharIndex].growUp==-1) then text="growing up"; end
			ChatFrame1:AddMessage("Egcd cooldowns are "..text.." from the anchor",0,1,1)
		end
		Egcd_Repos()
		end,
	growleft=function(from) 		
		EgcdDB[CharIndex].growLeft=EgcdDB[CharIndex].growLeft*-1
		if not from then 
			local text="growing right"
			if (EgcdDB[CharIndex].growLeft==-1) then text="growing left"; end
			ChatFrame1:AddMessage("Egcd cooldows are "..text.." from the anchor",0,1,1)
		end
		Egcd_Repos()
		end,
	nocd=function(from) 
		EgcdDB[CharIndex].noCD = not EgcdDB[CharIndex].noCD
		if not from then 
			local cd="Disabled"
			if (not EgcdDB[CharIndex].noCD) then cd="Enabled"; end
			ChatFrame1:AddMessage("Egcd cooldown display is now "..cd,0,1,1)
			ChatFrame1:AddMessage("Enabled = Egcd displays text",0,1,0)
			ChatFrame1:AddMessage("Disabled = Egcd displays no text, OmniCC can be used",0,1,0)
		end
		Egcd_Reset()
	end,
	prioonly=function(from)
		EgcdDB[CharIndex].prioOnly=not EgcdDB[CharIndex].prioOnly
		if not from then
			local cd="all spell cooldowns"
			if (EgcdDB[CharIndex].prioOnly) then cd="ONLY priority cooldowns"; end
			ChatFrame1:AddMessage("Egcd is now displaying "..cd,0,1,1)
		end
		Egcd_Reset()  
	end,
	opts=function()
		InterfaceOptionsFrame_OpenToFrame(Egcd.mainpanel);
	end,
	gui=function()
		InterfaceOptionsFrame_OpenToFrame(Egcd.mainpanel);
	end,
	config=function()
		InterfaceOptionsFrame_OpenToFrame(Egcd.mainpanel);
	end,
	cols = function(id,v,from) 
		if not id or not v then 
			ChatFrame1:AddMessage("USAGE: cols <bar ID> <number>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			ChatFrame1:AddMessage("Current settings: Main Bar(1) = "..EgcdDB[CharIndex].cols.."  Prio Bar(2) = "..EgcdDB[CharIndex].colsPrio,0,1,0)
			return
		end
		if ((id == 1 or id == 2) and v >= 0) then 
			if id==1 then
				if (v==0) then
					EgcdDB[CharIndex].cols = getTotalMain()
				else
					EgcdDB[CharIndex].cols = v
				end
			elseif id==2 then
				if (v==0) then
					EgcdDB[CharIndex].colsPrio = getTotalPrio()
				else
					EgcdDB[CharIndex].colsPrio = v
				end
			end
			if not from then
				ChatFrame1:AddMessage("Cols for bar"..id.." set to "..v,0,1,0)
			end
			Egcd_Repos()
			return	
		end
		if not from then
			ChatFrame1:AddMessage("USAGE: /Egcd cols <bar ID> <number>",0,1,0)
			ChatFrame1:AddMessage("Bar IDs: Main bar = 1   Prio Bar = 2",0,1,0)
			ChatFrame1:AddMessage("Current settings: Main Bar(1) = "..EgcdDB[CharIndex].cols.."  Prio Bar(2) = "..EgcdDB[CharIndex].colsPrio,0,1,0)
			ChatFrame1:AddMessage("Example: set main bar cols to 6: /Egcd cols 1 6",0,1,0)
		end
	end,
	reset = function() Egcd_Reset() end,
	test = function() Egcd_Test() end,
}

local cmdtbl = {}
function Egcd_Command(cmd)
	for k in ipairs(cmdtbl) do
		cmdtbl[k] = nil
	end
	for v in gmatch(cmd, "[%d|%a|.]+") do
		tinsert(cmdtbl, v)
	end
  local cb = cmdfuncs[cmdtbl[1]] 
  if cb then
  	local s = tonumber(cmdtbl[2])
  	local ss = tonumber(cmdtbl[3])
  	cb(s,ss)
  else
	ChatFrame1:AddMessage("Egcd Help",0,1,0)
	ChatFrame1:AddMessage("config - Display current value of options",0,1,0)
	ChatFrame1:AddMessage("scale <bar ID> <number> - Sets the scale factor for the given bar",0,1,0)
  	ChatFrame1:AddMessage("hidden <bar ID> (toggle) - Hides spell icons when off cooldown",0,1,0)
	ChatFrame1:AddMessage("smart <bar ID>(toggle) - Only show CD when used",0,1,0)
  	ChatFrame1:AddMessage("lock <bar ID>(toggle) - Locks the bars in place",0,1,0)
	ChatFrame1:AddMessage("growup (toggle) - The icons grow upwards from the anchor if enabled",0,1,0)
	ChatFrame1:AddMessage("growleft (toggle) - The icons grow left from the anchor if enabled",0,1,0)
	ChatFrame1:AddMessage("prio (toggle) - Displays second anchor with priority spells",0,1,0)
	ChatFrame1:AddMessage("arenaonly (toggle) - Only display cooldowns if in an arena",0,1,0)
	ChatFrame1:AddMessage("bgonly (toggle) - Only display cooldowns if in a battleground",0,1,0)
	ChatFrame1:AddMessage("prioonly (toggle) - Only displays priority cooldowns",0,1,0)
	ChatFrame1:AddMessage("nocd (toggle) - Disables the Egcd cooldown text and allows omniCC",0,1,0)
	ChatFrame1:AddMessage("cols <bar ID> <num> (0 = 1 row) - Set number of spells per row for the given bar",0,1,0)
  	ChatFrame1:AddMessage("test - Activates all cooldowns to test Egcd",0,1,0)
  	ChatFrame1:AddMessage("reset - Resets all cooldowns",0,1,0)
  end
end

local function Egcd_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if not EgcdDB then
		EgcdDB={}
	end
	EgcdDB["Default"]= EgcdDB["Default"] or { scale = 1, scale2 = 1, hidden = true, hidden2 = true, smart = true, smartPrio=true, prio = true, cols=1, colsPrio=1, arenaOnly=true, bgOnly=false, lock = false, growUp=0, growLeft=0, noCD=false, prioOnly=false,}
	EgcdDB["CharsUse"]=EgcdDB["CharsUse"] or {}
	
	if (EgcdDB["CharsUse"][CharIndex]) then
		if (EgcdDB[EgcdDB["CharsUse"][CharIndex]]) then
			CharIndex=EgcdDB["CharsUse"][CharIndex]
		else
			EgcdDB["CharsUse"][CharIndex]=CharIndex
			if not EgcdDB[CharIndex] then
				EgcdDB[CharIndex]=EgcdDB["Default"]
			end
		end	
	else
		EgcdDB["CharsUse"][CharIndex]=CharIndex
		if not EgcdDB[CharIndex] then
			EgcdDB[CharIndex]=EgcdDB["Default"]
		end
	end
	for k,v in pairs(EgcdDB) do
		if not (type(EgcdDB[k]) == "table" ) then 
			EgcdDB[k]=nil
		elseif (k=="Position" and (EgcdDB["Position"]["scale2"]==nil)) then 
			EgcdDB[k]=nil
		end
	end
	
	Egcd_CreateBar()
	Egcd_SavePosition()
	
	SlashCmdList["Egcd"] = Egcd_Command
	SLASH_Egcd1 = "/Egcd"
	DEFAULT_CHAT_FRAME:AddMessage("|cff77FF24Enemy global cooldown|r by |cff835EF0Drainlock|r. Type |cff77FF24/Egcd|r for options.")
end

local eventhandler = {
	["VARIABLES_LOADED"] = function(self) Egcd_OnLoad(self) end,
	["PLAYER_ENTERING_WORLD"] = function(self) Egcd_PLAYER_ENTERING_WORLD(self) end,
	["COMBAT_LOG_EVENT_UNFILTERED"] = function(self,...) Egcd_COMBAT_LOG_EVENT_UNFILTERED(...) end,
}

local function Egcd_OnEvent(self,event,...)
	eventhandler[event](self,...)
end

frame = CreateFrame("Frame","EgcdMainFrame",UIParent)
frame:SetScript("OnEvent",Egcd_OnEvent)
frame:RegisterEvent("VARIABLES_LOADED")

Egcd = {};
Egcd.mainpanel = CreateFrame( "Frame", "EgcdMainPanel", UIParent );
Egcd.mainpanel.name = "Egcd";
local title = Egcd.mainpanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 20, -10)
title:SetText("Egcd")
local subtitle = Egcd.mainpanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetPoint("RIGHT", Egcd.mainpanel, -32, 0)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("General options for Egcd")

local buttonPositionY = -60;
local buttonPositionX = 20;

local t = {"prio","prioOnly","arenaOnly","bgOnly","nocd","growLeft","growUp"};
local general_cmd_table={cmdfuncs["prio"],cmdfuncs["prioonly"],cmdfuncs["arenaonly"],cmdfuncs["bgonly"],cmdfuncs["nocd"],cmdfuncs["growleft"],cmdfuncs["growup"]};
local t2 = {"Show Priority bar","Priority Bar Only", "Display Only in Arenas","Display Only in Battlegrounds","Hide Egcd cooldown time","Grow icons left from the anchor","Grow icons up from the anchor"};
for i,v in ipairs (t) do
	local Egcd_IconOptions_CheckButton = CreateFrame("CheckButton", "Egcd_Button_"..v, Egcd.mainpanel, "OptionsCheckButtonTemplate");
	Egcd_IconOptions_CheckButton:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);
	getglobal(Egcd_IconOptions_CheckButton:GetName().."Text"):SetText(t2[i]);

	local function Egcd_IconOptions_CheckButton_OnClick()
			general_cmd_table[i](1,"gui")
	end

	local function Egcd_IconOptions_CheckButton_OnShow()
		if (v == "growLeft" or v == "growUp") then
			Egcd_IconOptions_CheckButton:SetChecked(EgcdDB[CharIndex][v]==-1);
		else
			Egcd_IconOptions_CheckButton:SetChecked(EgcdDB[CharIndex][v]);
		end
	end

	Egcd_IconOptions_CheckButton:RegisterForClicks("AnyUp");
	Egcd_IconOptions_CheckButton:SetScript("OnClick", Egcd_IconOptions_CheckButton_OnClick);
	Egcd_IconOptions_CheckButton:SetScript("OnShow", Egcd_IconOptions_CheckButton_OnShow);
	buttonPositionY = buttonPositionY - 30;
end

-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(Egcd.mainpanel);
-- Make a child panel
Egcd.mainbarpanel = CreateFrame( "Frame", "MainBarPanel", Egcd.mainpanel);
Egcd.mainbarpanel.name = "Main Bar";
-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
Egcd.mainbarpanel.parent = Egcd.mainpanel.name;
			
local title = Egcd.mainbarpanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 20, -10)
title:SetText("Main Bar Options")

local subtitle = Egcd.mainbarpanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetPoint("RIGHT", Egcd.mainbarpanel, -32, 0)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("Options for Egcd Main Bar")	

buttonPositionY = -60;
buttonPositionX = 20;

-- Main bar options
local t = {"hidden","smart","lock"};
local bar_cmd_table={cmdfuncs["hidden"],cmdfuncs["smart"],cmdfuncs["lock"]};
local t2 = {"Hide Icons","Smart", "Lock frame"};
for i,v in ipairs (t) do
	local Egcd_IconOptions_CheckButton = CreateFrame("CheckButton", "Egcd_Button_"..v, Egcd.mainbarpanel, "OptionsCheckButtonTemplate");
	Egcd_IconOptions_CheckButton:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);
	getglobal(Egcd_IconOptions_CheckButton:GetName().."Text"):SetText(t2[i]);

	local function Egcd_IconOptions_CheckButton_OnClick()
			bar_cmd_table[i](1,"gui")
	end

	local function Egcd_IconOptions_CheckButton_OnShow()
		Egcd_IconOptions_CheckButton:SetChecked(EgcdDB[CharIndex][v]);
	end

	Egcd_IconOptions_CheckButton:RegisterForClicks("AnyUp");
	Egcd_IconOptions_CheckButton:SetScript("OnClick", Egcd_IconOptions_CheckButton_OnClick);
	Egcd_IconOptions_CheckButton:SetScript("OnShow", Egcd_IconOptions_CheckButton_OnShow);
	buttonPositionY = buttonPositionY - 30;
end
local tsliders = {"cols","scale"};
local slider_table={cmdfuncs["cols"],cmdfuncs["scale"]};
local slidert2 = {"Number of cols","Scale (default 1.0)" };
buttonPositionY = buttonPositionY - 30;
for i,v in ipairs (tsliders) do
	local Egcd_IconOptions_Slider = CreateFrame("Slider", "Egcd_Slider_"..v, Egcd.mainbarpanel, "OptionsSliderTemplate");
	Egcd_IconOptions_Slider:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);
	getglobal(Egcd_IconOptions_Slider:GetName() .. 'Low'):SetText('-');
	getglobal(Egcd_IconOptions_Slider:GetName() .. 'High'):SetText('+');
	getglobal(Egcd_IconOptions_Slider:GetName() .. 'Text'):SetText(slidert2[i].."\nValue: "..EgcdDB[CharIndex][v]);

	if (v == "cols") then
		Egcd_IconOptions_Slider:SetMinMaxValues(0,#(spell_table));
		Egcd_IconOptions_Slider:SetValueStep(1.0);
	elseif (v == "scale") then
		Egcd_IconOptions_Slider:SetMinMaxValues(0.1,2.0);
		Egcd_IconOptions_Slider:SetValueStep(0.1);
	end
	
	local function Egcd_IconOptions_Slider_OnShow()
		Egcd_IconOptions_Slider:SetValue(EgcdDB[CharIndex][v]);
	end

	local function Egcd_IconOptions_Slider_OnValueChanged()
		slider_table[i](1,Egcd_IconOptions_Slider:GetValue(),"gui");
		getglobal(Egcd_IconOptions_Slider:GetName() .. 'Text'):SetText(slidert2[i].."\nValue: "..EgcdDB[CharIndex][v]);
	end

	Egcd_IconOptions_Slider:SetScript("OnValueChanged", Egcd_IconOptions_Slider_OnValueChanged);
	Egcd_IconOptions_Slider:SetScript("OnShow", Egcd_IconOptions_Slider_OnShow);
	buttonPositionY = buttonPositionY - 60;
end

InterfaceOptions_AddCategory(Egcd.mainbarpanel);
-- Make a child panel
Egcd.priobarpanel = CreateFrame( "Frame", "PrioBarPanel", Egcd.mainpanel);
Egcd.priobarpanel.name = "Prio Bar";
-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
Egcd.priobarpanel.parent = Egcd.mainpanel.name;

local title = Egcd.priobarpanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 20, -10)
title:SetText("Prio Bar Options")

local subtitle = Egcd.priobarpanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetPoint("RIGHT", Egcd.priobarpanel, -32, 0)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("Options for Egcd Prio Bar")	

buttonPositionY = -60;
buttonPositionX = 20;
local priot = {"hidden2","smartPrio","lockPrio"};
for i,v in ipairs (priot) do
	local Egcd_IconOptions_CheckButton = CreateFrame("CheckButton", "Egcd_Button_"..v, Egcd.priobarpanel, "OptionsCheckButtonTemplate");
	Egcd_IconOptions_CheckButton:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);
	getglobal(Egcd_IconOptions_CheckButton:GetName().."Text"):SetText(t2[i]);

	local function Egcd_IconOptions_CheckButton_OnClick()
			bar_cmd_table[i](2,"gui")
	end

	local function Egcd_IconOptions_CheckButton_OnShow()
		Egcd_IconOptions_CheckButton:SetChecked(EgcdDB[CharIndex][v]);
	end

	Egcd_IconOptions_CheckButton:RegisterForClicks("AnyUp");
	Egcd_IconOptions_CheckButton:SetScript("OnClick", Egcd_IconOptions_CheckButton_OnClick);
	Egcd_IconOptions_CheckButton:SetScript("OnShow", Egcd_IconOptions_CheckButton_OnShow);

	buttonPositionY = buttonPositionY - 30;
end
tsliders = {"colsPrio","scale2"};
buttonPositionY = buttonPositionY - 30;
for i,v in ipairs (tsliders) do
	local Egcd_IconOptions_Slider = CreateFrame("Slider", "Egcd_Slider_"..v, Egcd.priobarpanel, "OptionsSliderTemplate");
	Egcd_IconOptions_Slider:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);

	getglobal(Egcd_IconOptions_Slider:GetName() .. 'Low'):SetText('-');
	getglobal(Egcd_IconOptions_Slider:GetName() .. 'High'):SetText('+');
	getglobal(Egcd_IconOptions_Slider:GetName() .. 'Text'):SetText(slidert2[i].."\nValue: "..EgcdDB[CharIndex][v]);
	
	if (v == "colsPrio") then
		local val = getTotalPrio("gui");
		Egcd_IconOptions_Slider:SetMinMaxValues(0,val+1);
		Egcd_IconOptions_Slider:SetValueStep(1.0);
	elseif (v == "scale2") then
		
		Egcd_IconOptions_Slider:SetMinMaxValues(0.1,2.0);
		Egcd_IconOptions_Slider:SetValueStep(0.1);
	end
	
	local function Egcd_IconOptions_Slider_OnShow()
		Egcd_IconOptions_Slider:SetValue(EgcdDB[CharIndex][v]);
	end

	local function Egcd_IconOptions_Slider_OnValueChanged()
		slider_table[i](2,Egcd_IconOptions_Slider:GetValue(),"gui");
		getglobal(Egcd_IconOptions_Slider:GetName() .. 'Text'):SetText(slidert2[i].."\nValue: "..EgcdDB[CharIndex][v]);
	end

	Egcd_IconOptions_Slider:SetScript("OnValueChanged", Egcd_IconOptions_Slider_OnValueChanged);
	Egcd_IconOptions_Slider:SetScript("OnShow", Egcd_IconOptions_Slider_OnShow);

	buttonPositionY = buttonPositionY - 60;
end
InterfaceOptions_AddCategory(Egcd.priobarpanel);


-- Make a child panel
Egcd.profilepanel = CreateFrame( "Frame", "ProfilePanel", Egcd.mainpanel);
Egcd.profilepanel.name = "Profiles";
-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
Egcd.profilepanel.parent = Egcd.mainpanel.name;

local title = Egcd.profilepanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 20, -10)
title:SetText("Prio Bar Options")

local subtitle = Egcd.profilepanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetPoint("RIGHT", Egcd.profilepanel, -32, 0)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("Egcd Profile Options")	

buttonPositionY = -60;
buttonPositionX = 20;
local UsingProfileLabel = Egcd.profilepanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
UsingProfileLabel:SetHeight(32)
UsingProfileLabel:SetPoint("TOPLEFT", buttonPositionX,buttonPositionY)
UsingProfileLabel:SetNonSpaceWrap(true)
UsingProfileLabel:SetJustifyH("LEFT")
UsingProfileLabel:SetJustifyV("TOP")
UsingProfileLabel:SetText("Currently using: "..CharIndex)	


buttonPositionY=-100
local Egcd_Options_EditBox = CreateFrame("EditBox", "Egcd_NewProfile_NewID", Egcd.profilepanel, "InputBoxTemplate");
Egcd_Options_EditBox:SetPoint("TOPLEFT", buttonPositionX+5,buttonPositionY);
Egcd_Options_EditBox:SetWidth(125);
Egcd_Options_EditBox:SetHeight(32);
Egcd_Options_EditBox:EnableMouse(true);
Egcd_Options_EditBox:SetAutoFocus(false);
Egcd_Options_EditBox_Text = Egcd_Options_EditBox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall');
Egcd_Options_EditBox_Text:SetPoint("TOPLEFT", -3, 10);
Egcd_Options_EditBox_Text:SetText("New Profile Name");


-- New Profile Save Button
local Egcd_CreateProfile_SaveButton = CreateFrame("Button", "Egcd_ProfileSaveButton",Egcd.profilepanel, "OptionsButtonTemplate");
Egcd_CreateProfile_SaveButton:SetPoint("TOPLEFT",buttonPositionX+130,buttonPositionY-5);
Egcd_CreateProfile_SaveButton:SetWidth(50);
Egcd_CreateProfile_SaveButton:SetHeight(21);
Egcd_CreateProfile_SaveButton:SetText("Save");

local function CreateNewProfile()
	EgcdDB[Egcd_Options_EditBox:GetText()]=EgcdDB[Egcd_Options_EditBox:GetText()] or { scale = 1,scale2=1 , hidden = false,hidden2=false, smart=false, smartPrio=false,prio = false, cols=1, colsPrio=1, arenaOnly=false, bgOnly=false, lock = false,growUp=1,growLeft=1, noCD=false,prioOnly=false,}
	Egcd_Options_EditBox:SetText("")
end
Egcd_CreateProfile_SaveButton:SetScript("OnClick", CreateNewProfile)


buttonPositionX = buttonPositionX+195
buttonPositionY = -100
local subtitle = Egcd.profilepanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", buttonPositionX+10,buttonPositionY+15)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("Use Profile...")
if not DropDownMenuUse then
   CreateFrame("Button", "DropDownMenuUse", Egcd.profilepanel, "UIDropDownMenuTemplate")
end
 
DropDownMenuUse:ClearAllPoints()
DropDownMenuUse:SetPoint("TOPLEFT", buttonPositionX-10, buttonPositionY)
DropDownMenuUse:Show()
 
local items = {}

local function OnClick(self)
   UIDropDownMenu_SetSelectedID(DropDownMenuUse, self:GetID())
   EgcdDB["CharsUse"][EgcdChar.." - "..EgcdRealm]=self:GetText()
   CharIndex=self:GetText()
   UsingProfileLabel:SetText("Currently using: "..CharIndex)
   Egcd_Reset()
end
 
local function initialize(self, level)
items = {};
 	for k,v in pairs(EgcdDB) do
		if (type(EgcdDB[k]) == "table" and not(k =="CharsUse")) then table.insert(items,k) end
	end
   local info = UIDropDownMenu_CreateInfo()
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
   end
end

UIDropDownMenu_Initialize(DropDownMenuUse, initialize)
UIDropDownMenu_SetWidth(160, DropDownMenuUse);
UIDropDownMenu_SetButtonWidth(180, DropDownMenuUse)
UIDropDownMenu_SetSelectedID(DropDownMenuUse, 1)
UIDropDownMenu_JustifyText("LEFT", DropDownMenuUse)

buttonPositionX = 5
buttonPositionY = buttonPositionY -60

local subtitle = Egcd.profilepanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", buttonPositionX+20,buttonPositionY+15)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("Copy From...")

if not DropDownMenuCopy then
   CreateFrame("Button", "DropDownMenuCopy", Egcd.profilepanel, "UIDropDownMenuTemplate")
end

DropDownMenuCopy:ClearAllPoints()
DropDownMenuCopy:SetPoint("TOPLEFT", buttonPositionX, buttonPositionY)
DropDownMenuCopy:Show()
 
local function OnClick(self)
   UIDropDownMenu_SetSelectedID(DropDownMenuCopy, self:GetID())
   EgcdDB[EgcdChar.." - "..EgcdRealm]=EgcdDB[self:GetText()]
   CharIndex=EgcdChar.." - "..EgcdRealm
   UsingProfileLabel:SetText("Currently using: "..CharIndex)
   Egcd_Reset()
end
 
local function initialize(self, level)
items = {};
 	for k,v in pairs(EgcdDB) do
		if (type(EgcdDB[k]) == "table" and not(k =="CharsUse")) then table.insert(items,k) end
	end
   local info = UIDropDownMenu_CreateInfo()
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
   end
end
 
UIDropDownMenu_Initialize(DropDownMenuCopy, initialize)
UIDropDownMenu_SetWidth(160, DropDownMenuCopy);
UIDropDownMenu_SetButtonWidth(180, DropDownMenuCopy)
UIDropDownMenu_SetSelectedID(DropDownMenuCopy, 1)
UIDropDownMenu_JustifyText("LEFT", DropDownMenuCopy)

buttonPositionX = buttonPositionX+220

local subtitle = Egcd.profilepanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetHeight(32)
subtitle:SetPoint("TOPLEFT", buttonPositionX,buttonPositionY+15)
subtitle:SetNonSpaceWrap(true)
subtitle:SetJustifyH("LEFT")
subtitle:SetJustifyV("TOP")
subtitle:SetText("Delete Profile")

if not DropDownMenuDel then
   CreateFrame("Button", "DropDownMenuDel", Egcd.profilepanel, "UIDropDownMenuTemplate")
end

DropDownMenuDel:ClearAllPoints()
DropDownMenuDel:SetPoint("TOPLEFT", buttonPositionX-20, buttonPositionY)
DropDownMenuDel:Show()
 
local function OnClick(self)
	EgcdDB[self:GetText()]=nil
	if (CharIndex == self:GetText()) then
		if ((EgcdChar.." - "..EgcdRealm)==self:GetText()) then
			EgcdDB["CharsUse"][EgcdChar.." - "..EgcdRealm]="Default"
			CharIndex="Default"
		else
			CharIndex=EgcdChar.." - "..EgcdRealm
			if not EgcdDB[CharIndex] then
				EgcdDB[CharIndex] = EgcdDB["Default"]
			end
			EgcdDB["CharsUse"][CharIndex]=CharIndex
		end
		UsingProfileLabel:SetText("Currently using: "..CharIndex)	
	end
	items = {};
 	for k,v in pairs(EgcdDB) do
		if (type(EgcdDB[k]) == "table" and not(k =="CharsUse")and not (k == "Default")) then table.insert(items,k) end
	end
	Egcd_Reset()
end
 
local function initialize(self, level)
items = {};
 	for k,v in pairs(EgcdDB) do
		if (type(EgcdDB[k]) == "table" and not(k =="CharsUse")and not (k == "Default")) then table.insert(items,k) end
	end
	local info = UIDropDownMenu_CreateInfo()
	for k,v in pairs(items) do
		info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.value = v
		info.func = OnClick
		UIDropDownMenu_AddButton(info, level)
	end
end
	
UIDropDownMenu_Initialize(DropDownMenuDel, initialize)
UIDropDownMenu_SetWidth(160, DropDownMenuDel);
UIDropDownMenu_SetButtonWidth(180, DropDownMenuDel)
UIDropDownMenu_SetSelectedID(DropDownMenuDel, 1)
UIDropDownMenu_JustifyText("LEFT", DropDownMenuDel)
-- Add the child to the Interface Options
InterfaceOptions_AddCategory(Egcd.profilepanel);