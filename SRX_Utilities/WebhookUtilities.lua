repeat wait() until _G.SRX_ADMINSYS ~= nil
local SETTINGS = require(_G.SRX_ADMINSYS:WaitForChild("SRXAdminSettings"))
repeat wait() until _G.SRX_EVENTS ~= nil
local EVENTS = _G.SRX_EVENTS
repeat wait() until _G.SRX_COMMANDS ~= nil
local COMMANDS = _G.SRX_COMMANDS
repeat wait() until _G.SRX_UTILITIES ~= nil
local UTILITIES = _G.SRX_UTILITIES
repeat wait() until _G.SRX_ASSETS ~= nil
local ASSETS = _G.SRX_ASSETS


----------------------------------------------------------------

local module = {

	NoLogCMDS = {}; -- the names of the commands that are not to be logged if executed
}


----------------------------------------------------------------
local HTTP = game:GetService("HttpService")

----------------------------------------------------------------
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
----------------------------------------------------------------


module.CheckIfNoLog = function(command:string)
	if command == nil then return true end
	command = tostring(command)
	if command == "" then return true end
	for _,v in pairs(module.NoLogCMDS) do
		if string.lower(v.Name) == string.lower(command) then
			return true
		end
	end
	return false
end

----------------------------------------------------------------

----------------------------------------------------------------

local commandEmbedColour = SETTINGS["WebhookSettings"]["COMMANDS"]["EmbedColour"]
local dev_consoleEmbedColour = SETTINGS["WebhookSettings"]["DEV_CONSOLE"]["EmbedColour"]

----------------------------------------------------------------

local defaultParameters = {
	{
		["name"] = "Date & Time:",
		["value"] = module.getTimeStampForDiscordEmbeds(),
		["inline"] = true
	},


	{
		["name"] = "Server ID:",
		["value"] = "``"..serverID.."``",
		["inline"] = true
	},


	{
		["name"] = "Server Type:",
		["value"] = serverType,
		["inline"] = true
	},

	{
		["name"] = "Server Owner:",
		["value"] = sOwner,
		["inline"] = true
	},

	{
		["name"] = "Game/Experience :",
		["value"] = "["..tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)["Name"]).."](https://www.roblox.com/games/"..game.PlaceId.."/)",
		["inline"] = true
	},
}

----------------------------------------------------------------

module.FormatCommandWebhook = function(command:string,args:table)
	local data = {
		["content"] = "",
		["embeds"] = {{
			["title"] = string.upper(tostring(command)).." | Command Execution",
			["description"] = "More Information Below:",
			["type"] = "rich",
			["color"] = tonumber(commandEmbedColour:ToHex(),16),
			["fields"] = {
				
			}
		}}
	}
	
	for idx,v in pairs(args) do
		table.insert(data["embeds"][1]["fields"],
			{
				["name"] = "__"..tostring(idx).."__",
				["value"] = tostring(v),
				["inline"] = true,
			}
		)
	end
	
	for _,v in pairs(defaultParameters) do
		table.insert(data["embeds"][1]["fields"],v)
	end
	
	return data
end

module.FormatDevConsoleLogWebhook = function(command:string)
	command = tostring(command)

	local data = {

		["content"] = "",
		["embeds"] = {{
			["title"] = "Developer Console Command Log",
			["description"] = "A command entered within the developer console has been detected and subsequently logged below: ",
			["type"] = "rich",
			["color"] = tonumber(dev_consoleEmbedColour:ToHex(),16),
			["fields"] = {

				{
					["name"] = "Command:",
					["value"] = command,
					["inline"] = true
				},
			}
		}}
	}
	
	for _,v in pairs(defaultParameters) do
		table.insert(data["embeds"][1]["fields"],v)
	end

	return data
end

module.SendLog = function(wbhkid,data)
	if wbhkid and data then

		local wbhk_proxys = { 
			-- {proxy link, can queue (so like adding /queue to the end of the link, but make sure the proxy service supports links with /queue)}

			--{"https://hook.proximatech.us/api/webhooks/",false},
			{"https://webhook.newstargeted.com/api/webhooks/",false},
			{"https://webhook.lewisakura.moe/api/webhooks/",true},


		}



		local id = string.gsub(wbhkid,"https://discord.com/api/webhooks/","")




		local ndata = HTTP:JSONEncode(data)
		for _,v in pairs(wbhk_proxys) do
			local webhook = v[1]..id
			if v[2] then
				webhook = webhook.."/queue"
			end

			local succ,err = pcall(function()
				HTTP:PostAsync(webhook,ndata)
			end)

			if succ then
				print("SRX Admin System Successfully Logged An Action")
				return
			end
		end

		warn("SRX Admin System Encountered An Error While Loggin An Action")
	end
end




return module
