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

module.ExecutableCommand = true; -- whether you can actually even use this command or not || this parameter is not required
module.ExecutionLevel = 2; -- rank id required to execute the command
module.LockToRank = false; -- whether or not if it is only available to the rank put in "ExecutionLevel" | false -> any rank above the posted requirement can execute the rank | true -> only the required rank can execute the command

module.CommandDescription = "Bans the target"; -- description of the command

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
		Description = "Reason for the ban";
		Required = false;
	};
	["DURATION"] = {
		Description = "Duration of the ban (-1 or nil = permanent) | In Days";
		Required = false;
	};
	
}


module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
}

local excludeAlts = SETTINGS.BanSettings.ExcludeAltsInBans

module.SendLog = true -- whether the command is logged or not

module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local execSuccess = false
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		local e_rID = executor:GetAttribute("SRX_RANKID")
		
		if serverUtil.PlayerCanUseCommand(executor,script) then
			local isValid,userID,target = playerUtil.FindPlayer(parameters["TARGET"])

			if target then
				local tRankId,tRankName = playerUtil.GetPlayerRankInfo(target)
				
				if tRankId < e_rID then
					local banReason,banDuration = serverUtil.FilterMessage(executor,parameters["REASON"]),parameters["DURATION"]
					if banReason == nil then banReason = "No Reason" end
					banDuration = tonumber(tostring(banDuration))
					if banDuration == nil then banDuration = -1 end



					local banConfig = {
						UserIds = {target.UserId},
						Duration = banDuration * 86400,
						DisplayReason = banReason,
						PrivateReason = banReason,
						ExcludeAltAccounts = excludeAlts,
						ApplyToUniverse = true,
					}

					local succ,err = pcall(function()
						local durationText = "Permanent"
						if banDuration ~= -1 then
							durationText = banDuration.." Days"

						end
						local infracData = {

							StaffMemberID = executor.UserId;
							InfractionType = "Ban";
							Reason = banReason;
							Duration = durationText;

						}
						playerUtil.RecordPlayerInfraction(target.UserId,infracData)
						game.Players:BanAsync(banConfig)
					end)

					if not succ and err then
						warn("Failed to ban: "..target.Name.." ("..tostring(target.UserId)..") | Error: "..tostring(err))
					elseif succ then
						execSuccess = true
					end
				end
				
				
				
			end
		end
	end
	
	return execSuccess
	
end

return module
