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

local serverUtil = require(UTILITIES.ServerUtilities)

----------------------------------------------------------------
local MPS = game:GetService("MarketplaceService")
local US = game:GetService("UserService")
local DDS = game:GetService("DataStoreService")
local HTTPS = game:GetService("HttpService")
----------------------------------------------------------------
local RankDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"SAVEDRANKS")
local InfractionDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"USERINFRACTIONS")
local PlayerJoinsDDS = DDS:GetDataStore(SETTINGS.DataStore,"PLAYERJOINS")
----------------------------------------------------------------

local OverheadTagStatus = {}

----------------------------------------------------------------
local saveRanks = SETTINGS.SaveRanks
----------------------------------------------------------------

module.SetupPlayer = function(plr:Player)
	if plr:GetAttribute("SRX_SETUP") == (false or nil) then
		plr:SetAttribute("SRX_SETUP",true)
		
		for _,v in pairs(SETTINGS["BanSettings"]["BannedUsers"]) do
			if string.lower(plr.Name) == string.lower(v) or plr.UserId == v then
				plr:Kick("You are not permitted to join this game")
				return
			end
		end
		
		local joins = serverUtil.GetDataFromDDS(tostring(plr.UserId),PlayerJoinsDDS)
		if joins == 0 or joins == nil then
			joins = 0
			task.defer(function()
				serverUtil.SaveDataToDDS(tostring(plr.UserId),InfractionDDS,{})
			end)
			
		end
		joins += 1
		serverUtil.SaveDataToDDS(tostring(plr.UserId),PlayerJoinsDDS,joins)
		
		local function setupPlayerRank()
			local userRanked = false
			local DRN,DRID,DRC = nil,nil,nil
			-- DRN = DesiredRankName, DRID = DesiredRankID, DRC = DesiredRankColour
			
			if game.CreatorType ~= Enum.CreatorType.Group then
				-- SERVER OWNER
				-------------------------------
				if game.PrivateServerId ~= "" then --private server
					if plr.UserId == game.PrivateServerOwnerId and SETTINGS.VIPServerSettings.VIPCommands then
						DRN,DRID,DRC = serverUtil.FindRank(tonumber(SETTINGS.VIPServerSettings.ServerOwnerRankId))
						
						userRanked = true
						
					end
					
				end
				-------------------------------
				
				if plr.UserId == game.CreatorId and not userRanked then
					DRN,DRID,DRC = serverUtil.GetHighestRank()
					userRanked = true
				end
			end
			
			-------------------------------
			-- USERS
			if not userRanked then
				for _,u in pairs(SETTINGS.RankBinds.Users) do
					if string.lower(u[1]) == string.lower(plr.Name) or u[1] == plr.UserId then
						DRN,DRID,DRC = serverUtil.FindRank(tonumber(u[2]))
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
						DRN,DRID,DRC = serverUtil.FindRank(tonumber(g.RankId))
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
						DRN,DRID,DRC = serverUtil.FindRank(tonumber(gpid))
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
						DRN,DRID,DRC = serverUtil.FindRank(tonumber(a))
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
					DRN,DRID,DRC = result[1],result[2],result[3]
				end
			end
			
			-------------------------------
			
			-- PLAYER W/ NO RANK
			
			if not userRanked then
				DRN,DRID,DRC = serverUtil.GetLowestRank()
				userRanked = true
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
			end
			
		end

		setupPlayerRank()
		
		task.defer(function()
			serverUtil.RegisterClientTextChatCommands(plr)
		end)
		
		plr.CharacterAdded:Connect(function(char)

		end)

		plr.Chatted:Connect(function(msg)
			local fl = string.sub(msg,1,1)
			if fl == SETTINGS.Prefix then
				msg = string.sub(msg,2,string.len(msg))
				local parameters = string.split(msg," ")
				serverUtil.HandleCommandExecution(plr,parameters)
			end
		end)
	end
end

module.PlayerLeft = function(plr:Player)
	
	if saveRanks then
		local dds_data = {plr:GetAttribute("SRX_RANKNAME"),plr:GetAttribute("SRX_RANKID"),plr:GetAttribute("SRX_RANKCOLOUR")}
		task.defer(function()
			serverUtil.SaveDataToDDS(tostring(plr.UserId),RankDDS,dds_data)
		end)
	end
end


module.FindPlayer = function(username:string,userid:number)
	local isValidPlayer,userID,plrObject = false,false,nil
	username = tostring(username)
	if (username == nil or username == "") and (userid == nil or tonumber(userid) == nil) then return isValidPlayer,isInGame,plrObject end
	
	username = string.lower(username)
	
	for _,v in pairs(game.Players:GetChildren()) do
		local pN = string.lower(v.Name)
		local pUID = v.UserId
		
		
		if pUID == userid or string.match(pN,username,1) then
			isValidPlayer = true
			userID = pUID
			plrObject = v
			return isValidPlayer,userid,plrObject
		end
		
		
	end
	
	if game.Players:GetUserIdFromNameAsync(username) ~= nil or game.Players:GetNameFromUserIdAsync(userid) ~= nil then
		isValidPlayer = true
		plrObject = nil
		
		if game.Players:GetUserIdFromNameAsync(username) then
			userID = game.Players:GetUserIdFromNameAsync(username)
		else
			userID = userid
		end
	end
	return isValidPlayer,userID,plrObject
end

module.SetPlayerRank = function(plr:Player,rank_id:number)
	if plr then
		
		local rank_name,rank_id,rank_colour = serverUtil.FindRank(rank_id,nil)
		if rank_id ~= nil and rank_name ~= nil then
			plr:SetAttribute("SRX_RANKID",rank_id)
			plr:SetAttribute("SRX_RANKNAME",rank_name)
			if rank_colour then
				plr:SetAttribute("SRX_RANKCOLOUR",rank_colour)
			end
			task.defer(function()
				serverUtil.RegisterClientTextChatCommands(plr)
			end)
		end
	end
end

module.GetPlayerRankInfo = function(username:string,userid:number)
	local isValidPlayer,isInGame,plrObject = module.FindPlayer(username,userid)
	
	local rank_id,rank_name,rank_colour = nil,nil,nil
	
	if isValidPlayer and isInGame and plrObject then
		rank_id = plrObject:GetAttribute("SRX_RANKID")
		rank_name = plrObject:GetAttribute("SRX_RANKNAME")
		rank_colour = plrObject:GetAttribute("SRX_RANKCOLOUR")
		
	end
	
	
	return rank_id,rank_name,rank_colour
	
	
	
end


module.RecordPlayerInfraction = function(userid:number,infracData:table)
	local isValidPlayer,isInGame,plrObject = module.FindPlayer(nil,userid)
	
	if isValidPlayer then
		local duration = infracData["Duration"]
		local reason = infracData["Reason"]
		local infracType = infracData["InfractionType"]
		local staffMemID = infracData["StaffMemberID"]
		local infractionID = HTTPS:GenerateGUID(false)
		local staffMemName = game.Players:GetNameFromUserIdAsync(staffMemID)
		if isInGame and staffMemName ~= nil then
			local utcTime = os.time(os.date("!*t"))
			
			local currInfractions = serverUtil.GetDataFromDDS(tostring(userid),InfractionDDS)
			
			if currInfractions ~= nil then
				local newInfraction = {
					StaffMemberID = tonumber(staffMemID);
					InfractionType = infracType;
					Reason = reason;
					Duration = duration;
					InfractionTime = utcTime;
				}

				currInfractions[tostring(infractionID)] = newInfraction
				
				task.defer(function()
					serverUtil.SaveDataToDDS(tostring(userid),InfractionDDS,currInfractions)
				end)
			end
		end
	end
end

module.RemovePlayerInfraction = function(userid:number,infracID)
	local isValidPlayer,isInGame,plrObject = module.FindPlayer(nil,userid)

	if isValidPlayer and infracID then
		local currInfractions = serverUtil.GetDataFromDDS(tostring(userid),InfractionDDS)
		
		if currInfractions[infracID] then
			currInfractions[infracID] = nil
			serverUtil.SaveDataToDDS(tostring(userid),currInfractions)
		end
	end
end


return module
