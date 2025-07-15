repeat task.wait() until game.ReplicatedStorage:FindFirstChild("SRX_Events") ~= nil
local SRX_Events = game.ReplicatedStorage:FindFirstChild("SRX_Events")
----------------------------------------------------------------
local Utilities = script.Parent:WaitForChild("Utilities")
local Assets = script.Parent:WaitForChild("Assets")


local NotificaitonUtility = require(Utilities:WaitForChild("NotificationManager"))
----------------------------------------------------------------
local CS_Func = SRX_Events:WaitForChild("CSC_Func")
local CS_Event = SRX_Events:WaitForChild("CSC_Event")
----------------------------------------------------------------

local TCS = game:GetService("TextChatService")
local TWS = game:GetService("TweenService")

----------------------------------------------------------------
local chatTagsEnabled = CS_Func:InvokeServer("ChatTagStatus")
local chatSlashCMDS = CS_Func:InvokeServer("ChatSlashCMDStatus")

----------------------------------------------------------------

local SRX_TextCMDS = TCS:WaitForChild("SRX_TEXTCHATCOMMANDS")

----------------------------------------------------------------

----------------------------------------------------------------

local cam = game.Workspace.CurrentCamera

----------------------------------------------------------------
-- 
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
		
	elseif param1 == "view" and param2~=nil and param2:IsA("Player") then
		
		local t_char = param2.Character or param2.CharacterAdded:Wait()
		
		cam.CameraSubject = t_char:WaitForChild("Humanoid")
	elseif param1 == "announcement" and param2 and param3 then
		task.defer(function()
			NotificaitonUtility.CreateAnnouncement(param2,param3)
		end)
	end
end)

----------------------------------------------------------------
