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
repeat wait() until _G.SRX_WORKSPACE ~= nil
local SRX_WORKSPACE = _G.SRX_WORKSPACE
repeat wait() until _G.SRX_ASSETS ~= nil
local ASSETS = _G.SRX_ASSETS
----------------------------------------------------------------

local serverUtil = require(UTILITIES.ServerUtilities)
local playerUtil = require(UTILITIES.PlayerUtilities)

----------------------------------------------------------------

module.ExecutionLevel = 2; -- rank id required to execute the command
module.LockToRank = false; -- whether or not if it is only available to the rank put in "ExecutionLevel" | false -> any rank above the posted requirement can execute the rank | true -> only the required rank can execute the command

module.CommandDescription = "Unbans the target if they're banned"; -- description of the command

module.Parameters = {
	-- put whatever parameters you need for the command to work under here
	--[[
	[PARAMETER_NAME] = { -- name of the parameter
		Description = ""; -- description of the parameter
		Required = true; -- whether or not if the user is required to input this parameter in order to execute the command
	}
	
	]]
	
	["TARGET"] = {
		Description = "Target of the command"; 
		Required = true; 
		Class = "User";

	};
	
	["REASON"] = {
		Description = "Reason for the unban";
		Required = false;
	}
	
	
}


module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
}

local excludeAlts = SETTINGS.BanSettings.ExcludeAltsInBans

function isUserBanned(userid:number)
	if userid then
		
		local function toUTC(isoString:string)
			local year, month, day, hour, min, sec = isoString:match(
				"^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)Z$"
			)

			if not (year and month and day and hour and min and sec) then
				warn("Invalid ISO 8601 format:", isoString)
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
			warn("Error retrieving ban history")
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
module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		local e_rID = executor:GetAttribute("SRX_RANKID")
		
		if serverUtil.PlayerCanUseCommand(executor,script) then
			local isValid,userID,target = playerUtil.FindPlayer(parameters["TARGET"])
			userID = tonumber(tostring(userID))
			
			local reason = parameters["REASON"]
			if reason == nil then reason = "N/A" end
			reason = serverUtil.FilterMessage(executor,reason)
			
			if isValid and userID then
				local isBanned = isUserBanned(userID)
				
				if isBanned then
					local unbanConfig = {
						UserIds = {tonumber(userID)},
						ApplyToUniverse = true,
					}
					
					local succ,err = pcall(function()
						game.Players:UnbanAsync(unbanConfig)
					end)

					if not succ and err then
						warn("Failed to unban:",tostring(userID),"| Error: "..tostring(err))
					elseif succ then
						task.defer(function()
							local durationText = "Permanent"
							
							local infracData = {

								StaffMemberID = executor.UserId;
								InfractionType = "Unban";
								Reason = reason;
								Duration = durationText;

							}
							playerUtil.RecordPlayerInfraction(target.UserId,infracData)
						end)
						task.defer(function() -- notifies the server to log this command being run
							serverUtil.LogCommand(script,parameters)
						end)
					end
				end
			end
		end
	end
	
end

return module
