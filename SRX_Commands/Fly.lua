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

module.CommandDescription = "Allows the player to fly"; -- description of the command

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
	
	["SPEED"] = {
		Description = "The speed you want to fly at";
		Required = false;
	}
}


module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
}

local defaultFlyingSpeed = 50
local flyingAssets = ASSETS:WaitForChild("FlyingAssets")


module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		local e_rID = executor:GetAttribute("SRX_RANKID")
		
		if serverUtil.PlayerCanUseCommand(executor,script) then
			local isValid,userID,target = playerUtil.FindPlayer(parameters["TARGET"])

			if target and not target:GetAttribute("SRX_FLYING") then
				
				local flyingSpeed = parameters["SPEED"]
				
				if flyingSpeed == nil or tonumber(tostring(flyingSpeed)) == nil then
					flyingSpeed = defaultFlyingSpeed
				end
				
				local tRankId,tRankName = playerUtil.GetPlayerRankInfo(target)

				if tRankId <= e_rID then
					
					target:SetAttribute("SRX_FLYING",true)

					local char = target.Character or target.CharacterAdded:Wait()
					
					local newFlightScript = flyingAssets:WaitForChild("Flight"):Clone()
					
					newFlightScript:WaitForChild("Speed").Value = tonumber(flyingSpeed) or defaultFlyingSpeed
					
					local newFlightGyro,newFlightPos = flyingAssets:WaitForChild("FlightGyro"):Clone(),flyingAssets:WaitForChild("FlightPos"):Clone()
					
					local hrp = char:WaitForChild("HumanoidRootPart")
					
					newFlightScript.Parent = hrp
					newFlightGyro.Parent = hrp
					newFlightPos.Parent = hrp

					task.defer(function() -- notifies the server to log this command being run
						serverUtil.LogCommand(script,parameters)
					end)
				end
			end

		end
	end
	
end

return module
