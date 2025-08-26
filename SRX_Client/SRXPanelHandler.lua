local events = game.ReplicatedStorage:WaitForChild("SRX_Events")
local csc_event = events:WaitForChild("CSC_Event")
local csc_func = events:WaitForChild("CSC_Func")
local panelcsc_event = events:WaitForChild("PanelCSC_Event")

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
local closeBttn = generalInfo:WaitForChild("Close")
local homeBttn = generalInfo:WaitForChild("Home")
returnBttn.Visible = false
homeBttn.Visible = false
closeBttn.Visible = true




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

-- cmdpanel
local cmdPanel = main:WaitForChild("CMDPanel")
local currCMDNameText = cmdPanel:WaitForChild("Titles"):WaitForChild("CMDName")
local cmdActivateBttn = cmdPanel:WaitForChild("Activate")
local cmdParameterList = cmdPanel:WaitForChild("Parameters"):WaitForChild("List")
local cmdParameterTemplate = cmdParameterList:WaitForChild("Template")

-- infractions page
local infracUserSearch = infractions:WaitForChild("UserSearch"):WaitForChild("SearchBox")
local infractionList = infractions:WaitForChild("InfractionFrame"):WaitForChild("InfractionList")
local infractionTemplate = infractionList:WaitForChild("Template")

-- other
local pageHistory = {
	home,
}
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

function loadCMDPanel(cmd,cmdParams)
	if cmd and cmdParams then
		for _,v in pairs(cmdParameterList:GetChildren()) do
			if v:IsA("Frame") and string.lower(v.Name) ~= "template" then v:Destroy() end
		end
		currCMDNameText.Text = tostring(cmd)
		for pName,v in pairs(cmdParams) do
			local newParamTemplate = cmdParameterTemplate:Clone()
			
			local placeholderTxt = v["Description"]
			
			if placeholderTxt == nil or placeholderTxt == "" then placeholderTxt = "Input......" end
			newParamTemplate:WaitForChild("Input").PlaceholderText = placeholderTxt
			
			local paramRequired = v["Required"]
			if paramRequired == nil then paramRequired = false end
			newParamTemplate:WaitForChild("Input"):SetAttribute("Required",paramRequired)
			
			newParamTemplate:WaitForChild("Title").Text = pName
			
			newParamTemplate.Name = pName
			
			newParamTemplate.Parent = cmdParameterList
			newParamTemplate.Visible = true
		end
		
	end
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
		newCMDTemplate.Name = tostring(v)
		newCMDTemplate.Parent = cmdList
		newCMDTemplate.Visible = true
		
		newCMDTemplate:WaitForChild("Use").Activated:Connect(function()
			loadCMDPanel(string.upper(tostring(v)),cmdParams)
			changePage(cmdPanel)
		end)
	end
end

function loadUserInfractions(targUID)
	for _,v in pairs(infractionList:GetChildren()) do
		if string.lower(v.Name) ~= "template" and v:IsA("Frame") then v:Destroy() end
	end
	if targUID then
		local uInfracs = csc_func:InvokeServer("GETPLAYERINFRACTIONS",targUID)
		if uInfracs ~= nil then
			for infracID,infracInfo in pairs(uInfracs) do

				local newInfractionTemplate = infractionTemplate:Clone()
				newInfractionTemplate.Name = tostring(infracID)
				
				local infracReason = tostring(infracInfo["Reason"])
				local staffMem = game.Players:GetNameFromUserIdAsync(tonumber(infracInfo["StaffMemberID"]))
				local canDelete = infracInfo["CanDelete"]
				local infracDuration = infracInfo["Duration"]
				local infracReason = tostring(infracInfo["Reason"])
				local infracType = tostring(infracInfo["InfractionType"])
				local timeIssued = os.date("*t",tonumber(tostring(infracInfo["InfractionTime"])))
				
				local formattedTime = string.format("%02d/%02d/%04d %02d:%02d:%02d",
					timeIssued.day,
					timeIssued.month,
					timeIssued.year,
					timeIssued.hour,
					timeIssued.min,
					timeIssued.sec
				)
				
				newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("StaffMember"):WaitForChild("Content").Text = staffMem.." ("..tostring(infracInfo["StaffMemberID"])..")"
				newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("InfractionID"):WaitForChild("Content").Text = tostring(infracID)
				newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("Description"):WaitForChild("Content").Text = infracReason
				newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("TimeIssued"):WaitForChild("Content").Text = formattedTime
				newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("Duration"):WaitForChild("Content").Text = tostring(infracDuration)
				
				if infracType == nil or infracType == "" then
					infracType = "UNKNOWN"
				end
				
				infracType = tostring(infracType)
				
				newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("InfractionType"):WaitForChild("Content").Text = infracType
				
				if infracDuration == nil or infracDuration == "" then
					newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("Duration").Visible  = false
				else
					newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("Duration").Visible = true
				end
				
				if canDelete then
					newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("Delete").Visible = true
					newInfractionTemplate:WaitForChild("InternalFrame"):WaitForChild("Delete").Activated:Connect(function()
						csc_event:FireServer("REMOVEINFRACTION",targUID,infracID)
						loadUserInfractions(targUID)
					end)
				else
					newInfractionTemplate:WaitForChild('InternalFrame'):WaitForChild("Delete").Visible = false
				end
				newInfractionTemplate.Parent = infractionList
				newInfractionTemplate.Visible = true
			end
		end
	end
end

function filterCMDS(txt:string)
	if txt == nil then return end
	txt = string.lower(tostring(txt))
	for _,v in pairs(cmdList:GetChildren()) do
		if string.lower(v.Name) ~= "template" and v:IsA("Frame") then 
			if txt == "" then
				v.Visible = true 
			else
				local cName = string.lower(v.Name)
				if string.match(cName,txt) ~= nil then
					v.Visible = true
				else
					v.Visible = false
				end
			end
			
		end
		
	end
end


function clearInputs(dPage:Frame)
	for _,v in pairs(dPage:GetDescendants()) do
		if v:IsA("TextBox") then v.Text = "" end
	end
end



function changeVisibleStatus(dPage:Frame,CName,DName:string,Status:boolean,CaseSensitive:boolean)
	if dPage and CName and DName and Status ~= nil then
		for _,v in pairs(dPage:GetDescendants()) do
			if v:IsA(CName) then
				if (CaseSensitive and DName == v.Name) or (not CaseSensitive and string.lower(DName) == string.lower(v.Name)) then
					v.Visible = Status
				end
			end
		end
	end
end


function changePage(dPage:Frame,returning:boolean)
	if dPage then
		local currPage = pageHistory[#pageHistory]
		
		if currPage then currPage.Visible = false end
		
		if returning then
			table.remove(pageHistory,#pageHistory)
		end
		
		
		if dPage ~= home then 
			returnBttn.Visible = true 
			homeBttn.Visible = true
			closeBttn.Visible = false 
		else 
			table.clear(pageHistory)
			returnBttn.Visible = false 
			homeBttn.Visible = false
			closeBttn.Visible = true 
		end
		
		dPage.Visible = true
		table.insert(pageHistory,dPage)
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
	local idx = math.max(#pageHistory-1,0)
	changePage(pageHistory[idx],true)
end)

homeBttn.Activated:Connect(function()
	changePage(home)
end)

closeBttn.Activated:Connect(function()
	csc_event:FireServer("closeadminpanel")
end)


cmdActivateBttn.Activated:Connect(function()
	local currPage = pageHistory[#pageHistory]
	if currPage == cmdPanel then
		local dParams = cmdParameterList:GetChildren()
		local allParams = {}
		
		local c_cmd = currCMDNameText.Text
		table.insert(allParams,c_cmd)
		
		local succ = true
		
		for _,v in pairs(dParams) do
			if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
				local userInput = v:WaitForChild("Input")
				local txt = userInput.Text
				local paramName = v.Name
				
				local warnMsg = v:WaitForChild("WarnMessage")
				
				if userInput:GetAttribute("Required") then
					if txt == "" or txt == nil then
						warnMsg.Visible = true
						succ = false
					end
				end
				
				table.insert(allParams,txt)
			end
			
		end
		
		
		if succ then
			csc_event:FireServer("CMDACTIVATION",allParams)
			task.defer(function()
				changeVisibleStatus(cmdPanel,"TextLabel","WarnMessage",false,false)
			end)
			task.defer(function()
				clearInputs(cmdPanel)
			end)
		end
		
	end
end)


cmdSearch:GetPropertyChangedSignal("Text"):Connect(function()
	filterCMDS(cmdSearch.Text)
end)

infracUserSearch.FocusLost:Connect(function()
	local targUID = tonumber(infracUserSearch.Text)
	
	if targUID == nil and infracUserSearch.Text ~= "" then
		targUID = game.Players:GetUserIdFromNameAsync(infracUserSearch.Text)
	end
	loadUserInfractions(targUID)
end)


panelcsc_event.OnClientEvent:Connect(function(param1,param2,param3,param4,param5)
	if param1 then
		param1 = string.lower(tostring(param1))
		
		if param1 == "updatepanel" then
			changePage(home)
			task.defer(setupGeneralInfo)
		end
	end
end)

task.defer(setupGeneralInfo)

---------------------
-- Draggable UI Stuff

local UIS = game:GetService('UserInputService')
local dragToggle = nil
local dragSpeed = 0.25
local dragStart = nil
local startPos = nil

local function updateInput(input)
	local delta = input.Position - dragStart
	local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	game:GetService('TweenService'):Create(main, TweenInfo.new(dragSpeed), {Position = position}):Play()
end

main.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
		dragToggle = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragToggle = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragToggle then
			updateInput(input)
		end
	end
end)


