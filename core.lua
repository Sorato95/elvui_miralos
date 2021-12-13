local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_Miralos = E:NewModule('ElvUI_Miralos', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

function ElvUI_Miralos:Update()
	for groupName in pairs(UF.headers) do  
        local group = UF[groupName]
        
        if group.GetNumChildren then
            for i=1, group:GetNumChildren() do
                local frame = select(i, group:GetChildren())
                
                if frame and frame.Health then
                    FrameGlow_UpdateSingleFrame(frame)
                elseif frame then
                    for n = 1, frame:GetNumChildren() do
                        local child = select(n, frame:GetChildren())
                        if child and child.Health then
                            FrameGlow_UpdateSingleFrame(child)
                        end
                    end
                end
            end
        end
    end
end

function FrameGlow_UpdateSingleFrame(frame)
	if frame.TargetGlow then
		local color = E.db.unitframe.colors.frameGlow.targetGlow.color;
		frame.TargetGlow:Point("TOPLEFT", -E.db.unitframe.colors.frameGlow.targetGlow.size, E.db.unitframe.colors.frameGlow.targetGlow.size)
		frame.TargetGlow:Point("TOPRIGHT", E.db.unitframe.colors.frameGlow.targetGlow.size-1, E.db.unitframe.colors.frameGlow.targetGlow.size-1)
		frame.TargetGlow:Point("BOTTOMLEFT", -E.db.unitframe.colors.frameGlow.targetGlow.size, -E.db.unitframe.colors.frameGlow.targetGlow.size)
		--frame.TargetGlow:SetFrameLevel(0)
		if E.db.unitframe.colors.frameGlow.targetGlow.foreground == true then
			frame.TargetGlow:SetFrameStrata("MEDIUM")
		else 
			frame.TargetGlow:SetFrameStrata("BACKGROUND")
		end
		
		--local dbTexture = LSM:Fetch('statusbar', E.db.unitframe.colors.frameGlow.mouseoverGlow.texture)
		--frame.FrameGlow.texture:SetTexture(dbTexture)
		frame.TargetGlow:SetBackdrop({edgeFile = E.Media.Textures.GlowTex, edgeSize = E.db.unitframe.colors.frameGlow.targetGlow.size})
		UF:FrameGlow_SetGlowColor(frame.TargetGlow, frame.unit, 'targetGlow')
	end
end

--This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function ElvUI_Miralos:InsertOptions()
	local SizeOption = {
		order = 1,
		type = "range",
		name = "Size",
		min = 5,
		max = 25,
		step = 1,
		get = function(info)
			return E.db.unitframe.colors.frameGlow.targetGlow.size
		end,
		set = function(info, value)
			E.db.unitframe.colors.frameGlow.targetGlow.size = value
			ElvUI_Miralos:Update() --We changed a setting, call our Update function
		end,
	}

	local ForeGroundOption = {
		order = 1,
		type = "toggle",
		name = "Target Glow in Foreground?",
		get = function(info)
			return E.db.unitframe.colors.frameGlow.targetGlow.foreground
		end,
		set = function(info, value)
			E.db.unitframe.colors.frameGlow.targetGlow.foreground = value
			ElvUI_Miralos:Update() --We changed a setting, call our Update function
		end,
	}


	E.Options.args.unitframe.args.frameGlowGroup.args.targetGlow.args["size"] = SizeOption
	E.Options.args.unitframe.args.frameGlowGroup.args.targetGlow.args["foreground"] = ForeGroundOption
end

function ElvUI_Miralos:Initialize()
	if E.db.unitframe.colors.frameGlow.targetGlow.size == nil then
		E.db.unitframe.colors.frameGlow.targetGlow.size = 5
	end

	if E.db.unitframe.colors.frameGlow.targetGlow.foreground == nil then
		E.db.unitframe.colors.frameGlow.targetGlow.foreground = false
	end

	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, ElvUI_Miralos.InsertOptions)

	self:RegisterEvent("PLAYER_TARGET_CHANGED", "Update")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "Update")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "Update")
end

E:RegisterModule(ElvUI_Miralos:GetName()) --Register the module with ElvUI. ElvUI will now call MyPlugin:Initialize() when ElvUI is ready to load our plugin.