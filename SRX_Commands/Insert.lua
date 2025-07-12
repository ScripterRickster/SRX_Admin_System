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
----------------------------------------------------------------

local serverUtil = require(UTILITIES.ServerUtilities)
local playerUtil = require(UTILITIES.PlayerUtilities)

----------------------------------------------------------------

module.ExecutionLevel = 3; -- rank id required to execute the command
module.LockToRank = false; -- whether or not if it is only available to the rank put in "ExecutionLevel" | false -> any rank above the posted requirement can execute the rank | true -> only the required rank can execute the command

module.CommandDescription = "Inserts the given asset ID"; -- description of the command

module.Parameters = {
	-- put whatever parameters you need for the command to work under here
	--[[
	[PARAMETER_NAME] = { -- name of the parameter
		Description = ""; -- description of the parameter
		Required = true; -- whether or not if the user is required to input this parameter in order to execute the command
	}
	
	]]
	
	["ASSET_ID"] = {
		Description = "ID of the asset";
		Required = true; 

	};
	
}


module.Aliases = { -- other names that tie it to this command
	-- "alias_name1";
}

local excludeAlts = SETTINGS.BanSettings.ExcludeAltsInBans


module.Execute = function(parameters:table)
	-- !! BY DEFAULT, ALL PARAMETER TABLES WILL INCLUDE THE PERSON WHO EXECUTED THE COMMAND | IT WILL BE STORED IN AS "EXECUTOR" !!
	
	local meetsRequirements = serverUtil.CheckCommandRequirements(module.Parameters,parameters)
	
	if meetsRequirements then
		local executor = parameters.EXECUTOR
		local e_rID = executor:GetAttribute("SRX_RANKID")
		
		if serverUtil.PlayerCanUseCommand(executor,script) then
			local asset_id = parameters["ASSET_ID"]
			
			if asset_id then
				local succ,res = pcall(function()
					return game:GetService("InsertService"):LoadAsset(asset_id)
				end)
				
				if not succ then
					warn("FAILED TO INSERT:",tostring(asset_id))
				else
					if res then
						if res:IsA("Tool") then
							res.Parent = executor.Backpack
						elseif res:IsA("Model") then
							res.Parent = SRX_WORKSPACE
							
							local exec_char = executor.Character or executor.CharacterAdded:Wait()
							local exec_hrp = exec_char:WaitForChild("HumanoidRootPart")
							
							local exec_pos = exec_hrp.Position
							
							res:MoveTo(Vector3.new(exec_pos.X,exec_pos.Y+20,exec_pos.Z))
						end
						
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
