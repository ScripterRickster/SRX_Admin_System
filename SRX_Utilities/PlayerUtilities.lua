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
----------------------------------------------------------------
local RankDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"SAVEDRANKS")
local InfractionDDS = DDS:GetDataStore(SETTINGS.DatastoreName,"USERINFRACTIONS")
----------------------------------------------------------------

local OverheadTagStatus = {}

----------------------------------------------------------------
local saveRanks = SETTINGS.SaveRanks
----------------------------------------------------------------

module.SetupPlayer = function(plr:Player)
	if plr:GetAttribute("SRX_SETUP") == (false or nil) then
		plr:SetAttribute("SRX_SETUP",true)
		
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
				local attempt_limit,current_tries,result = 3,0,nil
				repeat
					local succ,res = pcall(function()
						RankDDS:GetAsync(tostring(plr.UserId),{plr:GetAttribute("SRX_RANKNAME"),plr:GetAttribute("SRX_RANKID"),plr:GetAttribute("SRX_RANKCOLOUR")})
					end)

					if not succ then
						warn("FAILED TO RETRIEVE RANK FOR "..plr.Name.." ("..tostring(plr.UserId)..") | RETRYING.....")
					else
						result = res
						break
					end
					current_tries += 1
					task.wait()
				until current_tries == attempt_limit
				if result == nil then
					warn("FAILED TO RETRIEVE RANK FOR "..plr.Name.." ("..tostring(plr.UserId)..")")
				else
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
		local attempt_limit,current_tries,success = 3,0,false
		repeat
			local succ,err = pcall(function()
				RankDDS:SetAsync(tostring(plr.UserId),{plr:GetAttribute("SRX_RANKNAME"),plr:GetAttribute("SRX_RANKID"),plr:GetAttribute("SRX_RANKCOLOUR")})
			end)
			
			if not succ then
				warn("FAILED TO SAVE RANK FOR "..plr.Name.." ("..tostring(plr.UserId)..") WITH THE ERROR: "..tostring(err).." | RETRYING.....")
			else
				success = true
				break
			end
			current_tries += 1
			task.wait()
		until current_tries == attempt_limit
		if not success then
			warn("FAILED TO SAVE RANK FOR "..plr.Name.." ("..tostring(plr.UserId)..")")
		end
		
	end
end


module.FindPlayer = function(username:string,userid:number)
	local isValidPlayer,isInGame,plrObject = false,false,nil
	username = tostring(username)
	if (username == nil or username == "") and (userid == nil or tonumber(userid) == nil) then return isValidPlayer,isInGame,plrObject end
	
	username = string.lower(username)
	
	for _,v in pairs(game.Players:GetChildren()) do
		local pN = string.lower(v.Name)
		local pUID = v.UserId
		
		
		if pUID == userid or string.match(pN,username,1) then
			isValidPlayer = true
			isInGame = true
			plrObject = v
			return isValidPlayer,isInGame,plrObject
		end
		
		
	end
	
	if game.Players:GetUserIdFromNameAsync(username) ~= nil or game.Players:GetNameFromUserIdAsync(userid) ~= nil then
		isValidPlayer = true
		isInGame = false
		plrObject = nil
	end
	return isValidPlayer,isInGame,plrObject
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

return module
