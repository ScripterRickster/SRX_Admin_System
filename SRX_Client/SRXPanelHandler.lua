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


function changePage(dPage:Frame)
	if dPage then
		local currPage = pageHistory[#pageHistory]
		
		if currPage then currPage.Visible = false end
		
		
		
		dPage.Visible = true
		table.insert(pageHistory,dPage)
		
		if dPage ~= home then 
			returnBttn.Visible = true 
			homeBttn.Visible = true
			closeBttn.Visible = false 
		else 
			returnBttn.Visible = false 
			homeBttn.Visible = false
			closeBttn.Visible = true 
		end
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
	pageHistory[#pageHistory].Visible = false
	table.remove(pageHistory,#pageHistory)
	changePage(pageHistory[#pageHistory])
end)

homeBttn.Activated:Connect(function()
	pageHistory[#pageHistory].Visible = false
	table.clear(pageHistory)
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


task.defer(setupGeneralInfo)
