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

module.ExecutableCommand = false; -- whether you can actually even use this command or not || this parameter is not required
module.ExecutionLevel = 0; -- rank id required to execute the command
module.LockToRank = false; -- whether or not if it is only available to the rank put in "ExecutionLevel" | false -> any rank above the posted requirement can execute the rank | true -> only the required rank can execute the command

module.CommandDescription = ""; -- description of the command

module.Parameters = {
	-- put whatever parameters you need for the command to work under here
	--[[
	[PARAMETER_NAME] = { -- name of the parameter
		Description = ""; -- description of the parameter
		Required = true; -- whether or not if the user is required to input this parameter in order to execute the command
	}
	
	]]
}


module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
}


module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		local e_rID = executor:GetAttribute("SRX_RANKID")
		
		if serverUtil.PlayerCanUseCommand(executor,script) then
			
			task.defer(function() -- notifies the server to log this command being run
				serverUtil.LogCommand(script,parameters)
			end)
			
			
			-- do whatever here
		end
	end
	
end

return module
