-- services
local UIS = game:GetService('UserInputService')

-- core
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
local aiPage = main:WaitForChild("AI_Panel")
local helpReqPage = main:WaitForChild("HelpRequests")
local settingsPage = main:WaitForChild("Settings")

local panelTheme = main:WaitForChild("UserTheme")

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
	["HelpReqBttn"] = {
		TButton = H_Options:WaitForChild("HelpRequests"):WaitForChild("Enter");
		DesiredPage = helpReqPage;
	};
	["SettingsBttn"] = {
		TButton = H_Options:WaitForChild("Settings"):WaitForChild("Enter");
		DesiredPage = settingsPage;
	};


}

-- cmds page
local cmdList = cmds:WaitForChild("CMDFrame"):WaitForChild("CMDList")
local cmdLoadingMsg = cmds:WaitForChild("CMDFrame"):WaitForChild("LoadingCMDSMessage")
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

-- logs page

local chatLogsList = logs:WaitForChild("LogFrame"):WaitForChild("ChatLogList")
local commandLogsList = logs:WaitForChild("LogFrame"):WaitForChild("CMDLogList")

local chatlogTemplate = chatLogsList:WaitForChild("Template")
local cmdlogTemplate = commandLogsList:WaitForChild("Template")

local cmdlogSearch = logs:WaitForChild("SearchAreas"):WaitForChild("CMDLogSearchBox")
local chatlogSearch = logs:WaitForChild("SearchAreas"):WaitForChild("ChatLogSearchBox")

-- ai page
local AICommList = aiPage:WaitForChild("CommunicationFrame"):WaitForChild("MessagesList")
local AI_UTemplate = AICommList:WaitForChild("UserTemplate")
local AI_AITemplate = AICommList:WaitForChild("AITemplate")
local AI_SearchBox = aiPage:WaitForChild("SearchArea"):WaitForChild("SearchBox")
local AIMsgCount,AIDebounce = 0,false

-- help requests page
local HelpRequestsList = helpReqPage:WaitForChild("HelpRequestDisplay"):WaitForChild("HelpRequestList")
local HelpRequestTemplate = HelpRequestsList:WaitForChild("Template")
local HelpRequestSearch = helpReqPage:WaitForChild("SearchArea"):WaitForChild("SearchBox")


-- settings page
local SettingsList = settingsPage:WaitForChild("MainFrame"):WaitForChild("SettingsList")

local PrefixSetting = SettingsList:WaitForChild("Prefix")
local PrefixButton = PrefixSetting:WaitForChild("PrefixButton")
local PrefixMsg = PrefixSetting:WaitForChild("Message")

local prefixChanging = false

local ThemeSetting = SettingsList:WaitForChild('Theme')
local ThemeChangebutton = ThemeSetting:WaitForChild("ThemeButton")
local ThemeList = ThemeSetting:WaitForChild("ThemesList")
local ThemeTempate = ThemeList:WaitForChild("TEMPLATE")

-- other
local pageHistory = {
	home,
}


local validKeyCodes = {
	["A"] = "a";
	["B"] = "b";
	["C"] = "c";
	["D"] = "d";
	["E"] = "e";
	["F"] = "f";
	["G"] = "g";
	["H"] = "h";
	["I"] = "i";
	["J"] = "j";
	["K"] = "k";
	["L"] = "l";
	["M"] = "m";
	["N"] = "n";
	["O"] = "o";
	["P"] = "p";
	["Q"] = "q";
	["R"] = "r";
	["S"] = "s";
	["T"] = "t";
	["U"] = "u";
	["V"] = "v";
	["W"] = "w";
	["X"] = "x";
	["Y"] = "y";
	["Z"] = "z";
	["One"] = "1";
	["Two"] = "2";
	["Three"] = "3";
	["Four"] = "4";
	["Five"] = "5";
	["Six"] = "6";
	["Seven"] = "7";
	["Eight"] = "8";
	["Nine"] = "9";
	["Zero"] = "0";
	["QuotedDouble"] = '"';
	["Hash"] = "#";
	["Dollar"] = "$";
	["Percent"] = "%";
	["Ampersand"] = "&";
	["Quote"] = "'";
	["LeftParenthesis"] = "(";
	["RightParenthesis"] = ")";
	["Asterisk"] = "*";
	["Plus"] = "+";
	["Minus"] = "-";
	["Equals"] = "=";
	["Comma"] = ",";
	["Period"] = ".";
	["Slash"] = "/";
	["Colon"] = ":";
	["Semicolon"] = ";";
	["LessThan"] = "<";
	["GreaterThan"] = ">";
	["Question"] = "?";
	["At"] = "@";
	["LeftBracket"] = "[";
	["RightBracket"] = "]";
	["Backslash"] = '\ ';
	["Caret"] = "^";
	["Underscore"] = "_";
	["Backquote"] = "`";
	["Tilde"] = "~";
	["LeftCurly"] = "{";
	["RightCurly"] = "}";
	["Pipe"] = "|";
	
}

local cmdCooldown,onCMDCooldown = math.huge,false

-------------------------------------------------------------------------------------

function setupGeneralInfo()
	local rID,rName,rClr = csc_func:InvokeServer("GETRANKINFO")
	local adminV = csc_func:InvokeServer("GETADMINVERSION")
	local sID = csc_func:InvokeServer("GETSERVERID")
	local canUseAI = csc_func:InvokeServer("CANUSEAI")
	local canViewHelpReq = csc_func:InvokeServer("CANVIEWHELPREQ")
	local currUserTheme = csc_func:InvokeServer("GETPLAYERTHEME")
	local currUserPrefix = csc_func:InvokeServer("GETPLAYERPREFIX")
	local allHelpRequests = csc_func:InvokeServer("GETALLHELPREQUESTS")
	
	for _,v in pairs(HelpRequestsList:GetChildren()) do
		if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
			v:Destroy()
		end
	end
	
	for helpReqIDX,helpReqV in pairs(allHelpRequests) do
		if helpReqV then
			task.defer(function()
				createHelpRequest(game.Players:GetPlayerByUserId(tonumber(helpReqIDX)))
			end)
		end
	end
	
	local allThemes = csc_func:InvokeServer("GETALLTHEMES")
	
	for _,v in pairs(ThemeList:GetChildren()) do
		if v:IsA("ImageButton") and string.lower(v.Name) ~= "template" then
			v:Destroy() 
		end
	end
	
	if allThemes ~= nil and typeof(allThemes) == 'table' then
		for tN,tID in pairs(allThemes) do
			local nThemeBttn = ThemeTempate:Clone()
			local themeID = tID.ThemeID
			nThemeBttn.Image = themeID
			nThemeBttn.Name = tN
			nThemeBttn:WaitForChild("ThemeName").Text = tN
			nThemeBttn.Parent = ThemeList
			nThemeBttn.Visible = true
			
			nThemeBttn.Activated:Connect(function()
				csc_event:FireServer("CHANGETHEME",themeID)
				
				ThemeList.Visible = false
			end)
		end
	end
	
	panelTheme.Image = currUserTheme
	PrefixButton.Text = currUserPrefix
	
	userPFPDisplay.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	
	MainButtons["AIChatBttn"].TButton.Parent.Visible = canUseAI
	MainButtons["HelpReqBttn"].TButton.Parent.Visible = canViewHelpReq
	
	rID,rName = tostring(rID),tostring(rName)
	
	userNameDisplay.Text = string.upper(player.Name)
	userRankDisplay.Text = string.upper(rName)

	if rClr then
		userRankDisplay.TextColor3 = rClr
	else
		userRankDisplay.TextColor3 = Color3.fromRGB(255,255,255)
	end
	
	cmdCooldown = tonumber(csc_func:InvokeServer("GETCMDCOOLDOWN"))
	if cmdCooldown == nil then cmdCooldown = math.huge warn("SRX | Failed to get command cooldown") end
	
	
	adminVersionText.Text = "VERSION: "..tostring(adminV)
	serverIDText.Text = tostring(sID)
	
	task.defer(loadUserCommands)
	task.defer(loadLogs)
end

function loadCMDPanel(cmd,cmdParams)
	if cmd and cmdParams then
		for _,v in pairs(cmdParameterList:GetChildren()) do
			if v:IsA("Frame") and string.lower(v.Name) ~= "template" then v:Destroy() end
		end
		local idx = 1
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
			newParamTemplate.LayoutOrder = idx
			newParamTemplate.Visible = true
			
			idx += 1
		end
		
	end
end

function loadUserCommands()
	for _,v in pairs(cmdList:GetChildren()) do
		if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
			v:Destroy()
		end
	end
	
	cmdLoadingMsg.Visible = true
	
	local newCMDS = csc_func:InvokeServer("GETPLAYERCMDS")
	
	cmdLoadingMsg.Visible = false
	
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
						task.delay(1,function()
							loadUserInfractions(targUID)
						end)
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

function loadLogs()
	local msgLogs = csc_func:InvokeServer("GETMSGLOGS")
	local cmdLogs = csc_func:InvokeServer("GETCMDLOGS")
	
	for _,v in pairs(commandLogsList:GetChildren()) do
		if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
			v:Destroy()
		end
	end
	
	for _,v in pairs(chatLogsList:GetChildren()) do
		if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
			v:Destroy()
		end
	end
	
	if msgLogs ~= nil then
		
		for _,v in pairs(msgLogs) do
			task.defer(function()
				createLog("msg",v)
			end)
		end
	end
	
	if cmdLogs ~= nil then
		for _,v in pairs(cmdLogs) do
			task.defer(function()
				createLog("cmd",v)
			end)
		end
	end
end

function createLog(logType:string,logInfo:table)
	if logType == nil or logType == "" then return end
	local newLog = nil
	logType = string.lower(tostring(logType))
	if logType == "cmd" then
		newLog = cmdlogTemplate:Clone()
		newLog.Visible = false
		newLog.Parent = commandLogsList
	elseif logType == "msg" then
		newLog = chatlogTemplate:Clone()
		newLog.Visible = false
		newLog.Parent = chatLogsList
	end
	
	local utcTime = os.date("*t",tonumber(tostring(logInfo[2])))
	local staffMemID = tonumber(tostring(logInfo[1]))
	local txtcontent = tostring(logInfo[3])
	
	local plrName,plrImage = "UNKNOWN",""
	
	if staffMemID ~= nil then
		plrName = game.Players:GetNameFromUserIdAsync(staffMemID)
		plrImage = game.Players:GetUserThumbnailAsync(staffMemID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end
	
	local logTime = string.format("%02d:%02d |",
		utcTime.hour,
		utcTime.min
	)
	
	local logDate = string.format("%02d/%02d/%04d",
		utcTime.day,
		utcTime.month,
		utcTime.year
	)
	
	if newLog ~= nil then
		newLog.Name = logType.."_log"
		newLog:WaitForChild("Username").Text = "<u>"..plrName.."</u>"
		newLog:WaitForChild("TextContent").Text = newLog:WaitForChild("TextContent").Text..txtcontent
		newLog:WaitForChild("Date").Text = logDate
		newLog:WaitForChild("Time").Text = logTime
		newLog:WaitForChild("PFP").Image = plrImage
		newLog.Visible = true
	end
end

function createHelpRequest(plr:Player)
	if plr then
		if HelpRequestsList:FindFirstChild(tostring(plr.UserId)) ~= nil then return end
		local newHelpReqTemplate = HelpRequestTemplate:Clone()
		newHelpReqTemplate.Name = tostring(plr.UserId)
		newHelpReqTemplate:WaitForChild("Username").Text = "<u>"..tostring(plr.Name).."</u>"
		newHelpReqTemplate:WaitForChild("PFP").Image = game.Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		
		local utcTime = os.date("*t")
		local helpReqTime = string.format("| %02d:%02d",
			utcTime.hour,
			utcTime.min
		)
		local helpReqDate = string.format("%02d/%02d/%04d",
			utcTime.day,
			utcTime.month,
			utcTime.year
		)
		
		newHelpReqTemplate:WaitForChild("Time").Text = helpReqTime
		newHelpReqTemplate:WaitForChild("Date").Text = helpReqDate
		
		newHelpReqTemplate.Parent = HelpRequestsList
		newHelpReqTemplate.Visible = true
		newHelpReqTemplate:WaitForChild("TeleportButton").Activated:Connect(function()
			csc_event:FireServer("HANDLEHELPREQ",plr)
		end)
		
	end
end

function newAIPrompt(prmpt:string)
	if prmpt == "" or prmpt == nil or AIDebounce then return end
	
	prmpt = csc_func:InvokeServer("filterclientmsg",prmpt)
	AI_SearchBox.TextEditable = false
	AI_SearchBox.Text = ""
	AI_SearchBox.PlaceholderText = "WAITING FOR A RESPONSE......."
	
	AIDebounce = true
	
	AIMsgCount += 1
	
	local newUserMsgTemplate = AI_UTemplate:Clone()
	newUserMsgTemplate:WaitForChild("TextContent").Text = prmpt
	newUserMsgTemplate.LayoutOrder = AIMsgCount
	newUserMsgTemplate.Name = "UserPromptMsg"
	newUserMsgTemplate.Visible = true
	newUserMsgTemplate.Parent = AICommList
	
	
	local aiResponse = csc_func:InvokeServer("GETAIRESPONSE",prmpt)
	
	local aiTextColour = Color3.fromRGB(255,255,255)
	if aiResponse == "ERROR405" then
		aiResponse = "AI Services Has Been Disabled By The Game Developer(s)"
		aiTextColour = Color3.fromRGB(255,0,0)
	elseif aiResponse == nil then
		aiResponse = "Failed To Get A Response"
		aiTextColour = Color3.fromRGB(255,0,0)
	elseif aiResponse == "" then
		aiResponse = "A.I. System Returned A Blank Message"
		aiTextColour = Color3.fromRGB(255, 170, 0)
	end
	
	
	
	AIMsgCount += 1
	
	
	
	local newAIMsgTemplate = AI_AITemplate:Clone()
	newAIMsgTemplate:WaitForChild("TextContent").Text = aiResponse
	newAIMsgTemplate:WaitForChild("TextContent").TextColor3 = aiTextColour
	newAIMsgTemplate.LayoutOrder = AIMsgCount
	newAIMsgTemplate.Name = "AIResponseMsg"
	newAIMsgTemplate.Visible = true
	newAIMsgTemplate.Parent = AICommList
	
	AI_SearchBox.PlaceholderText = "ASK SOMETHING......."
	AI_SearchBox.TextEditable = true
	AIDebounce = false
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

function filterLogs(txt:string,listFrame:ScrollingFrame)
	if txt == nil or listFrame == nil then return end
	txt = string.lower(tostring(txt))
	
	for _,v in pairs(listFrame:GetChildren()) do
		if string.lower(v.Name) ~= "template" and v:IsA("Frame") then
			if txt == "" then
				v.Visible = true
			else
				local userTxt = string.lower(v:WaitForChild("Username").Text)
				local mainTxt = string.lower(v:WaitForChild("TextContent").Text)
				
				if v:WaitForChild("Username").RichText then
					userTxt = string.sub(userTxt,4,string.len(userTxt)-4)
				end
				
				if string.match(userTxt,txt) ~= nil or string.match(mainTxt,txt) ~= nil then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end
	end
end

function filterHelpRequests(txt:string)
	if txt == nil then return end
	txt = string.lower(tostring(txt))
	
	for _,v in pairs(HelpRequestsList:GetChildren()) do
		if string.lower(v.Name) ~= "template" and v:IsA("Frame") then
			if txt == "" then
				v.Visible = true
			else
				local userTxt = string.lower(v:WaitForChild("Username").Text)
				if v:WaitForChild("Username").RichText then
					userTxt = string.sub(userTxt,4,string.len(userTxt)-4)
				end
				if string.match(userTxt,txt) ~= nil then
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
		if prefixChanging then 
			PrefixMsg.Visible = false 
			prefixChanging = false 
		end
		ThemeList.Visible = false
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

function updateClientTime()
	local currTime = os.date("*t")
	local cHour,cMin = currTime.hour,currTime.min
	
	local AM_PM = "AM"
	if cHour >= 12 then
		AM_PM = "PM"
		
		if cHour > 12 then
			cHour -= 12
		end
		
	end
	
	if cMin >= 0 and cMin <= 9 then
		cMin = "0"..tostring(cMin)
	end
	
	timeText.Text = tostring(cHour)..":"..tostring(cMin).." "..AM_PM
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
	if currPage == cmdPanel and not onCMDCooldown then
		onCMDCooldown = true
		
		
		local dParams = cmdParameterList:GetChildren()
		local allParams = {}
		
		local c_cmd = currCMDNameText.Text
		allParams["D_CMD"] = c_cmd
		
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
				
				allParams[paramName] = txt
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
			
			cmdActivateBttn.TextTransparency = 0.5

			local uistroke = cmdActivateBttn:FindFirstChildOfClass("UIStroke")
			if uistroke then
				uistroke.Transparency = 0.5
			end
			
			task.wait(cmdCooldown)
		end
		
		cmdActivateBttn.TextTransparency = 0

		local uistroke = cmdActivateBttn:FindFirstChildOfClass("UIStroke")
		if uistroke then
			uistroke.Transparency = 0
		end
		
		onCMDCooldown = false
		
	end
end)

PrefixButton.Activated:Connect(function()
	if prefixChanging then return end
	prefixChanging = true
	PrefixMsg.Visible = true
end)

ThemeChangebutton.Activated:Connect(function()
	ThemeList.Visible = not ThemeList.Visible
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

chatlogSearch:GetPropertyChangedSignal("Text"):Connect(function()
	filterLogs(chatlogSearch.Text,chatLogsList)
end)

cmdlogSearch:GetPropertyChangedSignal("Text"):Connect(function()
	filterLogs(cmdlogSearch.Text,commandLogsList)
end)

AI_SearchBox.FocusLost:Connect(function()
	newAIPrompt(AI_SearchBox.Text)
end)

HelpRequestSearch:GetPropertyChangedSignal("Text"):Connect(function()
	filterHelpRequests(HelpRequestSearch.Text)
end)

panelcsc_event.OnClientEvent:Connect(function(param1,param2,param3,param4,param5)
	if param1 then
		param1 = string.lower(tostring(param1))
		
		if param1 == "updatepanel" then
			changePage(home)
			task.defer(setupGeneralInfo)
		elseif param1 == "newmsglog" and param2 then
			task.defer(function()
				createLog("msg",param2)
			end)
		elseif param1 == "newcmdlog" and param2 then
			task.defer(function()
				createLog("cmd",param2)
			end)
		elseif param1 == "updatepaneltheme" and param2 then
			panelTheme.Image = param2
			
		elseif param1 == "createhelpreq" and param2 then
			if param2:IsA("Player") then 
				task.defer(function()
					createHelpRequest(param2)
				end)
			end
		elseif param1 == "removehelpreq" and param2 then
			if param2:IsA("Player") then
				local dHelpReq = HelpRequestsList:FindFirstChild(tostring(param2.UserId))
				if dHelpReq then dHelpReq:Destroy() end
			end
		end
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	task.defer(updateClientTime)
end)

UIS.InputBegan:Connect(function(inp,gip)
	if gip then return end
	
	local prefixChanged = false
	if prefixChanging then
		prefixChanging = false
		local n_prefix = inp.KeyCode.Name
		
		local inpKeyVal = validKeyCodes[n_prefix]
		if inpKeyVal ~= nil then
			inpKeyVal = string.sub(string.upper(tostring(inpKeyVal)),1,1)
			csc_event:FireServer("changeprefix",inpKeyVal)
			PrefixButton.Text = inpKeyVal
			PrefixMsg.Visible = false
			prefixChanged = true
		end
		
		if not prefixChanged then prefixChanging = true end
		
	end
	
end)

task.defer(setupGeneralInfo)

---------------------
-- Draggable UI Stuff

local dragToggle = nil
local dragSpeed = 0.25
local dragStart = nil
local startPos = nil

function updateDragInput(input)
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
			updateDragInput(input)
		end
	end
end)


