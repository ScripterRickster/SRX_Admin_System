local module = {}

repeat wait() until _G.SRX_ADMINSYS ~= nil
local SETTINGS = require(_G.SRX_ADMINSYS:WaitForChild("AdminSettings"))
repeat wait() until _G.SRX_EVENTS ~= nil
local EVENTS = _G.SRX_EVENTS
repeat wait() until _G.SRX_COMMANDS ~= nil
local COMMANDS = _G.SRX_COMMANDS
repeat wait() until _G.SRX_UTILITIES ~= nil
local UTILITIES = _G.SRX_UTILITIES


local serverUtil = require(UTILITIES.ServerUtilities)

module.SetupPlayer = function(plr:Player)
	if plr:GetAttribute("SRX_SETUP") == (false or nil) then
		plr:SetAttribute("SRX_SETUP",true)
		plr.CharacterAdded:Connect(function(char)

		end)

		plr.Chatted:Connect(function(msg)
			local fl = string.sub(msg,1,1)
			if fl == SETTINGS.Prefix then
				msg = string.sub(msg,2,string.len(msg))
				local parameters = string.split(msg," ")
				local cmd = parameters[1]
				
				
				local cmd_Module = serverUtil.FindCommand(cmd)


				if cmd_Module ~= nil then
					local newParameters = {
						EXECUTOR = plr;
					}

					local c_cmd = require(cmd_Module)
					local c_params = c_cmd.Parameters

					local ct = 2
					for par,k in pairs(c_params) do
						newParameters[par] = parameters[ct]
						ct += 1
					end

					c_cmd.Execute(newParameters)
				end
			end
		end)
	end
end


module.FindPlayer = function(username,userid)
	local isValidPlayer,isInGame,plrObject = false,false,nil
	username = tostring(username)
	if (username == nil or username == "") and (userid == nil or tonumber(userid) == nil) then return isValidPlayer,isInGame,plrObject end
	
	username = string.lower(username)
	
	for _,v in pairs(game.Players:GetChildren()) do
		local pN = string.lower(v.Name)
		local pUID = v.UserId
		
		
		if pUID == userid or string.match(pN,username,1) then
			isValidPlayer = true
			isInGame = true
			plrObject = v
			return isValidPlayer,isInGame,plrObject
		end
		
		
	end
	
	if game.Players:GetUserIdFromNameAsync(username) ~= nil or game.Players:GetNameFromUserIdAsync(userid) ~= nil then
		isValidPlayer = true
		isInGame = false
		plrObject = nil
	end
	return isValidPlayer,isInGame
end

return module
