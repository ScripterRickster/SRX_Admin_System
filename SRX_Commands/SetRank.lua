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
local playerUtil = require(UTILITIES.PlayerUtilities)

----------------------------------------------------------------

module.ExecutableCommand = true; -- whether you can actually even use this command or not
module.ExecutionLevel = 3; -- rank id required to execute the command
module.LockToRank = false; -- whether or not if it is only available to the rank put in "ExecutionLevel" | false -> any rank above the posted requirement can execute the rank | true -> only the required rank can execute the command

module.CommandDescription = "Sets the rank of the player"

module.Parameters = {
	["TARGET"] = { -- name of parameter
		Description = "Target of the command"; -- description of the parameter
		Required = true; -- whether or not if the user is required to input this parameter in order to execute the command
		
	};
	["RANK"] = {
		Description = "Target rank";
		Required = true;
	}
}

module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
	"rank";
}

module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		
		local e_rID = executor:GetAttribute("SRX_RANKID")
		if serverUtil.PlayerCanUseCommand(executor,script) then
			local isValid,isInGame,target = playerUtil.FindPlayer(parameters["TARGET"])
			
			print(target)
			
			local rank_name,rank_id = serverUtil.FindRank(parameters["RANK"],parameters["RANK"])
			if target and rank_id then
				local tRankId,tRankName = playerUtil.GetPlayerRankInfo(target)
				
				if tRankId <= e_rID and rank_id < e_rID then
					playerUtil.SetPlayerRank(target,rank_id)
				end
			end
			
			
		end
	end
	
end

return module
