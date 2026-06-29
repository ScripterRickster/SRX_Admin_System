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

local CSC_Event = EVENTS:WaitForChild("CSC_Event")
local PanelCSC_Event = EVENTS:WaitForChild("PanelCSC_Event")
local SSC_Event = EVENTS:WaitForChild("SSC_Event")
----------------------------------------------------------------

local serverUtil = require(UTILITIES.ServerUtilities)
local webhookUtil = require(UTILITIES.WebhookUtilities)

----------------------------------------------------------------
local MPS = game:GetService("MarketplaceService")
local US = game:GetService("UserService")
local DDS = game:GetService("DataStoreService")
local HTTPS = game:GetService("HttpService")
local GS = game:GetService("GroupService")
----------------------------------------------------------------
local DSName = SETTINGS.DatastoreName or SETTINGS.DatastoreSettings.DatastoreName
local RankDDS = DDS:GetDataStore(DSName,"SAVEDRANKS")
local InfractionDDS = DDS:GetDataStore(DSName,"USERINFRACTIONS")
local PlayerJoinsDDS = DDS:GetDataStore(DSName,"PLAYERJOINS")
local PlayerPlayTimeDDS = DDS:GetDataStore(DSName,"PLAYERPLAYTIME")
local PlayerSettingsDDS = DDS:GetDataStore(DSName,"PLAYERSETTINGS")
local PlayerCommandCountDDS = DDS:GetDataStore(DSName,"PLAYERCOMMANDCOUNT")
----------------------------------------------------------------

local OverheadTagStatus = {}
local rtag = ASSETS:WaitForChild("SRX_RANKTAG")


local ftag = ASSETS:WaitForChild("SRX_FROZENTAG")

local adminTool = ASSETS:WaitForChild("SRXAdminTool")

----------------------------------------------------------------
local saveRanks = SETTINGS.SaveRanks or SETTINGS.DatastoreSettings.SaveRanks

local logJoins = SETTINGS["WebhookSettings"]["JOIN_LOGS"]["Enabled"]
local joinLogsWebhook = SETTINGS["WebhookSettings"]["JOIN_LOGS"]["WebhookLink"]

local logInfractions = SETTINGS["WebhookSettings"]["INFRACTION_LOGS"]["Enabled"]
local infractionsWebhook = SETTINGS["WebhookSettings"]["INFRACTION_LOGS"]["WebhookLink"]

local logMessages = SETTINGS["WebhookSettings"]["CHAT_LOGS"]["Enabled"]
local chatlogsWebhook = SETTINGS["WebhookSettings"]["CHAT_LOGS"]["WebhookLink"]

----------------------------------------------------------------

local default_attributes = {
	["SRX_SETUP"] = true;
	["SRX_MUTED"] = false;
	["SRX_FROZEN"] = false;
	["SRX_FLYING"] = false;
}

----------------------------------------------------------------

local trackedUsers = {
	--[userid] = {}
}

----------------------------------------------------------------

local chatlogs = {}

----------------------------------------------------------------

local activeHelpRequests = {
	--[[
	
	[userid] = status
	
	]]
}

----------------------------------------------------------------

local defaultSettingsTable = {
	["SRX_PREFIX"] = SETTINGS.Prefix;
	["SRX_THEME"] = "";
	["SRX_THEME_TRANSPARENCY"] = 0;
}

----------------------------------------------------------------
local playerCommandCount = {
	--[[
	[userid] = {
		[CommandName] = #;
	}
	]]
}

local playerJoinTime = {
	--[[
	[userid] = {
		["PreviousTotalTime"] = prevTotalTime;
		["JoinTime"] = os.time();
	}
	
	]]
}

local staffCount = 0
----------------------------------------------------------------
local _,currentServerID,_,serverOwner = webhookUtil.getServerInfo()
----------------------------------------------------------------

local function getCrossServerPlayerInfo(userid:number)
	if tonumber(tostring(userid)) == nil then return nil end

	local requestID = HTTPS:GenerateGUID(false)
	local responseData = nil
	local requestFinished = false

	SSC_Event:Fire("createreq",{
		["RequestID"] = requestID;
		["ActionID"] = "SRX_CHECKFORPLAYER";
		["Parameters"] = {
			["RequestID"] = requestID;
			["PlayerID"] = tonumber(userid);
		};
		["FunctionThread"] = function(returnData)
			responseData = returnData
			requestFinished = true
		end;
	})

	local requestTimeout = math.min(tonumber(SETTINGS.RequestTimeout or SETTINGS.GeneralSettings.RequestTimeout) or 5, 5)
	local startTime = os.clock()
	while not requestFinished and (os.clock() - startTime) < requestTimeout do
		task.wait()
	end

	return responseData
end


module.SetupPlayerTag = function(plr:Player)
	local ohTagSetting = SETTINGS.OverheadTags or SETTINGS.DecorativeSettings.OverheadTags
	if plr and ohTagSetting["Enabled"] then
		local char = plr.Character or plr.CharacterAdded:Wait()
		local head = char:WaitForChild("Head")
		if plr:GetAttribute("SRX_RANKCOLOUR") ~= nil and plr:GetAttribute("SRX_RANKNAME") ~= nil then
			
			local newTag = nil
			if head:FindFirstChild("SRX_RANKTAG") == nil then
				newTag = rtag:Clone()
				newTag.Parent = head
			else
				newTag = head:FindFirstChild("SRX_RANKTAG")
			end
			if newTag ~= nil then
				for _,v in pairs(newTag:GetDescendants()) do
					if string.lower(v.Name) == "ranktext" and v:IsA("TextLabel") then
						v.Text = plr:GetAttribute("SRX_RANKNAME")
						v.TextColor3 = plr:GetAttribute("SRX_RANKCOLOUR")
					elseif string.lower(v.Name) == "overlay" and v:IsA("Frame") then
						v.BackgroundColor3 = plr:GetAttribute("SRX_RANKCOLOUR") 
					end
				end
				
				newTag.Enabled = OverheadTagStatus[plr.UserId]
			end
		else
			if head:FindFirstChild("SRX_RANKTAG") ~= nil then
				head:FindFirstChild("SRX_RANKTAG"):Destroy()
			end
			OverheadTagStatus[plr.UserId] = false
		end
	end
end

module.ManagePlayerTag = function(plr:Player,forcedStatus:boolean)
	local ohTagSetting = SETTINGS.OverheadTags or SETTINGS.DecorativeSettings.OverheadTags
	if plr and ohTagSetting["Enabled"] then
		local char = plr.Character or plr.CharacterAdded:Wait()
		local head = char:WaitForChild("Head")
		if head:FindFirstChild("SRX_RANKTAG") then
			if forcedStatus ~= nil and typeof(forcedStatus) == "boolean" then
				OverheadTagStatus[plr.UserId] = forcedStatus
			else
				OverheadTagStatus[plr.UserId] = not OverheadTagStatus[plr.UserId]
			end
			head:FindFirstChild("SRX_RANKTAG").Enabled = OverheadTagStatus[plr.UserId]
		end
	end
end

----------------------------------------------------------------

module.SetupPlayer = function(plr:Player)
	if plr:GetAttribute("SRX_SETUP") == (false or nil) then
		
		for attr,aVal in pairs(default_attributes) do
			plr:SetAttribute(attr,aVal)
		end
		
		trackedUsers[plr.UserId] = {}
		
		OverheadTagStatus[plr.UserId] = false
		
		playerJoinTime[plr.UserId] = {}
		
		
		
		for idx,v in pairs(SETTINGS["BanSettings"]["BannedUsers"]) do
			if string.lower(plr.Name) == string.lower(tostring(idx)) or plr.UserId == idx then
				local reason = v
				if reason == nil then
					reason = "No Reason"
				end
				reason = tostring(reason)
				plr:Kick("You are not permitted to join this game | Reason: "..tostring(reason))
				return
			end
		end
		
		if game:GetAttribute("SRX_SERVERLOCK") then
			if game.CreatorType ~= Enum.CreatorType.Group then
				if game.PrivateServerId ~= "" then
					if plr.UserId ~= game.PrivateServerOwnerId then
						plr:Kick("SERVER IS LOCKED")
					end
				else
					if plr.UserId ~= game.CreatorId then
						plr:Kick("SERVER IS LOCKED")
					end
				end
			end
		end
		
		local pChar = plr.Character or plr.CharacterAdded:Wait()
		
		local b_srx_attach = Instance.new("Attachment")
		b_srx_attach.Name = "SRX_ATTACHMENT"
		b_srx_attach.Parent = pChar:WaitForChild("HumanoidRootPart")
		
		local joins = serverUtil.GetDataFromDDS(tostring(plr.UserId),PlayerJoinsDDS)
		if joins == 0 or joins == nil then
			joins = 0
			task.defer(function()
				serverUtil.SaveDataToDDS(tostring(plr.UserId),InfractionDDS,HTTPS:JSONEncode({}))
			end)
			
		end
		joins += 1
		task.defer(function()
			serverUtil.SaveDataToDDS(tostring(plr.UserId),PlayerJoinsDDS,joins)
		end)
		
		local playTime = serverUtil.GetDataFromDDS(tostring(plr.UserId),PlayerPlayTimeDDS)
		
		if tonumber(tostring(playTime)) == nil then
			playTime = 0
			task.defer(function()
				serverUtil.SaveDataToDDS(tostring(plr.UserId),PlayerPlayTimeDDS,playTime)
			end)
		end
		
		playerJoinTime[plr.UserId]["PreviousTotalTime"] = playTime
		playerJoinTime[plr.UserId]["JoinTime"] = os.time()
		
		
		
		plr:SetAttribute("SRX_JOINCOUNT",joins)
		
		if logJoins then
			task.defer(function()
				webhookUtil.SendLog(joinLogsWebhook,webhookUtil.FormatJoinLogWebhook(plr,"JOIN",joins,playTime))
			end)
		end
		
		local function setupPlayerRank()
			local userRanked = false
			local DRN,DRID,DRC,DCUP,sRank = nil,nil,nil,nil,false
			-- DRN = DesiredRankName, DRID = DesiredRankID, DRC = DesiredRankColour
			
			
			if game.CreatorType ~= Enum.CreatorType.Group then
				-- SERVER OWNER
				-------------------------------
				if game.PrivateServerId ~= "" then --private server
					local vipsettings = SETTINGS.VIPServerSettings or SETTINGS.GeneralSettings.VIPServerSettings
					if plr.UserId == game.PrivateServerOwnerId and vipsettings.VIPCommands then
						DRN,DRID,DRC,DCUP = serverUtil.FindRank(tonumber(vipsettings.ServerOwnerRankId))
						
						userRanked = true
						
					end
					
				end
				-------------------------------
				
				if plr.UserId == serverOwner and not userRanked then
					DRN,DRID,DRC,DCUP,sRank = serverUtil.GetHighestRank()
					userRanked = true
				end
			end
			
			
			-------------------------------
			-- USERS
			if not userRanked then
				for _,u in pairs(SETTINGS.RankBinds.Users) do
					if string.lower(u[1]) == string.lower(plr.Name) or u[1] == plr.UserId then
						DRN,DRID,DRC,DCUP,sRank = serverUtil.FindRank(tonumber(u[2]))
						if DRN and DRID then
							userRanked = true
							break
						end
					end
				end
			end
			
			-------------------------------
			-- GROUPS
			
			if not userRanked then
				for gid,g in pairs(SETTINGS.RankBinds.Groups) do
					for rid,rgid in pairs(g) do
						local pRanks = GS:GetRolesInGroupAsync(plr.UserId,gid)
						if pRanks then
							for _,v in pRanks.Roles do
								if v.Id == tonumber(rgid) then
									DRN,DRID,DRC,DCUP,sRank = serverUtil.FindRank(tonumber(rid))
									if DRN and DRID then
										userRanked = true
										break
									end
								end
							end
						end
					end
				end
			end
			
			-------------------------------
			-- GAMEPASSES
			if not userRanked then
				for gpid,g in pairs(SETTINGS.RankBinds.Gamepasses) do
					if MPS:UserOwnsGamePassAsync(plr.UserId,tonumber(gpid)) then
						DRN,DRID,DRC,DCUP,sRank = serverUtil.FindRank(tonumber(gpid))
						if DRN and DRID then
							userRanked = true
							break
						end
						
					end
				end
			end
			
			-------------------------------
			-- OTHER ASSETS
			
			if not userRanked then
				for aid,a in pairs(SETTINGS.RankBinds.OtherAssets) do
					local succ,res = pcall(function()
						return MPS:PlayerOwnsAssetAsync(plr,tonumber(aid))
					end)
					if res then
						DRN,DRID,DRC,DCUP,sRank = serverUtil.FindRank(tonumber(a))
						if DRN and DRID then
							userRanked = true
							break
						end
					end
				end
			end
			
			-------------------------------
			
			if not userRanked and saveRanks then
				local result = serverUtil.GetDataFromDDS(tostring(plr.UserId),RankDDS)
				if result ~= nil then
					result = HTTPS:JSONDecode(result)
					DRN,DRID,DRC,DCUP,sRank = result[1],result[2],result[3],result[4],result[5]
					userRanked = true
				end
			end
			
			-------------------------------
			
			-- PLAYER W/ NO RANK
		
			
			if not userRanked then
				
				
				local defaultRank = SETTINGS.RankBinds.DefaultAdminRank

				if defaultRank and tonumber(tostring(defaultRank)) ~= nil then
					defaultRank = tonumber(tostring(defaultRank))
					
					DRN,DRID,DRC,DCUP,sRank = serverUtil.FindRank(defaultRank)
					userRanked = true
				else
					DRN,DRID,DRC,DCUP,sRank = serverUtil.GetLowestRank()
					userRanked = true
				end
			end
			
			-------------------------------
			-- RANKING THE PLAYER
			if DRN and DRID then
				userRanked = true
				plr:SetAttribute("SRX_RANKNAME",DRN)
				plr:SetAttribute("SRX_RANKID",DRID)

				if DRC then
					plr:SetAttribute("SRX_RANKCOLOUR",DRC)
				end
				
				if DCUP then
					plr:SetAttribute("SRX_CANUSEPANEL",DCUP)
					
					local aType = SETTINGS.SystemAccessType
					
					if aType == nil and SETTINGS.PanelSettings then
						aType = SETTINGS.PanelSettings.SystemAccessType
					end
					
					if string.lower(tostring(aType)) == "button" then
						CSC_Event:FireClient(plr,"SETUPACCESSBUTTON")
					else
						adminTool:Clone().Parent = plr.Backpack
					end

				end
			end
			
			if sRank then
				plr:SetAttribute("SRX_IS_STAFF",true)
				staffCount += 1
				-- evt fire
			end
			
		end

		setupPlayerRank()
		

		
		local function loadPlayerSettings()
			local plrSettings = serverUtil.GetDataFromDDS(tostring(plr.UserId),PlayerSettingsDDS)
			local playerSettingsTable = table.clone(defaultSettingsTable)
			
			if plrSettings ~= nil then
				plrSettings = HTTPS:JSONDecode(plrSettings)
				
				for vName,v in pairs(plrSettings) do
					if playerSettingsTable[vName] ~= nil then
						playerSettingsTable[vName] = v
					end
				end
			end
			
			
			for sName,st in pairs(playerSettingsTable) do
				plr:SetAttribute(sName,st)
			end
			
			local succ1,res = pcall(function()
				return serverUtil.GetDataFromDDS(tostring(plr.UserId),PlayerCommandCountDDS)
			end)
			
			if succ1 then
				
				if res == nil or tostring(res) == "null" then
					 playerCommandCount[tostring(plr.UserId)] = {}
				else
					res = HTTPS:JSONDecode(res)
					playerCommandCount[tostring(plr.UserId)] = res
				end

			end
		end
		
		loadPlayerSettings()
		
		
		
		task.defer(function()
			module.SetupPlayerTag(plr)
		end)
		
		task.defer(function()
			serverUtil.RegisterClientTextChatCommands(plr)
		end)
		
		plr.CharacterAdded:Connect(function(char)
			plr:SetAttribute("SRX_FLYING",false)
			
			local hrp = char:WaitForChild("HumanoidRootPart")
			
			local srx_attach = Instance.new("Attachment")
			srx_attach.Name = "SRX_ATTACHMENT"
			srx_attach.Parent = hrp
			
			if plr:GetAttribute("SRX_CANUSEPANEL") then
				local aType = SETTINGS.SystemAccessType

				if aType == nil and SETTINGS.PanelSettings then
					aType = SETTINGS.PanelSettings.SystemAccessType
				end
				
				if string.lower(tostring(aType)) ~= "button" then
					if not plr.Backpack:FindFirstChild(adminTool.Name) then
						adminTool:Clone().Parent = plr.Backpack
					end
				end
			end
			
			task.defer(function()
				for _,p2 in pairs(trackedUsers[plr.UserId]) do
					module.TrackPlayer(plr,game.Players:GetPlayerByUserId(p2),true)
				end
			end)
			
			task.defer(function()
				if plr:GetAttribute("SRX_FROZEN") then
					ftag:Clone().Parent = char:WaitForChild("Head")
					
					
					if plr:GetAttribute("SRX_FREEZECFRAME") then
						hrp.CFrame = plr:GetAttribute("SRX_FREEZECFRAME")
					end
					hrp.Anchored = true
				end
			end)
			task.defer(function()
				module.SetupPlayerTag(plr)
			end)
		end)

		plr.Chatted:Connect(function(msg)
			local ohTagSetting = SETTINGS.OverheadTags or SETTINGS.DecorativeSettings.OverheadTags
			if ohTagSetting["Enabled"] then
				if string.lower(tostring(ohTagSetting["Command"])) == string.lower(msg) then
					task.defer(function()
						module.ManagePlayerTag(plr)
					end)
					return
				end
			end
			
			local helpCMDSettings = SETTINGS.HelpCMDSettings or SETTINGS.AdministrativeSettings.HelpCMDSettings
			if helpCMDSettings ~= nil then
				local helpCMDEnabled = helpCMDSettings["Enabled"]
				local helpCMD = helpCMDSettings["Command"]
				
				if helpCMDEnabled then
					if string.lower(tostring(helpCMD)) == string.lower(msg) then
						task.defer(function()
							module.CreatePlayerHelpRequest(plr)
						end)
					end
				end
			end
			
			local fl = string.sub(msg,1,1)
			
			local plrCMDPrefix = plr:GetAttribute("SRX_PREFIX")
			if plrCMDPrefix == nil then plrCMDPrefix = SETTINGS.Prefix end
			plrCMDPrefix = tostring(plrCMDPrefix)
			
			if string.lower(fl) == string.lower(plrCMDPrefix) then
				msg = string.sub(msg,2,string.len(msg))
				local parameters = string.split(msg," ")
				task.defer(function()
					serverUtil.HandleCommandExecution(plr,parameters)
				end)
			end
			
			table.insert(chatlogs,{plr.UserId,os.time(os.date("!*t")),msg})
			PanelCSC_Event:FireAllClients("newmsglog",{plr.UserId,os.time(os.date("!*t")),msg})
			
			if logMessages then
				webhookUtil.SendLog(chatlogsWebhook,webhookUtil.FormatChatLogWebhook(plr,msg))
			end
		end)
	end
end

module.PlayerLeft = function(plr:Player)

	
	task.spawn(module.SavePlayerSettings,plr)
	task.spawn(serverUtil.SaveDataToDDS,tostring(plr.UserId),PlayerCommandCountDDS,HTTPS:JSONEncode(playerCommandCount[tostring(plr.UserId)]))
	print("saved")
	task.spawn(module.RemovePlayerHelpRequest,plr)
	
	local totalPlayTime = module.GetPlayerPlayTime(plr.UserId)
	task.spawn(serverUtil.SaveDataToDDS,tostring(plr.UserId),PlayerPlayTimeDDS,totalPlayTime)
	
	
	if logJoins then
		task.spawn(webhookUtil.SendLog,joinLogsWebhook,webhookUtil.FormatJoinLogWebhook(plr,"LEAVE",0,totalPlayTime))
	end
	
	if saveRanks then
		local dds_data = {plr:GetAttribute("SRX_RANKNAME"),plr:GetAttribute("SRX_RANKID"),plr:GetAttribute("SRX_RANKCOLOUR")}
		dds_data = HTTPS:JSONEncode(dds_data)
		task.defer(function()
			serverUtil.SaveDataToDDS(tostring(plr.UserId),RankDDS,dds_data)
		end)
	end
	
	if plr:GetAttribute("SRX_IS_STAFF") then
		staffCount -= 1
	end
	
	playerJoinTime[plr.UserId] = {}
	trackedUsers[plr.UserId] = {}
	playerCommandCount[tostring(plr.UserId)] = {}
	
	for _,v in pairs(game.Players:GetChildren()) do
		task.spawn(module.UntrackPlayer,v,plr)
	end
	
	
	
end

----------------------------------------------------------------


module.FindPlayer = function(username:string,userid:number)
	local isValidPlayer,userID,plrObject = false,false,nil
	local userIdNumber = tonumber(userid)
	local normalizedUsername = username ~= nil and tostring(username) or ""
	if (normalizedUsername == "" and userIdNumber == nil) then return isValidPlayer,userID,plrObject end

	normalizedUsername = string.lower(normalizedUsername)
	local hasUsername = normalizedUsername ~= ""

	for _,v in pairs(game.Players:GetChildren()) do
		local pN = string.lower(v.Name)
		local pUID = v.UserId
		
		
		if (userIdNumber ~= nil and pUID == userIdNumber) or (hasUsername and string.find(pN,normalizedUsername,1,true) ~= nil) then
			isValidPlayer = true
			userID = pUID
			plrObject = v
			return isValidPlayer,userID,plrObject
		end
		
		
	end
	
	if userIdNumber ~= nil then
		local succ,temp_name = pcall(function()
			return game.Players:GetNameFromUserIdAsync(userIdNumber)
		end)
		if succ then
			isValidPlayer = true
			plrObject = nil
			userID = userIdNumber
			return isValidPlayer,userID,plrObject
		end
	else
		local succ,temp_id = pcall(function()
			return game.Players:GetUserIdFromNameAsync(normalizedUsername)
		end)
		
		if succ then
			isValidPlayer = true
			plrObject = nil
			userID = temp_id
			return isValidPlayer,userID,plrObject
		end
	end

	return isValidPlayer,userID,plrObject
end

----------------------------------------------------------------

module.SetPlayerRank = function(plr:Player,rank_id:number)
	if plr then
		
		local rank_name,rank_id,rank_colour,can_use_panel,sRank = serverUtil.FindRank(rank_id,nil)
		if rank_id ~= nil and rank_name ~= nil then
			plr:SetAttribute("SRX_RANKID",rank_id)
			plr:SetAttribute("SRX_RANKNAME",rank_name)
			plr:SetAttribute("SRX_RANKCOLOUR",rank_colour)
			plr:SetAttribute("SRX_CANUSEPANEL",can_use_panel)
			plr:SetAttribute("SRX_IS_STAFF",sRank)
			
			if not sRank then
				staffCount -= 1
			end
			
			
			CSC_Event:FireClient(plr,"notification","RANK UPDATE","Your rank has been updated to: "..tostring(rank_name))
			PanelCSC_Event:FireClient(plr,"updatepanel")
			
			local aType = SETTINGS.SystemAccessType

			if aType == nil and SETTINGS.PanelSettings then
				aType = SETTINGS.PanelSettings.SystemAccessType
			end
			
			if can_use_panel ~= true then
				local pTool = plr.Backpack:FindFirstChild("SRXAdminTool")
				local char = plr.Character or plr.CharacterAdded:Wait()


				
				local cTool = char:FindFirstChild("SRXAdminTool")
				
				if pTool then pTool:Destroy() end
				if cTool then cTool:Destroy() end
				
				local panelUI = plr.PlayerGui:FindFirstChild("SRXPanelUI") or plr.PlayerGui:FindFirstChild("SRXPanelUI_V2")
				if panelUI then panelUI:Destroy() end
				CSC_Event:FireClient(plr,"DESTROYACCESSBUTTON")
				
			else
				local pTool = plr.Backpack:FindFirstChild("SRXAdminTool")
				local char = plr.Character or plr.CharacterAdded:Wait()
				local cTool = char:FindFirstChild("SRXAdminTool")
				
				if string.lower(aType) == "tool" then
					if pTool == nil and cTool == nil then
						ASSETS:WaitForChild("SRXAdminTool"):Clone().Parent = plr.Backpack
					end
				elseif string.lower(aType) == "button" then
					CSC_Event:FireClient(plr,"SETUPACCESSBUTTON")
				end
			
				
			end
			
			
			task.defer(function()
				module.SetupPlayerTag(plr)
			end)
			task.defer(function()
				serverUtil.RegisterClientTextChatCommands(plr)
			end)
		end
	end
end

module.GetPlayerRankInfo = function(username:string,userid:number)
	local isValidPlayer,plrID,plrObject = module.FindPlayer(username,userid)
	
	local rank_id,rank_name,rank_colour,can_use_panel,is_staff_rank = nil,nil,nil,nil,false
	
	if isValidPlayer and plrObject then
		rank_id = plrObject:GetAttribute("SRX_RANKID")
		rank_name = plrObject:GetAttribute("SRX_RANKNAME")
		rank_colour = plrObject:GetAttribute("SRX_RANKCOLOUR")
		can_use_panel = plrObject:GetAttribute("SRX_CANUSEPANEL")
		is_staff_rank = plrObject:GetAttribute("SRX_IS_STAFF")
		
	end
	
	
	return rank_id,rank_name,rank_colour,can_use_panel,is_staff_rank
	
	
	
end

----------------------------------------------------------------


module.RecordPlayerInfraction = function(userid:number,infracData:table)
	local isValidPlayer,plrID,plrObject = module.FindPlayer(nil,userid)
	
	if isValidPlayer then
		local duration = infracData["Duration"]
		local reason = infracData["Reason"]
		local infracType = infracData["InfractionType"]
		local staffMemID = infracData["StaffMemberID"]
		local canRemove = infracData["Deletable"]
		local infractionID = HTTPS:GenerateGUID(false)
		local staffMemName = game.Players:GetNameFromUserIdAsync(staffMemID)
		if plrID and staffMemName ~= nil then
			local utcTime = os.time(os.date("!*t"))
			
			local currInfractions = serverUtil.GetDataFromDDS(tostring(userid),InfractionDDS)
			currInfractions = HTTPS:JSONDecode(currInfractions)
			if currInfractions ~= nil then
				local newInfraction = {
					StaffMemberID = tonumber(staffMemID);
					InfractionType = infracType;
					Reason = reason;
					Duration = duration;
					CanDelete = canRemove;
					InfractionTime = utcTime;
					InfractionID = infractionID;
				}

				currInfractions[tostring(infractionID)] = newInfraction
				
				task.defer(function()
					serverUtil.SaveDataToDDS(tostring(userid),InfractionDDS,HTTPS:JSONEncode(currInfractions))
				end)
				
				if logInfractions then
					task.defer(function()
						webhookUtil.SendLog(infractionsWebhook,webhookUtil.FormatInfractionLogWebhook(plrID,newInfraction,"CREATE"))
					end)
				end
			end
		end
	end
end

module.RemovePlayerInfraction = function(userid:number,infracID,staffMem:Player)
	local isValidPlayer,plrID,plrObject = module.FindPlayer(nil,userid)
	
	if isValidPlayer and infracID and staffMem then
		
		local staffRankID = staffMem:GetAttribute("SRX_RANKID")
		local mfr = SETTINGS.ManageInfractionRank or SETTINGS.AdministrativeSettings.ManageInfractionRank
		if tonumber(tostring(staffRankID)) >= mfr then
			local currInfractions = serverUtil.GetDataFromDDS(tostring(userid),InfractionDDS)
			currInfractions = HTTPS:JSONDecode(currInfractions)
			if currInfractions[infracID] then
				local canDelete = currInfractions[infracID]["CanDelete"]

				if canDelete then
					if logInfractions then
						local tempInfracInfo = table.clone(currInfractions[infracID])
						task.defer(function()
							webhookUtil.SendLog(infractionsWebhook,webhookUtil.FormatInfractionLogWebhook(plrID,tempInfracInfo,"DELETE"))
						end)
					end
					currInfractions[infracID] = nil
					task.defer(function()
						serverUtil.SaveDataToDDS(tostring(userid),InfractionDDS,HTTPS:JSONEncode(currInfractions))
					end)
				end
			end
		end
	end
end

module.GetPlayerInfractions = function(userid:number)
	local isValidPlayer,plrID,plrObject = module.FindPlayer(nil,userid)

	if isValidPlayer then
		local plrInfractions = serverUtil.GetDataFromDDS(tostring(userid),InfractionDDS)
		
		if plrInfractions == nil then return nil end
		local allInfracs = HTTPS:JSONDecode(plrInfractions)
		
		return allInfracs
	end
	return nil
end

----------------------------------------------------------------

module.TrackPlayer = function(p1:Player,p2:Player,forceTrack:boolean)
	if p1 and p2 then
		if p1 == p2 then return end
		if forceTrack then
			CSC_Event:FireClient(p1,"track",p2)
			return
		end
		if table.find(trackedUsers[p1.UserId],p2.UserId) == nil then
			table.insert(trackedUsers[p1.UserId],p2.UserId)
			CSC_Event:FireClient(p1,"track",p2)
		end
	end
end

module.UntrackPlayer = function(p1:Player,p2:Player)
	if p1 and p2 then
		local idx = table.find(trackedUsers[p1.UserId],p2.UserId)
		if idx ~= nil then
			CSC_Event:FireClient(p1,"untrack",p2)
			table.remove(trackedUsers[p1.UserId],idx)
		end
	end
end

----------------------------------------------------------------
module.GetChatLogs = function(plr:Player)
	if plr:GetAttribute("SRX_CANUSEPANEL") then
		return chatlogs
	else
		return nil
	end
end
----------------------------------------------------------------
module.SetPlayerPrefix = function(plr:Player,prefix:string)
	if plr and prefix then
		plr:SetAttribute("SRX_PREFIX",prefix)
		task.spawn(module.SavePlayerSettings,plr)
	end
end

module.SetPlayerTheme = function(plr:Player,theme:string)
	if plr and theme then
		
		local themeInfo = serverUtil.FindTheme(theme)
		if themeInfo ~= nil then
			plr:SetAttribute("SRX_THEME",themeInfo.ThemeID)
			if themeInfo.ThemeTransparency ~= nil and tonumber(tostring(themeInfo.ThemeTransparency)) ~= nil then
				plr:SetAttribute("SRX_THEME_TRANSPARENCY",themeInfo.ThemeTransparency)
			else
				plr:SetAttribute("SRX_THEME_TRANSPARENCY",0)
			end
			PanelCSC_Event:FireClient(plr,"UPDATEPANELTHEME",tostring(themeInfo.ThemeID),themeInfo.ThemeTransparency)
		end
		
	end
end

module.SavePlayerSettings = function(plr:Player)
	if plr then
		local currPlrSettings = {}
		
		for sN,sV in pairs(defaultSettingsTable) do
			if plr:GetAttribute(sN) then
				currPlrSettings[sN] = plr:GetAttribute(sN)
			else
				currPlrSettings[sN] = sV
			end
		end
		
		task.defer(function()
			serverUtil.SaveDataToDDS(tostring(plr.UserId),PlayerSettingsDDS,HTTPS:JSONEncode(currPlrSettings))
		end)
		
	end
end
----------------------------------------------------------------

module.CreatePlayerHelpRequest = function(plr:Player)
	local helpCMDSettings = SETTINGS.HelpCMDSettings or SETTINGS.AdministrativeSettings.HelpCMDSettings
	if plr and helpCMDSettings ~= nil and helpCMDSettings["Enabled"] then
		if activeHelpRequests[plr.UserId] == nil then
			activeHelpRequests[plr.UserId] = true
			PanelCSC_Event:FireAllClients("CREATEHELPREQ",plr)
		end
	end
end

module.RemovePlayerHelpRequest = function(plr:Player)
	if plr then
		
		if activeHelpRequests[plr.UserId] then
			PanelCSC_Event:FireAllClients("REMOVEHELPREQ",plr)
			activeHelpRequests[plr.UserId] = nil
		end
	end
end

module.HandlePlayerHelpRequest = function(plr1:Player,plr2:Player)
	if plr1 and plr2 then
		if activeHelpRequests[plr2.UserId] ~= nil then
			local helpCMDSettings = SETTINGS.HelpCMDSettings or SETTINGS.AdministrativeSettings.HelpCMDSettings
			if tonumber(tostring(helpCMDSettings["HandlerMinRank"])) <= tonumber(tostring(plr1:GetAttribute("SRX_RANKID"))) then
				task.defer(function()
					module.RemovePlayerHelpRequest(plr2)
				end)

				local char1 = plr1.Character or plr1.CharacterAdded:Wait()
				local hrp1 = char1:WaitForChild("HumanoidRootPart")

				local char2 = plr2.Character or plr2.CharacterAdded:Wait()
				local hrp2 = char2:WaitForChild("HumanoidRootPart")

				hrp1.CFrame = CFrame.new(hrp2.CFrame.X,hrp2.CFrame.Y+10,hrp2.CFrame.Z)
			end
		end
	end
end

module.GetAllHelpRequests = function()
	return activeHelpRequests
end
----------------------------------------------------------------

module.UpdatePlayerCommandUse = function(plr:Player,cmdName:string)
	if plr and cmdName then
		if not serverUtil.PlayerCanUseCommand(plr,cmdName) then return end
		if playerCommandCount[tostring(plr.UserId)] == nil then
			playerCommandCount[tostring(plr.UserId)] = {}
		end
		local actualCMD = serverUtil.FindCommand(cmdName)
		if actualCMD ~= nil then
			actualCMD = tostring(actualCMD)
			local c = playerCommandCount[tostring(plr.UserId)][actualCMD]
			
			if c then
				playerCommandCount[tostring(plr.UserId)][actualCMD] += 1
			else
				playerCommandCount[tostring(plr.UserId)][actualCMD] = 1
			end
			
			PanelCSC_Event:FireClient(plr,"qactupdate","home")
		end
	end
end

----------------------------------------------------------------

module.IsPlayerBanned = function(userid:number)
	if userid then

		local function toUTC(isoString:string)
			local year, month, day, hour, min, sec = isoString:match(
				"^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)Z$"
			)

			if not (year and month and day and hour and min and sec) then
				if SETTINGS.EnableDebugComments or SETTINGS.GeneralSettings.EnableDebugComments then
					warn("Invalid ISO 8601 format:", isoString)
				end
				return nil
			end

			return os.time({
				year = tonumber(year),
				month = tonumber(month),
				day = tonumber(day),
				hour = tonumber(hour),
				min = tonumber(min),
				sec = tonumber(sec),
			})
		end


		userid = tonumber(userid)
		local success, entries = pcall(function()
			return game.Players:GetBanHistoryAsync(userid)
		end)

		if not success or not entries then
			if SETTINGS.EnableDebugComments  or SETTINGS.GeneralSettings.EnableDebugComments then
				warn("SRX | ERROR RETRIEVING BAN HISTORY")
			end
			return nil
		end

		local firstEntry = entries[1]

		if not firstEntry.Ban then return false end

		local startTime = firstEntry.StartTime
		local duration = firstEntry.Duration

		if duration == -1 then return true end
		local start_utc = toUTC(startTime)
		local curr_utc = os.date("!*t")

		if math.abs(curr_utc - start_utc) >= duration then
			return false
		else
			return true
		end		
	end
	return false
end

module.BanPlayer = function(userid:number,reason:string,privateReason:string,duration:number,excludeAlts:boolean)
	local succ,err = false,nil
	if tonumber(tostring(userid)) then
		
		if typeof(excludeAlts) ~= 'boolean' then
			excludeAlts = false
		end
		if duration == nil or tonumber(tostring(duration)) == nil then
			duration = -1
		else
			duration *= 86400
		end
		
		reason = tostring(reason)
		privateReason = tostring(privateReason)
		
		local banConfig = {
			UserIds = {tonumber(tostring(userid))},
			Duration = duration,
			DisplayReason = reason,
			PrivateReason = privateReason,
			ExcludeAltAccounts = excludeAlts,
			ApplyToUniverse = true,
		}

		succ,err = pcall(function()
			game.Players:BanAsync(banConfig)
		end)
		
	end
	return succ,err
end

module.UnbanPlayer = function(userid:number)
	local succ,err = false,nil
	if tonumber(tostring(userid)) then
		if module.IsPlayerBanned(userid) then
			local unbanConfig = {
				UserIds = {tonumber(tostring(userid))},
				ApplyToUniverse = true,
			}
			succ,err = pcall(function()
				game.Players:UnbanAsync(unbanConfig)
			end)
			
		else
			err = "PLAYER IS NOT BANNED"
		end
	end
	return succ,err
end

----------------------------------------------------------------
module.GetPlayerJoinCount = function(userid:number)
	if tonumber(tostring(userid)) == nil then return 0 end
	
	local joins = serverUtil.GetDataFromDDS(tostring(userid),PlayerJoinsDDS)
	
	if tonumber(tostring(joins)) == nil then joins = 0 end
	return joins
end

module.GetPlayerPlayTime = function(userid:number)
	if tonumber(tostring(userid)) == nil then return 0 end
	userid = tonumber(tostring(userid))
	if not playerJoinTime[userid] then return 0 end
	local pPTTime = playerJoinTime[userid]["PreviousTotalTime"]
	local pJTime = playerJoinTime[userid]["JoinTime"]
	
	
	
	if pPTTime == 0 or pPTTime == nil or pJTime == 0 or pJTime == nil then return 0 end
	
	local res = (os.time() - pJTime) + pPTTime 
	return res
end
----------------------------------------------------------------
module.GetPlayerInformation = function(user)
	if user == nil or user == "" or user == 0 or user == "0" then return nil end
	
	if tonumber(user) then
		user = tonumber(user)
	else
		local succ1,uid = pcall(function()
			return game.Players:GetUserIdFromNameAsync(user)
		end)
		
		if succ1 == false or uid == nil then return nil end
		user = uid
	end
	
	local data = {
		DisplayName = nil;
		Username = nil;
		UserID = nil;
		IsBanned = nil;
		JoinCount = nil;
		AccountAge = nil;
		PlayTime = nil;
		IsOnline = false;
		ServerID = nil;
	}
	
	local succ,info = pcall(function()
		return US:GetUserInfosByUserIdsAsync({user})
	end)
	
	
	if succ and info ~= nil then
		for _,v in pairs(info) do
			data.DisplayName = v.DisplayName
			data.Username = v.Username
			data.UserID = v.Id
		end
		
		data.IsBanned = module.IsPlayerBanned(data.UserID)
		
		if data.IsBanned == nil then data.IsBanned = false end
		data.JoinCount = module.GetPlayerJoinCount(data.UserID)
		data.PlayTime = module.GetPlayerPlayTime(data.UserID)
		
		
		local _,_,plrObject = module.FindPlayer(nil,data.UserID)
		if plrObject then
			data.AccountAge = tostring(plrObject.AccountAge).." Days Old"
			data.IsOnline = true
			data.ServerID = currentServerID
		else
			local serverInfo = getCrossServerPlayerInfo(data.UserID)
			if serverInfo ~= nil and serverInfo["ServerID"] ~= nil then
				data.IsOnline = true
				data.ServerID = serverInfo["ServerID"]
			end
		end
	end
	
	
	return data
end
----------------------------------------------------------------

module.GetStaffCount = function()
	return staffCount
end

----------------------------------------------------------------

module.GetMostUsedCommands = function(plr:Player,numOfCmd:number)
	if plr and numOfCmd then
		local uid = tostring(plr.UserId)
		local counts = playerCommandCount[uid]

		if counts == nil then return {} end

		local sorted = {}
		for cmdName,uses in pairs(counts) do
			if serverUtil.PlayerCanUseCommand(plr,cmdName) then
				table.insert(sorted,{Command = cmdName, Uses = uses})
			end
		end

		table.sort(sorted,function(a,b)
			return a.Uses > b.Uses
		end)

		local result = {}
		for i=1,math.min(numOfCmd,#sorted) do
			table.insert(result,sorted[i])
		end
		

		return result
	end
	
	return nil
end

----------------------------------------------------------------


return module
