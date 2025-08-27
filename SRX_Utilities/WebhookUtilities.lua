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

local SSC_Func = EVENTS:WaitForChild("SSC_Func")
----------------------------------------------------------------

local commandEmbedColour = SETTINGS["WebhookSettings"]["COMMANDS"]["EmbedColour"]
local dev_consoleEmbedColour = SETTINGS["WebhookSettings"]["DEV_CONSOLE"]["EmbedColour"]
local infractionEmbedColour = SETTINGS["WebhookSettings"]["INFRACTION_LOGS"]["EmbedColour"]
local join_logEmbedColour = SETTINGS["WebhookSettings"]["JOIN_LOGS"]["EmbedColour"]
local chat_logEmbedColour = SETTINGS["WebhookSettings"]["CHAT_LOGS"]["EmbedColour"]

----------------------------------------------------------------

local defaultParameters = {
	{
		["name"] = "DATE & TIME:",
		["value"] = module.getTimeStampForDiscordEmbeds(),
		["inline"] = true
	},


	{
		["name"] = "SERVER ID:",
		["value"] = "``"..serverID.."``",
		["inline"] = true
	},


	{
		["name"] = "SERVER TYPE:",
		["value"] = serverType,
		["inline"] = true
	},

	{
		["name"] = "SERVER OWNER:",
		["value"] = sOwner,
		["inline"] = true
	},

	{
		["name"] = "GAME/EXPERIENCE:",
		["value"] = "["..tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)["Name"]).."](https://www.roblox.com/games/"..game.PlaceId.."/)",
		["inline"] = true
	},
}

----------------------------------------------------------------

module.FormatCommandWebhook = function(command:ModuleScript,args:table)
	if command == nil then return nil end
	local data = {
		["content"] = "",
		["embeds"] = {{
			["title"] = string.upper(command.Name).." | Command Execution",
			["description"] = "More Information Below:",
			["type"] = "rich",
			["color"] = tonumber(commandEmbedColour:ToHex(),16),
			["fields"] = {
				
			}
		}}
	}
	
	local cmd = require(command)
	
	for idx,v in pairs(args) do
		
		local value = tostring(v)
		
		if string.lower(idx) ~= "executor" then
			local param_type = cmd["Parameters"][idx]["Class"]
			if string.lower(tostring(param_type)) == "user" then
				local isValid,userID,target = SSC_Func:Invoke("GETPLAYER",v)

				if isValid then
					if target then
						value = "["..target.Name.."](https://www.roblox.com/users/"..tostring(target.UserId).."/profile)"
					elseif target == nil and userID ~= nil then
						local username = game.Players:GetNameFromUserIdAsync(tonumber(userID))
						value = "["..username.."](https://www.roblox.com/users/"..tostring(userID).."/profile)"
					end
				end
			end
		else
			if v:IsA("Player") then
				value = "["..v.Name.."](https://www.roblox.com/users/"..tostring(v.UserId).."/profile)"
			end
		end
		
		
		
	
		
	
		table.insert(data["embeds"][1]["fields"],
			{
				["name"] = string.upper(tostring(idx))..":",
				["value"] = value,
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
					["name"] = "COMMAND:",
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

module.FormatInfractionLogWebhook = function(targID:number,infracData:table,action:string)
	if tonumber(tostring(targID)) ~= nil and infracData and action then
		
		local staffMemID = infracData["StaffMemberID"]
		local staffMemName = game.Players:GetNameFromUserIdAsync(tonumber(staffMemID))
		
		local targName = game.Players:GetNameFromUserIdAsync(tonumber(targID))
		
		local infracID = infracData["InfractionID"]
		
		
		local data = {

			["content"] = "",
			["embeds"] = {{
				["title"] = "Infraction Log",
				["description"] = "More Information Below: ",
				["type"] = "rich",
				["color"] = tonumber(infractionEmbedColour:ToHex(),16),
				["footer"] = {
					["text"] = "INFRACTION ID | "..tostring(infracData["InfractionID"]),
					["icon_url"] = "",
				},
				["fields"] = {
					
					{
						["name"] = "ACTION:",
						["value"] = "``"..action.."``",
						["inline"] = true
					},
					
					{
						["name"] = "STAFF MEMBER:",
						["value"] = "["..staffMemName.."](https://www.roblox.com/users/"..tostring(staffMemID).."/profile)",
						["inline"] = true
					},

					{
						["name"] = "PLAYER:",
						["value"] = "["..targName.."](https://www.roblox.com/users/"..tostring(targID).."/profile)",
						["inline"] = true
					},
					
					{
						["name"] = "INFRACTION TYPE:",
						["value"] = tostring(infracData["InfractionType"]),
						["inline"] = true
					},

					
					{
						["name"] = "REASON:",
						["value"] = tostring(infracData["Reason"]),
						["inline"] = true
					},
					
					{
						["name"] = "DURATION:",
						["value"] = tostring(infracData["Duration"]),
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
	return nil
end

module.FormatJoinLogWebhook = function(plr:Player,joinType:string,totalJoins:number)
	if plr and joinType then
		joinType = string.upper(tostring(joinType))
		
		local data = {

			["content"] = "",
			["embeds"] = {{
				["title"] = "Join/Leave Log",
				["description"] = "More Information Below: ",
				["type"] = "rich",
				["color"] = tonumber(join_logEmbedColour:ToHex(),16),
				["fields"] = {

					{
						["name"] = "PLAYER:",
						["value"] = "["..plr.Name.."](https://www.roblox.com/users/"..tostring(plr.UserId).."/profile)",
						["inline"] = true
					},
					
					{
						["name"] = "TYPE:",
						["value"] = joinType,
						["inline"] = true
					},
				}
			}}
		}
		
		if joinType == "JOIN" and tonumber(tostring(totalJoins)) ~= nil then
			totalJoins = tostring(totalJoins)
			
			local newParam = {
				["name"] = "TOTAL JOINS:",
				["value"] = "``"..totalJoins.."``",
				["inline"] = true
			}
			
			table.insert(data["embeds"][1]["fields"],newParam)
			
		end

		for _,v in pairs(defaultParameters) do
			table.insert(data["embeds"][1]["fields"],v)
		end
		
		return data
		
	end
	return nil
end

module.FormatChatLogWebhook = function(plr:Player,msg:string)
	if plr then
		msg = tostring(msg)
		
		local data = {

			["content"] = "",
			["embeds"] = {{
				["title"] = "Message Log",
				["description"] = "More Information Below: ",
				["type"] = "rich",
				["color"] = tonumber(join_logEmbedColour:ToHex(),16),
				["fields"] = {

					{
						["name"] = "PLAYER:",
						["value"] = "["..plr.Name.."](https://www.roblox.com/users/"..tostring(plr.UserId).."/profile)",
						["inline"] = true
					},

					{
						["name"] = "MESSAGE:",
						["value"] = msg,
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
	return nil
end

module.SendLog = function(wbhkid,data)
	if wbhkid and data then

		local wbhk_proxys = { 
			-- {proxy link, can queue (so like adding /queue to the end of the link, but make sure the proxy service supports links with /queue)}
			
			{"http://c4.play2go.cloud:20894/api/webhooks/",false},
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
