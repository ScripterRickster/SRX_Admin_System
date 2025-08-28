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
repeat wait() until _G.SRX_ASSETS ~= nil
local ASSETS = _G.SRX_ASSETS
----------------------------------------------------------------
local  webhookUtilities = require(UTILITIES.WebhookUtilities)
----------------------------------------------------------------
local TCS = game:GetService("TextChatService")
local TS = game:GetService("TextService")
local DDS = game:GetService("DataStoreService")
local HTTP = game:GetService("HttpService")


local OpenCloudAPI_Key = SETTINGS["AI_Services"]["OpenCloudAPI_Key"]
local AI_Model = SETTINGS["AI_Services"]["AI_Model"]
local AI_Max_Tokens = SETTINGS["AI_Services"]["Max_Tokens"]
local AI_Filter_Messages = SETTINGS["AI_Services"]["FilterAIMessages"]
----------------------------------------------------------------
local CSC_Func = EVENTS:WaitForChild("CSC_Func")
local CSC_Event = EVENTS:WaitForChild("CSC_Event")
local PanelCSC_Event = EVENTS:WaitForChild("PanelCSC_Event")

local SSC_Func = EVENTS:WaitForChild("SSC_Func")
local SSC_Event = EVENTS:WaitForChild("SSC_Event")
----------------------------------------------------------------
local allCMDS = {}

for _,a in pairs(COMMANDS:GetChildren()) do
	allCMDS[string.lower(a.Name)] = a
end

----------------------------------------------------------------
local toolLocations = SETTINGS["ToolLocations"]
----------------------------------------------------------------
local cmdLogs = {}
----------------------------------------------------------------
module.IsAlpha = function(s:string)
	return s:match("^%a+$") ~= nil
end

module.IsNumeric = function(s:string)
	return tonumber(s) ~= nil
end

module.IsPart = function(p)
	return p~=nil and (p:IsA("Part") or p:IsA("UnionOperation") or p:IsA("MeshPart"))
end

module.ConvertToDHMS = function(seconds:number) -- DHMS = Days Hours Minutes Seconds
	seconds = tonumber(tostring(seconds))
	if seconds == nil then return end
	
	local days = math.floor(seconds/86400)
	local hours = math.floor((seconds%86400)/3600)
	local minutes = math.floor((seconds%3600)/60)
	local r_seconds = seconds % 60
	return days,hours,minutes,r_seconds
end
----------------------------------------------------------------

module.FilterMessage = function(plr:Player,msg:string,forClient:boolean)
	if msg == nil or msg == "" then return msg end
	
	local filteredRes = TS:FilterStringAsync(msg,plr.UserId)
	
	if not forClient then
		return filteredRes:GetNonChatStringForBroadcastAsync()
	else
		return filteredRes:GetNonChatStringForUserAsync(plr.UserId)
	end
	
	
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

			if cmdInfo.ExecutableCommand ~= false then
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

module.HandleCommandExecution = function(plr:Player,params:table,fromPanel:boolean)
	if plr and params then
		
		local cmd,cmd_Module = nil,nil
		
		local newParameters = {}
		newParameters["EXECUTOR"] = plr;
		
		local applyToAllUsers,userParams = false,{}

		if fromPanel ~= true then
			local totalParams = #params
			if totalParams == 0 then return end
			
			local s_idx = 2

			if module.IsAlpha(string.sub(params[1],1,1)) then
				s_idx = 1
			end

			cmd = string.sub(params[1],s_idx,string.len(params[1]))

			cmd_Module = module.FindCommand(cmd)
			if cmd_Module then
				
				local c_cmd = require(cmd_Module)
				local c_params = c_cmd.Parameters


				local ct,lastParam = 2,nil
				for par,k in pairs(c_params) do

					if string.lower(tostring(k["Class"]))  == "user" and string.lower(tostring(params[ct])) == "all" then
						applyToAllUsers = true

						table.insert(userParams,par)
					end
					newParameters[par] = params[ct]
					lastParam = par

					ct += 1
				end

				local endString = params[ct-1]

				for ms=ct,totalParams do
					endString = endString.." "..tostring(params[ms])
				end

				newParameters[lastParam] = endString

			end
		else
			cmd = params["D_CMD"]
			
			cmd_Module = module.FindCommand(cmd)

			
			if cmd_Module then

				local c_cmd = require(cmd_Module)
				local c_params = c_cmd.Parameters
				
				for par,k in pairs(c_params) do
					newParameters[par] = params[par]
					
					
					if string.lower(tostring(k["Class"]))  == "user" and string.lower(tostring(params[par])) == "all" then
						applyToAllUsers = true

						table.insert(userParams,par)
					end
				end
			end
			
		end
		
		if cmd and cmd_Module then
			local c_cmd = require(cmd_Module)
			if applyToAllUsers then
				for _,p in pairs(game.Players:GetChildren()) do
					local paramClone = table.clone(newParameters)

					for _,newP in pairs(userParams) do
						paramClone[newP] = p
					end

					task.defer(function()
						c_cmd.Execute(paramClone)
					end)
				end
			else
				task.defer(function()
					c_cmd.Execute(newParameters)
				end)
			end
			
			table.insert(cmdLogs,{plr.UserId,os.time(os.date("!*t")),cmd})
			PanelCSC_Event:FireAllClients("newcmdlog",{plr.UserId,os.time(os.date("!*t")),cmd})
		end
		
	end
end

module.LogCommand = function(cmdModule:ModuleScript,given_params:table)
	if cmdModule and given_params ~= nil then
		if SETTINGS["WebhookSettings"]["COMMANDS"]["Enabled"] then
			if not webhookUtilities.CheckIfNoLog(cmdModule.Name) then
				task.defer(function()
					local webhookID = SETTINGS["WebhookSettings"]["COMMANDS"]["WebhookLink"]
					webhookUtilities.SendLog(webhookID,webhookUtilities.FormatCommandWebhook(cmdModule,given_params))
				end)
			end
		end
	end
end

module.FindCommand = function(cmd)
	if cmd == nil or tostring(cmd) == "" then return nil end
	
	cmd = string.lower(tostring(cmd))
	
	if allCMDS[cmd] ~= nil then return allCMDS[cmd] end
	
	for n,c in pairs(allCMDS) do
		local tempC = require(c)
		if string.match(n,cmd,1) then
			if tempC.ExecutableCommand ~= false then
				return c
			end
		elseif tempC.Aliases ~= nil then
			if table.find(tempC.Aliases,cmd) ~= nil then
				if tempC.ExecutableCommand ~= false then
					return c
				end
			end
		end
	end
	
	return nil
end

module.GetCommandInformation = function(cmd)
	local targCMD = module.FindCommand(cmd)
	if targCMD then
		local rCMD = require(targCMD)
		
		return rCMD.CommandDescription,rCMD.Parameters
	else 
		return nil
	end
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
	
	
	if cmdInfo.ExecutableCommand ~= false and cmdInfo.ExecutionLevel ~= nil then
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
	local rankName,rankId,rankColour,canUsePanel = nil,-math.huge,nil,nil
	for n,r in pairs(SETTINGS.Ranks) do
		if r.RankId > rankId then
			rankName = n
			rankId = r.RankId
			rankColour = r.RankColour
			canUsePanel = r.CanUsePanel
		end
	end
	return rankName,rankId,rankColour,canUsePanel
end

module.GetLowestRank = function()
	local rankName,rankId,rankColour,canUsePanel = nil,math.huge,nil,nil
	for n,r in pairs(SETTINGS.Ranks) do
		if r.RankId < rankId then
			rankName = n
			rankId = r.RankId
			rankColour = r.RankColour
			canUsePanel = r.CanUsePanel
		end
	end
	return rankName,rankId,rankColour,canUsePanel
end

module.FindRank = function(rank_id,rank_name)
	local rankName,rankId,rankColour,canUsePanel = nil,nil,nil,nil
	rank_id = tonumber(tostring(rank_id))
	if rank_id then
		
		for n,r in pairs(SETTINGS.Ranks) do
			if rank_id == r.RankId then
				rankId = r.RankId
				rankName = n
				rankColour = r.RankColour
				canUsePanel = r.CanUsePanel
				
				return rankName,rankId,rankColour,canUsePanel
			end
		end
	end
	if rank_name then
	
		for n,r in pairs(SETTINGS.Ranks) do
			if string.lower(n) == string.lower(tostring(rank_name)) then
				rankId = r.RankId
				rankName = n
				rankColour = r.RankColour
				canUsePanel = r.CanUsePanel
				break
			end
		end
	end
	return rankName,rankId,rankColour,canUsePanel
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
			success = true
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
	if not SETTINGS["AI_Services"]["Enabled"] then return "ERROR405" end
	if OpenCloudAPI_Key == nil or OpenCloudAPI_Key == "" or AI_Model == nil or AI_Model == "" or tonumber(tostring(AI_Max_Tokens)) == nil then return nil end
	if plr:GetAttribute("SRX_RANKID") < SETTINGS["AI_Services"]["MinRank"] then return nil end

	
	local headers: headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = `Bearer {OpenCloudAPI_Key}`
	}
	

	
	local body: body = {
		["model"] = tostring(AI_Model),
		["messages"] = {
			{["role"] = "user", ["content"] = prompt}
		},
		["temperature"] = 0.5,
		["max_tokens"] = tonumber(tostring(AI_Max_Tokens)),
		["top_p"] = 1,
		["frequency_penalty"] = 0.5,
		["presence_penalty"] = 0.0
	}
	


	local succ,response = pcall(function()
		return HTTP:RequestAsync({
			["Url"] = "https://openrouter.ai/api/v1/chat/completions",
			["Method"] = "POST",
			["Headers"] = headers,
			["Body"] = HTTP:JSONEncode(body)
		})
	end)

	if succ then
		
		if response["Success"] then
			local data = HTTP:JSONDecode(response["Body"])
			
			local aiResponse = data.choices[1].message.content
			
			if AI_Filter_Messages then
				aiResponse = module.FilterMessage(plr,aiResponse,true)
			end
			
			return aiResponse
		end
	end
	
	
	return nil

	
end
-----------------------------------------------------------------------------------

module.FindTool = function(toolName:string,forcedLocation)
	local toolObject,fullToolName = nil,nil
	if toolName == nil or toolName == "" then return toolObject,fullToolName end
	
	if forcedLocation == nil then
		for _,l in pairs(toolLocations) do
			for _,t in pairs(l:GetDescendants()) do
				if t.ClassName == "Tool" and string.match(string.lower(t.Name),string.lower(toolName)) ~= nil then
					toolObject,fullToolName = t,t.Name
					return toolObject,fullToolName
				end
			end
		end
	else
		for _,t in pairs(forcedLocation:GetDescendants()) do
			if t.ClassName == "Tool" and string.match(string.lower(t.Name),string.lower(toolName)) ~= nil then
				toolObject,fullToolName = t,t.Name
				return toolObject,fullToolName
			end
		end
	end
	
	return toolObject,fullToolName
end

-----------------------------------------------------------------------------------

module.GetCommandLogs = function(plr:Player)
	if plr:GetAttribute("SRX_CANUSEPANEL") then
		return cmdLogs
	else
		return nil
	end
end

return module
