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
----------------------------------------------------------------

local serverUtil = require(UTILITIES.ServerUtilities)
local webhookUtil = require(UTILITIES.WebhookUtilities)

----------------------------------------------------------------
local MPS = game:GetService("MarketplaceService")
local US = game:GetService("UserService")
local DDS = game:GetService("DataStoreService")
local HTTPS = game:GetService("HttpService")
----------------------------------------------------------------
local RankDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"SAVEDRANKS")
local InfractionDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"USERINFRACTIONS")
local PlayerJoinsDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"PLAYERJOINS")
----------------------------------------------------------------

local OverheadTagStatus = {}
local rtag = ASSETS:WaitForChild("SRX_RANKTAG")


local ftag = ASSETS:WaitForChild("SRX_FROZENTAG")

local adminTool = ASSETS:WaitForChild("SRXAdminTool")

----------------------------------------------------------------
local saveRanks = SETTINGS.SaveRanks

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


module.SetupPlayerTag = function(plr:Player)
	if plr and SETTINGS["OverheadTags"]["Enabled"] then
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
	if plr and SETTINGS["OverheadTags"]["Enabled"] then
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
		
		if logJoins then
			task.defer(function()
				webhookUtil.SendLog(joinLogsWebhook,webhookUtil.FormatJoinLogWebhook(plr,"JOIN",joins))
			end)
		end
		
		local function setupPlayerRank()
			local userRanked = false
			local DRN,DRID,DRC,DCUP = nil,nil,nil,nil
			-- DRN = DesiredRankName, DRID = DesiredRankID, DRC = DesiredRankColour
			
			if game.CreatorType ~= Enum.CreatorType.Group then
				-- SERVER OWNER
				-------------------------------
				if game.PrivateServerId ~= "" then --private server
					if plr.UserId == game.PrivateServerOwnerId and SETTINGS.VIPServerSettings.VIPCommands then
						DRN,DRID,DRC,DCUP = serverUtil.FindRank(tonumber(SETTINGS.VIPServerSettings.ServerOwnerRankId))
						
						userRanked = true
						
					end
					
				end
				-------------------------------
				
				if plr.UserId == game.CreatorId and not userRanked then
					DRN,DRID,DRC,DCUP = serverUtil.GetHighestRank()
					userRanked = true
				end
			end
			
			-------------------------------
			-- USERS
			if not userRanked then
				for _,u in pairs(SETTINGS.RankBinds.Users) do
					if string.lower(u[1]) == string.lower(plr.Name) or u[1] == plr.UserId then
						DRN,DRID,DRC,DCUP = serverUtil.FindRank(tonumber(u[2]))
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
					if plr:GetRankInGroup(tonumber(gid)) >= g.Min_Group_Rank then
						DRN,DRID,DRC,DCUP = serverUtil.FindRank(tonumber(g.RankId))
						if DRN and DRID then
							userRanked = true
							break
						end
					end
				end
			end
			
			-------------------------------
			-- GAMEPASSES
			if not userRanked then
				for gpid,g in pairs(SETTINGS.RankBinds.Gamepasses) do
					if MPS:UserOwnsGamePassAsync(plr.UserId,tonumber(gpid)) then
						DRN,DRID,DRC,DCUP = serverUtil.FindRank(tonumber(gpid))
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
					if MPS:PlayerOwnsAsset(plr,tonumber(aid)) then
						DRN,DRID,DRC,DCUP = serverUtil.FindRank(tonumber(a))
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
					DRN,DRID,DRC,DCUP = result[1],result[2],result[3],result[4]
				end
			end
			
			-------------------------------
			
			-- PLAYER W/ NO RANK
			
			if not userRanked then
				
				local defaultRank = SETTINGS.RankBinds.DefaultAdminRank
				if defaultRank and tonumber(tostring(defaultRank)) ~= nil then
					defaultRank = tonumber(tostring(defaultRank))
					
					DRN,DRID,DRC,DCUP = serverUtil.FindRank(defaultRank)
					userRanked = true
				else
					DRN,DRID,DRC,DCUP = serverUtil.GetLowestRank()
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
					adminTool:Clone().Parent = plr.Backpack
				end
			end
			
		end

		setupPlayerRank()
		
		
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
				if not plr.Backpack:FindFirstChild(adminTool.Name) then
					adminTool:Clone().Parent = plr.Backpack
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
			if SETTINGS.OverheadTags["Enabled"] then
				if string.lower(tostring(SETTINGS.OverheadTags["Command"])) == string.lower(msg) then
					task.defer(function()
						module.ManagePlayerTag(plr)
					end)
					return
				end
			end
			
			local fl = string.sub(msg,1,1)
			if fl == SETTINGS.Prefix then
				msg = string.sub(msg,2,string.len(msg))
				local parameters = string.split(msg," ")
				serverUtil.HandleCommandExecution(plr,parameters)
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
	trackedUsers[plr.UserId] = {}
	
	for _,v in pairs(game.Players:GetChildren()) do
		task.defer(function()
			module.UntrackPlayer(v,plr)
		end)
	end
	
	
	if logJoins then
		task.defer(function()
			webhookUtil.SendLog(joinLogsWebhook,webhookUtil.FormatJoinLogWebhook(plr,"LEAVE"))
		end)
	end
	if saveRanks then
		local dds_data = {plr:GetAttribute("SRX_RANKNAME"),plr:GetAttribute("SRX_RANKID"),plr:GetAttribute("SRX_RANKCOLOUR")}
		dds_data = HTTPS:JSONEncode(dds_data)
		task.defer(function()
			serverUtil.SaveDataToDDS(tostring(plr.UserId),RankDDS,dds_data)
		end)
	end
end

----------------------------------------------------------------


module.FindPlayer = function(username:string,userid:number)
	local isValidPlayer,userID,plrObject = false,false,nil
	username = tostring(username)
	if (username == nil or username == "") and (userid == nil or tonumber(userid) == nil) then return isValidPlayer,userID,plrObject end
	
	username = string.lower(username)

	for _,v in pairs(game.Players:GetChildren()) do
		local pN = string.lower(v.Name)
		local pUID = v.UserId
		
		
		if pUID == userid or string.match(pN,username,1) then
			isValidPlayer = true
			userID = pUID
			plrObject = v
			return isValidPlayer,userID,plrObject
		end
		
		
	end
	
	if tonumber(userid) ~= nil then
		local succ,temp_name = pcall(function()
			return game.Players:GetNameFromUserIdAsync(tonumber(userid))
		end)
		if succ then
			isValidPlayer = true
			plrObject = nil
			userID = tonumber(userid)
			return isValidPlayer,userID,plrObject
		end
	else
		local succ,temp_id = pcall(function()
			return game.Players:GetUserIdFromNameAsync(tostring(username))
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
		
		local rank_name,rank_id,rank_colour,can_use_panel = serverUtil.FindRank(rank_id,nil)
		if rank_id ~= nil and rank_name ~= nil then
			plr:SetAttribute("SRX_RANKID",rank_id)
			plr:SetAttribute("SRX_RANKNAME",rank_name)
			plr:SetAttribute("SRX_RANKCOLOUR",rank_colour)
			plr:SetAttribute("SRX_CANUSEPANEL",can_use_panel)
			
			
			
			CSC_Event:FireClient(plr,"notification","RANK UPDATE","Your rank has been updated to: "..tostring(rank_name))
			PanelCSC_Event:FireClient(plr,"updatepanel")
			
			if can_use_panel ~= true then
				local pTool = plr.Backpack:FindFirstChild("SRXAdminTool")
				local char = plr.Character or plr.CharacterAdded:Wait()
				
				local cTool = char:FindFirstChild("SRXAdminTool")
				
				if pTool then pTool:Destroy() end
				if cTool then cTool:Destroy() end
				
				local panelUI = plr.PlayerGui:FindFirstChild("SRXPanelUI")
				if panelUI then panelUI:Destroy() end
				
			else
				local pTool = plr.Backpack:FindFirstChild("SRXAdminTool")
				local char = plr.Character or plr.CharacterAdded:Wait()
				local cTool = char:FindFirstChild("SRXAdminTool")
				
				if pTool == nil and cTool == nil then
					ASSETS:WaitForChild("SRXAdminTool"):Clone().Parent = plr.Backpack
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
	
	local rank_id,rank_name,rank_colour,can_use_panel = nil,nil,nil,nil
	
	if isValidPlayer and plrObject then
		rank_id = plrObject:GetAttribute("SRX_RANKID")
		rank_name = plrObject:GetAttribute("SRX_RANKNAME")
		rank_colour = plrObject:GetAttribute("SRX_RANKCOLOUR")
		can_use_panel = plrObject:GetAttribute("SRX_CANUSEPANEL")
		
	end
	
	
	return rank_id,rank_name,rank_colour,can_use_panel
	
	
	
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
		if tonumber(tostring(staffRankID)) >= SETTINGS.ManageInfractionRank then
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


return module
