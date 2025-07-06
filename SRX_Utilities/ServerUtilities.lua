local module = {}
----------------------------------------------------------------
repeat wait() until _G.SRX_ADMINSYS ~= nil
local SETTINGS = require(_G.SRX_ADMINSYS:WaitForChild("AdminSettings"))
repeat wait() until _G.SRX_EVENTS ~= nil
local EVENTS = _G.SRX_EVENTS
repeat wait() until _G.SRX_COMMANDS ~= nil
local COMMANDS = _G.SRX_COMMANDS
repeat wait() until _G.SRX_UTILITIES ~= nil
local UTILITIES = _G.SRX_UTILITIES
----------------------------------------------------------------
local allCMDS = {}

for _,a in pairs(COMMANDS:GetChildren()) do
	allCMDS[string.lower(a.Name)] = a
end
----------------------------------------------------------------


module.FindCommand = function(cmd)
	if cmd == nil or tostring(cmd) == "" then return nil end
	
	cmd = string.lower(tostring(cmd))
	
	if allCMDS[cmd] ~= nil then return allCMDS[cmd] end
	
	for n,c in pairs(allCMDS) do
		local tempC = require(c)
		if string.match(n,cmd,1) then
			if tempC.ExecutableCommand == (true or nil) then
				return c
			end
		elseif tempC.Aliases ~= nil then
			if table.find(tempC.Aliases,cmd) ~= nil then
				if tempC.ExecutableCommand == (true or nil) then
					return c
				end
			end
		end
	end
	
	return nil
end

module.CheckCommandRequirements = function(required_parameters,given_parameters:table)
	for x,v in pairs(required_parameters) do
		if v.Required then
			if given_parameters[x] == nil then
				return false
			end
		end
	end
	return true
end


module.GetHighestRank = function()
	local rankName,rankId,rankColour = nil,-math.huge,nil
	for n,r in pairs(SETTINGS.Ranks) do
		if r.RankId > rankId then
			rankName = n
			rankId = r.RankId
			rankColour = r.RankColour
		end
	end
	return rankName,rankId,rankColour
end

module.GetLowestRank = function()
	local rankName,rankId,rankColour = nil,math.huge,nil
	for n,r in pairs(SETTINGS.Ranks) do
		if r.RankId < rankId then
			rankName = n
			rankId = r.RankId
			rankColour = r.RankColour
		end
	end
	return rankName,rankId,rankColour
end

module.FindRank = function(rank_id,rank_name)
	local rankName,rankId,rankColour = nil,nil,nil
	if rank_id then
		
		for n,r in pairs(SETTINGS.Ranks) do
			if rank_id == r.RankId then
				rankId = r.RankId
				rankName = n
				rankColour = r.RankColour
				break
			end
		end
		
	elseif rank_name then
		
		for n,r in pairs(SETTINGS.Ranks) do
			if string.lower(n) == string.lower(tostring(rank_name)) then
				rankId = r.RankId
				rankName = n
				rankColour = r.RankColour
				break
			end
		end
		
		
	end
	return rankName,rankId,rankColour
end
-----------------------------------------------------------------------------------


local serverID = game.JobId
if game.PrivateServerId ~= "" then
	serverID = game.PrivateServerId
end

if game:GetService("RunService"):IsStudio() then
	serverID = "STUDIO SERVER | NO SERVER ID IS AVAILABLE"
end

local serverType = "REGULAR"
local serverOwner = game.CreatorId

if game.PrivateServerId ~= "" then
	serverType = "VIP"
	serverOwner = game.PrivateServerOwnerId
end

local sOwner = "["..game.Players:GetNameFromUserIdAsync(serverOwner).."](https://www.roblox.com/users/"..serverOwner.."/profile)"
if game.CreatorType == Enum.CreatorType.Group then
	sOwner = "["..game:GetService("GroupService"):GetGroupInfoAsync(game.CreatorId).Name.."](https://www.roblox.com/groups/"..game.CreatorId..")"
end

module.getServerInfo = function()
	return serverType,serverID,sOwner
end

module.getServerLink = function()
	return tostring(serverID)..'\n[Join This Server](https://www.roblox.com/games/start?placeId='..tostring(game.PlaceId)..'%&launchData='..tostring(serverID)..')'
end

module.getTimeStampForDiscordEmbeds = function()
	local ct = os.time(os.date("!*t"))
	return "<t:"..ct..":F>"
end



return module
