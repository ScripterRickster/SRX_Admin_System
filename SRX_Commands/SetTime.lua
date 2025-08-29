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

module.ExecutionLevel = 1; -- rank id required to execute the command
module.LockToRank = false; -- whether or not if it is only available to the rank put in "ExecutionLevel" | false -> any rank above the posted requirement can execute the rank | true -> only the required rank can execute the command

module.CommandDescription = "To change the time in-game"; -- description of the command

module.Parameters = {
	-- put whatever parameters you need for the command to work under here
	--[[
	[PARAMETER_NAME] = { -- name of the parameter
		Description = ""; -- description of the parameter
		Required = true; -- whether or not if the user is required to input this parameter in order to execute the command
	}
	
	]]
	
	["TIME"] = {
		Description = "Time of day (24h format)";
		Required = true;
	}
}


module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
	"time"
}

module.SendLog = true -- whether the command is logged or not


module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local execSuccess = false
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		local e_rID = executor:GetAttribute("SRX_RANKID")
		
		if serverUtil.PlayerCanUseCommand(executor,script) then
			
			local timeOfDay = tonumber(tostring(parameters["TIME"]))
			
			if timeOfDay ~= nil then
				game.Lighting.ClockTime = timeOfDay
			end
			
			
			execSuccess = true

		end
	end
	
	return execSuccess
	
end

return module
