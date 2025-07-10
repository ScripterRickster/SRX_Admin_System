local module = {}
----------------------------------------------------------------
repeat wait() until _G.SRX_ADMINSYS ~= nil
local SETTINGS = require(_G.SRX_ADMINSYS:WaitForChild("SRXAdminSettings"))
repeat wait() until _G.SRX_EVENTS ~= nil
local EVENTS = _G.SRX_EVENTS
repeat wait() until _G.SRX_COMMANDS ~= nil
local COMMANDS = _G.SRX_COMMANDS
repeat wait() until _G.SRX_UTILITIES ~= nil
local UTILITIES = _G.SRX_UTILITIES
----------------------------------------------------------------
local TCS = game:GetService("TextChatService")
local TS = game:GetService("TextService")
local DDS = game:GetService("DataStoreService")
local OCS = game:GetService("OpenCloudService")


local OpenAICloud_Key = SETTINGS["AI_Services"]["OpenCloudAPI_Key"]
local AIService = nil
if OpenAICloud_Key ~= nil and OpenAICloud_Key ~= "" then
	AIService = OCS:new(OpenAICloud_Key)
end
----------------------------------------------------------------
local CSC_Func = EVENTS.CSC_Func
local CSC_Event = EVENTS.CSC_Event

local SSC_Func = EVENTS.SSC_Func
local SSC_Event = EVENTS.SSC_Event
----------------------------------------------------------------
local allCMDS = {}

for _,a in pairs(COMMANDS:GetChildren()) do
	allCMDS[string.lower(a.Name)] = a
end

----------------------------------------------------------------
module.IsAlpha = function(s:string)
	return s:match("^%a+$") ~= nil
end

module.IsNumeric = function(s:string)
	return tonumber(s) ~= nil
end

----------------------------------------------------------------

module.FilterMessage = function(plr,msg:string)
	if msg == nil or msg == "" then return msg end
	
	local filteredRes = TS:FilterStringAsync(msg,plr.UserId)
	
	return filteredRes:GetNonChatStringForBroadcastAsync()
end

----------------------------------------------------------------
local customTCCFolder = Instance.new("Folder")
customTCCFolder.Name = "SRX_TEXTCHATCOMMANDS"
customTCCFolder.Parent = TCS

local customTCCRegistered = false
module.RegisterTextChatCommands = function()
	if SETTINGS.IncludeChatSlashCommands then
		if customTCCRegistered then return end
		customTCCRegistered = true
		
		local function createTextChatCommand(cmd:ModuleScript)
			local cmdInfo = require(cmd)

			if cmdInfo.ExecutableCommand == (true or nil) then
				local newTCC = Instance.new("TextChatCommand")
				newTCC.AutocompleteVisible = false
				newTCC.Name = cmd.Name
				newTCC.PrimaryAlias = "/"..cmd.Name

				newTCC.Parent = customTCCFolder

				newTCC.Triggered:Connect(function(textsource:TextSource,text:string)
					local plr = game.Players:GetPlayerByUserId(textsource.UserId)
					if plr then
						local params = string.split(text," ")
						module.HandleCommandExecution(plr,params)
					end
				end)
			end



		end

		for _,v in pairs(allCMDS) do
			task.defer(function()
				createTextChatCommand(v)
			end)
		end
	end
end

module.RegisterClientTextChatCommands = function(plr:Player)
	if SETTINGS.IncludeChatSlashCommands then
		CSC_Event:FireClient(plr,"ALLSLASHCMDS",module.GetAllPlayerUsableCommands(plr))
	end
end

----------------------------------------------------------------

module.HandleCommandExecution = function(plr:Player,params:table)
	if plr and params then
		if #params == 0 then return end
		
		local s_idx = 2
		
		if module.IsAlpha(string.sub(params[1],1,1)) then
			s_idx = 1
		end
		
		local cmd = string.sub(params[1],s_idx,string.len(params[1]))
		
		local cmd_Module = module.FindCommand(cmd)
		if cmd_Module then
			local newParameters = {
				EXECUTOR = plr;
			}

			local c_cmd = require(cmd_Module)
			local c_params = c_cmd.Parameters

			local ct = 2
			for par,k in pairs(c_params) do
				newParameters[par] = params[ct]
				ct += 1
			end

			c_cmd.Execute(newParameters)
			
		end
	end
end

module.LogCommand = function(cmdModule:ModuleScript,given_params:table)
	if cmdModule and given_params ~= nil then
		
	end
end

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

module.PlayerCanUseCommand = function(plr:Player,cmd)
	local rankId = plr:GetAttribute("SRX_RANKID")
	if rankId == nil then return false end
	rankId = tonumber(rankId)
	local cmdInfo = nil
	if typeof(cmd) == 'string' then
		local res = module.FindCommand(cmd)
		if res then cmdInfo = require(res) end
	elseif cmd:IsA("ModuleScript") then
		cmdInfo = require(cmd)
	end
	
	
	if cmdInfo.ExecutableCommand == (true or nil) and cmdInfo.ExecutionLevel ~= nil then
		if cmdInfo.LockToRank then
			if rankId == cmdInfo.ExecutionLevel then
				return true
			end
		else
			if rankId >= cmdInfo.ExecutionLevel then
				return true
			end
		end
	end
	
	return false
end

module.GetAllPlayerUsableCommands = function(plr:Player)
	local p_cmds = {}
	if plr then
		for _,v in pairs(allCMDS) do
			if module.PlayerCanUseCommand(plr,v) then
				table.insert(p_cmds,v.Name)
			end
		end
	end
	return p_cmds
end

----------------------------------------------------------------


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
	rank_id = tonumber(tostring(rank_id))
	if rank_id then
		
		for n,r in pairs(SETTINGS.Ranks) do
			if rank_id == r.RankId then
				rankId = r.RankId
				rankName = n
				rankColour = r.RankColour
				
				return rankName,rankId,rankColour
			end
		end
	end
	if rank_name then
	
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

module.GetDataFromDDS = function(key,datastore:DataStore)
	local attempt_limit,current_tries,result = 3,0,nil
	repeat
		local succ,res = pcall(function()
			return datastore:GetAsync(key)
		end)

		if not succ then
			warn("FAILED TO RETRIEVE DATA FOR THE KEY: "..tostring(key).." | RETRYING.....")
		else
			result = res
			break
		end
		current_tries += 1
		task.wait()
	until current_tries == attempt_limit
	if result == nil then
		warn("FAILED TO RETRIEVE KEY: "..tostring(key).." FROM A DATASTORE")
	end
	return result
end

module.SaveDataToDDS = function(key,datastore:DataStore,data)
	local attempt_limit,current_tries,success = 3,0,false
	repeat
		local succ,err = pcall(function()
			datastore:SetAsync(key,data)
		end)

		if not succ then
			warn("FAILED TO SAVE DATA FOR THE KEY: "..tostring(key).." | RETRYING.....")
		else
			break
		end
		current_tries += 1
		task.wait()
	until current_tries == attempt_limit
	if not success then
		warn("FAILED TO SAVE DATA FOR THE KEY: "..tostring(key).." TO A DATASTORE")
	end
end

-----------------------------------------------------------------------------------

module.GetAIResponse = function(plr:Player,prompt:string)
	if not SETTINGS["AI_Services"]["Enabled"] then return nil end
	if AIService == nil then return nil end
	if plr:GetAttribute("SRX_RANKID") < SETTINGS["AI_Services"]["MinRank"] then return nil end
	local request = {
		model = "text-davinci-003",
		prompt = prompt,
		max_tokens = 2048,
		temperature = 0.5,
		top_p = 1,
		frequency_penalty = 0.5,
		presence_penalty = 0.0,
		stop = {"\n"}
	}
	
	local succ,response = pcall(function()
		return AIService:GenerateText(request)
	end)
	if succ then return module.FilterMessage(response.choices[1].text) else return "FAILED TO GET A RESPONSE" end
	
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
