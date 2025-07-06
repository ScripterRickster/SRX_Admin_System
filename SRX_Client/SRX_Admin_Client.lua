repeat task.wait() until game.ReplicatedStorage:FindFirstChild("SRX_Events") ~= nil
local SRX_Events = game.ReplicatedStorage:FindFirstChild("SRX_Events")
----------------------------------------------------------------
local Utilities = script.Parent.Utilities
----------------------------------------------------------------
local CS_Func = SRX_Events:WaitForChild("CSC_Func")
local CS_Event = SRX_Events:WaitForChild("CSC_Event")
----------------------------------------------------------------

local TCS = game:GetService("TextChatService")

----------------------------------------------------------------
local chatTagsEnabled = CS_Func:InvokeServer("ChatTagStatus")

----------------------------------------------------------------

-- chat tags
TCS.OnIncomingMessage = function(msg:TextChatMessage)
	local ts = msg.TextSource
	if ts then
		if chatTagsEnabled then
			local plr = game.Players:GetPlayerByUserId(ts.UserId)
			if plr then
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

