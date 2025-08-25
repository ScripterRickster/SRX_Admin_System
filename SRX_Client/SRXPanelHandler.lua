
local events = game.ReplicatedStorage:WaitForChild("SRX_Events")
local csc_event = events:WaitForChild("CSC_Event")
local csc_func = events:WaitForChild("CSC_Func")

local player = game.Players.LocalPlayer

local main = script.Parent:WaitForChild("Main")

local currPage = nil

-- main displays
local home = main:WaitForChild("Home")
local cmds = main:WaitForChild("Commands")
local infractions = main:WaitForChild("Infractions")
local logs = main:WaitForChild("Logs")

-- general info
local generalInfo = main:WaitForChild("GeneralInfo")
local adminVersionText = generalInfo:WaitForChild("AdminVersion"):WaitForChild("VersionText")
local serverIDText = generalInfo:WaitForChild("ServerId"):WaitForChild("IDText")
local timeText = generalInfo:WaitForChild("Time"):WaitForChild("TimeText")
local userPFPDisplay,userRankDisplay,userNameDisplay = generalInfo:WaitForChild("UserDisplay"):WaitForChild("PFP"),generalInfo:WaitForChild("UserDisplay"):WaitForChild("Rank"),generalInfo:WaitForChild("UserDisplay"):WaitForChild("Username")
local returnBttn = generalInfo:WaitForChild("Return")
returnBttn.Visible = false

-- home page
local H_Options = home:WaitForChild("MainOptions")
local MainButtons = {
	["AIChatBttn"] = H_Options:WaitForChild("AIChat"):WaitForChild("Enter");
	["CMDSBttn"] = H_Options:WaitForChild("Commands"):WaitForChild("Enter");
	["InfracBttn"] = H_Options:WaitForChild("Infractions"):WaitForChild("Enter");
	["LogsBttn"] = H_Options:WaitForChild("Logs"):WaitForChild("Enter");
	["SettingsBttn"] = H_Options:WaitForChild("Settings"):WaitForChild("Enter");
	
}


-------------------------------------------------------------------------------------

function setupGeneralInfo()
	local rID,rName,rClr = csc_func:InvokeServer("GETRANKINFO")
	local adminV = csc_func:InvokeServer("GETADMINVERSION")
	local sID = csc_func:InvokeServer("GETSERVERID")
	local canUseAI = csc_func:InvokeServer("CANUSEAI")
	
	userPFPDisplay.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	
	MainButtons["AIChatBttn"].Parent.Visible = canUseAI
	

	userNameDisplay.Text = string.upper(player.Name)
	userRankDisplay.Text = string.upper(rName)

	if rClr then
		userRankDisplay.TextColor3 = rClr
	else
		userRankDisplay.TextColor3 = Color3.fromRGB(255,255,255)
	end
end



function changePage(bttn)
	
end




