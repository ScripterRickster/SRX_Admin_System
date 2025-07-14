repeat wait() until _G.SRX_ADMINSYS ~= nil
local SETTINGS = require(_G.SRX_ADMINSYS:WaitForChild("SRXAdminSettings"))
repeat wait() until _G.SRX_EVENTS ~= nil
local EVENTS = _G.SRX_EVENTS
repeat wait() until _G.SRX_COMMANDS ~= nil
local COMMANDS = _G.SRX_COMMANDS
repeat wait() until _G.SRX_UTILITIES ~= nil
local UTILITIES = _G.SRX_UTILITIES

----------------------------------------------------------------
local HTTP = game:GetService("HttpService")

----------------------------------------------------------------

----------------------------------------------------------------

local webhook = {
	
	NoLogCMDS = {}; -- the names of the commands that are not to be logged if executed
}


webhook.CheckIfNoLog = function(command:string)
	if command == nil then return true end
	command = tostring(command)
	if command == "" then return true end
	for _,v in pairs(webhook.NoLogCMDS) do
		if string.lower(v.Name) == string.lower(command) then
			return true
		end
	end
	return false
end

----------------------------------------------------------------

local sInfoModule = require(UTILITIES.ServerUtilities)
local serverType,serverID,sOwner = sInfoModule.getServerInfo()

----------------------------------------------------------------

local commandEmbedColour = SETTINGS["WebhookSettings"]["COMMANDS"]
local dev_consoleEmbedColour = SETTINGS["WebhookSettings"]["DEV_CONSOLE"]

----------------------------------------------------------------

local defaultParameters = {
	{
		["name"] = "Date & Time:",
		["value"] = sInfoModule.getTimeStampForDiscordEmbeds(),
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

webhook.FormatCommandWebhook = function(command:string,args:table)
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

webhook.FormatDevConsoleLogWebhook = function(command:string)
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





webhook.SendLog = function(wbhkid,data)
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




return webhook
