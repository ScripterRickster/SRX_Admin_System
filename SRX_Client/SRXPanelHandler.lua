local events = game.ReplicatedStorage:WaitForChild("SRX_Events")
local csc_event = events:WaitForChild("CSC_Event")
local csc_func = events:WaitForChild("CSC_Func")

local player = game.Players.LocalPlayer

local main = script.Parent:WaitForChild("Main")



-- main displays
local home = main:WaitForChild("Home")
local cmds = main:WaitForChild("Commands")
local cmdPanel = main:WaitForChild("CMDPanel")
local infractions = main:WaitForChild("Infractions")
local logs = main:WaitForChild("Logs")
local aiPage = nil

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
	["AIChatBttn"] = {
		TButton = H_Options:WaitForChild("AIChat"):WaitForChild("Enter");
		DesiredPage = aiPage;
	};
	["CMDSBttn"] = {
		TButton = H_Options:WaitForChild("Commands"):WaitForChild("Enter");
		DesiredPage = cmds;
	};
	["InfracBttn"] = {
		TButton = H_Options:WaitForChild("Infractions"):WaitForChild("Enter");
		DesiredPage = infractions;
	};
	["LogsBttn"] = {
		TButton = H_Options:WaitForChild("Logs"):WaitForChild("Enter");
		DesiredPage = logs;
	};
	["SettingsBttn"] = {
		TButton = H_Options:WaitForChild("Settings"):WaitForChild("Enter");
		DesiredPage = nil;
	};


}

-- cmds page
local cmdList = cmds:WaitForChild("CMDFrame"):WaitForChild("CMDList")
local cmdTemplate = cmdList:WaitForChild("Template")
local cmdSearch = cmds:WaitForChild("CMDSearch"):WaitForChild("SearchBox")


-- other
local currPage = home
-------------------------------------------------------------------------------------

function setupGeneralInfo()
	local rID,rName,rClr = csc_func:InvokeServer("GETRANKINFO")
	local adminV = csc_func:InvokeServer("GETADMINVERSION")
	local sID = csc_func:InvokeServer("GETSERVERID")
	local canUseAI = csc_func:InvokeServer("CANUSEAI")
	
	userPFPDisplay.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	
	MainButtons["AIChatBttn"].TButton.Parent.Visible = canUseAI
	
	rID,rName = tostring(rID),tostring(rName)
	
	userNameDisplay.Text = string.upper(player.Name)
	userRankDisplay.Text = string.upper(rName)

	if rClr then
		userRankDisplay.TextColor3 = rClr
	else
		userRankDisplay.TextColor3 = Color3.fromRGB(255,255,255)
	end
	
	adminVersionText.Text = "VERSION: "..tostring(adminV)
	serverIDText.Text = tostring(sID)
	
	task.defer(loadUserCommands)
end

function loadUserCommands()
	for _,v in pairs(cmdList:GetChildren()) do
		if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
			v:Destroy()
		end
	end
	
	local newCMDS = csc_func:InvokeServer("GETPLAYERCMDS")
	
	for _,v in pairs(newCMDS) do
		local newCMDTemplate = cmdTemplate:Clone()
		newCMDTemplate:WaitForChild("Title").Text = "<u>"..string.upper(tostring(v)).."</u>"
		
		local cmdDesc,cmdParams = csc_func:InvokeServer("GETCMDINFO",v)
		
		if cmdDesc == nil then cmdDesc = "N/A" end
		
		cmdDesc = tostring(cmdDesc)
		newCMDTemplate:WaitForChild("Description").Text = cmdDesc
		newCMDTemplate.Parent = cmdList
		newCMDTemplate.Visible = true
		
		newCMDTemplate:WaitForChild("Use").Activated:Connect(function()
			
		end)
	end
end



function changePage(dPage:Frame)
	if dPage then
		if currPage then currPage.Visible = false end
		
		dPage.Visible = true
		currPage = dPage
		
		if currPage ~= home then returnBttn.Visible = true else returnBttn.Visible = false end
	end
end


for _,v in pairs(MainButtons) do
	local pBttn = v.TButton
	local dPage = v.DesiredPage
	
	if dPage and pBttn then
		pBttn.Activated:Connect(function()
			task.defer(function()
				changePage(dPage)
			end)
		end)
	end
end


returnBttn.Activated:Connect(function()
	changePage(home)
end)



task.defer(setupGeneralInfo)
