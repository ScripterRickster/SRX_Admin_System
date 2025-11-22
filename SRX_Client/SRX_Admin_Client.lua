repeat task.wait() until game.ReplicatedStorage:FindFirstChild("SRX_Events") ~= nil
local SRX_Events = game.ReplicatedStorage:FindFirstChild("SRX_Events")
----------------------------------------------------------------
local Utilities = script.Parent:WaitForChild("Utilities")
local Assets = script.Parent:WaitForChild("Assets")


local NotificaitonUtility = require(Utilities:WaitForChild("NotificationManager"))
local IconUtility = require(Utilities:WaitForChild("Icon"))
----------------------------------------------------------------
local CS_Func = SRX_Events:WaitForChild("CSC_Func")
local CS_Event = SRX_Events:WaitForChild("CSC_Event")
----------------------------------------------------------------

local TCS = game:GetService("TextChatService")
local TWS = game:GetService("TweenService")

----------------------------------------------------------------
local chatTagsEnabled = CS_Func:InvokeServer("ChatTagStatus")
local chatSlashCMDS = CS_Func:InvokeServer("ChatSlashCMDStatus")
local isHelpTicketsEnabled = CS_Func:InvokeServer("HELPTICKETSTATUS")
local sysAccessType = CS_Func:InvokeServer("GetSysAccessType")
----------------------------------------------------------------

local sysButtonSetup = false


local SRX_TextCMDS = TCS:WaitForChild("SRX_TEXTCHATCOMMANDS")

----------------------------------------------------------------
local plr = game.Players.LocalPlayer
----------------------------------------------------------------

local cam = game.Workspace.CurrentCamera

----------------------------------------------------------------

if isHelpTicketsEnabled then
	local ticket_icon = IconUtility.new()
	ticket_icon:setLabel("Help Tickets","Viewing")
	ticket_icon:setLabel("Help Tickets","Selected")
	ticket_icon:setImage(121820422977145)
	ticket_icon:setName("HT_BUTTON")
	ticket_icon:oneClick(true)
	
	ticket_icon.toggled:Connect(function(isSelected, fromSource)
		CS_Event:FireServer("GIVEHELPTICKETUI")
	end)
end


----------------------------------------------------------------
function registerTextChatCommand(cmd)
	if SRX_TextCMDS:FindFirstChild(cmd) then
		SRX_TextCMDS:FindFirstChild(cmd).AutocompleteVisible = true
	end
end

function resetTextChatCommands()
	for _,v in pairs(SRX_TextCMDS:GetChildren()) do
		if v:IsA("TextChatCommand") then
			v.AutocompleteVisible = false
		end
	end
end
----------------------------------------------------------------

-- chat tags
TCS.OnIncomingMessage = function(msg:TextChatMessage)
	local ts = msg.TextSource
	if ts then
		local plr = game.Players:GetPlayerByUserId(ts.UserId)
		if plr then
			if plr:GetAttribute("SRX_MUTED") then return false end
			if chatTagsEnabled then
				local rn = plr:GetAttribute("SRX_RANKNAME")
				local rc = plr:GetAttribute("SRX_RANKCOLOUR")
				if rn and rc then
					local n_msg_prp = Instance.new("TextChatMessageProperties")
					n_msg_prp.PrefixText = '<font color="#'..rc:ToHex()..'">['..tostring(rn)..']</font> '..msg.PrefixText
					return n_msg_prp
				end
			end
		end
	end
end

----------------------------------------------------------------


CS_Event.OnClientEvent:Connect(function(param1,param2,param3,param4,param5)
	param1 = string.lower(tostring(param1))
	if param1 == "allslashcmds" and param2 and chatSlashCMDS then
		resetTextChatCommands()
		for _,v in pairs(param2) do
			task.defer(function()
				registerTextChatCommand(v)
			end)
		end
		
	elseif param1 == "unfly" then
		local char = plr.Character or plr.CharacterAdded:Wait()
		local hum = char:WaitForChild("Humanoid")
		
		hum.PlatformStand = false
	elseif param1 == "view" and param2~=nil and param2:IsA("Player") then
		
		local t_char = param2.Character or param2.CharacterAdded:Wait()
		
		cam.CameraSubject = t_char:WaitForChild("Humanoid")
		
	elseif param1 == "announcement" and param2 and param3 then
		task.defer(function()
			NotificaitonUtility.CreateAnnouncement(param2,param3)
		end)
	
	elseif param1 == "warn" and param2 and param3 then
		task.defer(function()
			NotificaitonUtility.CreateWarning(param2,param3)
		end)
		
	elseif param1 == "notification" and param2 and param3 then
		task.defer(function()
			NotificaitonUtility.CreateNotification(param2,param3,param4)
		end)
		
	elseif param1 == "track" and param2 then
		local t_char = param2.Character or param2.CharacterAdded:Wait()
		local t_char_hrp = t_char:WaitForChild("HumanoidRootPart")
		
		local char = plr.Character or plr.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		
		local a1,a2 = hrp:FindFirstChild("SRX_ATTACHMENT"),t_char_hrp:FindFirstChild("SRX_ATTACHMENT")
		
		if a1 and a2 and hrp:FindFirstChild(string.lower(param2.Name)) == nil then
			local trackBeam = Instance.new("Beam")
			trackBeam.Color = ColorSequence.new(Color3.new(0.333333, 1, 1))
			trackBeam.Attachment0 = a1
			trackBeam.Attachment1 = a2
			trackBeam.Name = string.lower(param2.Name)
			trackBeam.Parent = hrp
			trackBeam.Enabled = true
		end
		
	elseif param1 == "untrack" and param2 then

		local char = plr.Character or plr.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")

		local t_beam = hrp:FindFirstChild(string.lower(param2.Name))
		
		if t_beam then t_beam:Destroy() end
		
	elseif param1 == "displayprefix" and param2 then
		task.defer(function()
			NotificaitonUtility.CreateNotification("SYSTEM PREFIX",tostring(param2))
		end)
	elseif param1 == "setupaccessbutton" then
		if string.lower(tostring(sysAccessType)) == "button" then
			local sysAccessIcon = IconUtility.new()
			sysAccessIcon:setLabel("SRX ADMIN UI","Viewing")
			sysAccessIcon:setLabel("SRX ADMIN UI","Selected")
			sysAccessIcon:setImage(128874314992009)
			sysAccessIcon:setName("SRX_UI_BUTTON")
			sysAccessIcon:oneClick(true)

			sysAccessIcon.toggled:Connect(function(isSelected, fromSource)
				CS_Event:FireServer("GETADMINPANEL")
			end)
		end
	end
end)

----------------------------------------------------------------
