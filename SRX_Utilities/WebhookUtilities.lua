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

local module = {}


----------------------------------------------------------------
local HTTP = game:GetService("HttpService")
local MPS = game:GetService("MarketplaceService")
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

if serverOwner == "0" or serverOwner == nil or serverOwner == 0 or serverOwner == "" then
	local gInfo = MPS:GetProductInfo(game.PlaceId,Enum.InfoType.Asset)
	
	serverOwner = gInfo.Creator.CreatorTargetId
	
end



local sOwner = "UNKNOWN"

if sOwner ~= 0 then
	if game.CreatorType == Enum.CreatorType.Group then
		sOwner = "["..game:GetService("GroupService"):GetGroupInfoAsync(game.CreatorId).Name.."](https://www.roblox.com/groups/"..game.CreatorId..")"
	else
		if serverOwner ~= nil and serverOwner ~= "" and serverOwner ~= "0" and serverOwner ~= 0 then
			sOwner = "["..game.Players:GetNameFromUserIdAsync(serverOwner).."](https://www.roblox.com/users/"..serverOwner.."/profile)"
		else
			warn("SRX ADMIN SYSTEM  | FAILED TO GET CREATOR ID","SRX ADMIN SYSTEM || YOUR ADMIN SYSTEM MAY EXPERIENCE SOME ISSUES DUE TO ROBLOX NOT PROPERLY RETURNING THE CORRECT CREATOR ID")
			sOwner = "UNKNOWN SERVER OWNER"
		end

	end
end


module.getServerInfo = function()
	return serverType,serverID,sOwner,serverOwner
end

module.getServerLink = function()
	return tostring(serverID)..'\n[Join This Server](https://www.roblox.com/games/start?placeId='..tostring(game.PlaceId)..'%&launchData='..tostring(serverID)..')'
end

module.getTimeStampForDiscordEmbeds = function()
	local ct = os.time(os.date("!*t"))
	return "<t:"..ct..":F>"
end

----------------------------------------------------------------

local SSC_Func = EVENTS:WaitForChild("SSC_Func")
----------------------------------------------------------------

local commandEmbedColour = SETTINGS["WebhookSettings"]["COMMANDS"]["EmbedColour"]
local dev_consoleEmbedColour = SETTINGS["WebhookSettings"]["DEV_CONSOLE"]["EmbedColour"]
local infractionEmbedColour = SETTINGS["WebhookSettings"]["INFRACTION_LOGS"]["EmbedColour"]
local join_logEmbedColour = SETTINGS["WebhookSettings"]["JOIN_LOGS"]["EmbedColour"]
local chat_logEmbedColour = SETTINGS["WebhookSettings"]["CHAT_LOGS"]["EmbedColour"]
local helpTicketEmbedColour = SETTINGS["WebhookSettings"]["HELP_TICKET_LOGS"]["EmbedColour"]

----------------------------------------------------------------
module.FormatWebhookMentionableIDs = function(webhookClass)
	local res = ""
	if SETTINGS["WebhookSettings"][webhookClass] ~= nil  then
		local roleIds = SETTINGS["WebhookSettings"][webhookClass]["Mentionable_Ids"]["Roles"]
		local userIds = SETTINGS["WebhookSettings"][webhookClass]["Mentionable_Ids"]["Users"]
		
		if roleIds ~= nil then
			for _,v in roleIds do
				res = res.."<@&"..tostring(v)..">\n"
			end
		end
		
		if userIds ~= nil then
			for _,v in userIds do
				res = res.."<@"..tostring(v)..">\n"
			end
		end
	end
	return res
end
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
	local embedDesc = module.FormatWebhookMentionableIDs("COMMANDS")
	local data = {
		["content"] = embedDesc,
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
	local embedDesc = module.FormatWebhookMentionableIDs("DEV_CONSOLE")
	local data = {

		["content"] = embedDesc,
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


		local embedDesc = module.FormatWebhookMentionableIDs("INFRACTION_LOGS")
		
		local data = {

			["content"] = embedDesc,
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

module.FormatJoinLogWebhook = function(plr:Player,joinType:string,totalJoins:number,totalPlayTime:number)
	if plr and joinType then
		joinType = string.upper(tostring(joinType))
		
		local days,hours,minutes,seconds = SSC_Func:Invoke("CONVERTTODHMS",totalPlayTime)
		local embedDesc = module.FormatWebhookMentionableIDs("JOIN_LOGS")
		local data = {

			["content"] = embedDesc,
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
					
					{
						["name"] = "TOTAL PLAY TIME:",
						["value"] = "``"..tostring(days).."`` Days, ``"..tostring(hours).."`` Hours, ``"..tostring(minutes).."`` Minutes, ``"..tostring(seconds).."`` Seconds",
						["inline"] = true
					}
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
		
		local embedDesc = module.FormatWebhookMentionableIDs("CHAT_LOGS")

		local data = {

			["content"] = embedDesc,
			["embeds"] = {{
				["title"] = "Message Log",
				["description"] = "More Information Below: ",
				["type"] = "rich",
				["color"] = tonumber(chat_logEmbedColour:ToHex(),16),
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

module.FormatHelpTicketWebhook = function(plr:Player,targetName:string,targetUID:number,reason:string,evidence:string,notes:string)
	if plr and targetName and targetUID then

		local embedDesc = module.FormatWebhookMentionableIDs("HELP_TICKET_LOGS")
		
		local data = {

			["content"] = embedDesc,
			["embeds"] = {{
				["title"] = "Help Ticket Log",
				["description"] = "More Information Below: ",
				["type"] = "rich",
				["color"] = tonumber(helpTicketEmbedColour:ToHex(),16),
				["fields"] = {

					{
						["name"] = "PLAYER:",
						["value"] = "["..plr.Name.."](https://www.roblox.com/users/"..tostring(plr.UserId).."/profile)",
						["inline"] = true
					},

					{
						["name"] = "REPORTED USER:",
						["value"] = "["..targetName.."](https://www.roblox.com/users/"..tostring(targetUID).."/profile)",
						["inline"] = true
					},
					
					{
						["name"] = "REASON:",
						["value"] = reason,
						["inline"] = true
					},
					
					{
						["name"] = "EVIDENCE:",
						["value"] = evidence,
						["inline"] = true
					},
					
					{
						["name"] = "NOTES:",
						["value"] = notes,
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

		local wbhk_proxys = SETTINGS.WebhookProxies
		if wbhk_proxys == nil or typeof(wbhk_proxys) ~= 'table' then return nil end



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
