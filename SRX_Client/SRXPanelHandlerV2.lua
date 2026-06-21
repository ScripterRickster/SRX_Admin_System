
-- services
local UIS = game:GetService('UserInputService')
local RNS = game:GetService("RunService")

-- core
local events = game.ReplicatedStorage:WaitForChild("SRX_Events")
local csc_event = events:WaitForChild("CSC_Event")
local csc_func = events:WaitForChild("CSC_Func")
local panelcsc_event = events:WaitForChild("PanelCSC_Event")

local player = game.Players.LocalPlayer

local main = script.Parent:WaitForChild("Main")
local pgNameDisplay = main:WaitForChild("PageNameDisplay")

local lsbar = main:WaitForChild("LeftSidebar")
local rsbar = main:WaitForChild("RightSidebar")


local fpsDisplay = lsbar:WaitForChild("FPSDisplay")
local pingDisplay = lsbar:WaitForChild("PingDisplay")
local serverIDDisplay = lsbar:WaitForChild("ServerIDDisplay")
local userDisplay = lsbar:WaitForChild("UserDisplay")

local buttons = lsbar:WaitForChild("Buttons")
local buttonTemplate = buttons:WaitForChild("TEMPLATE")
local closeButton = buttons:WaitForChild("Close")


local timeDisplay = rsbar:WaitForChild("TimeDisplay")
local aiChat = rsbar:WaitForChild("SubHolder"):WaitForChild("AI Chat")
local helpReqs = rsbar:WaitForChild("SubHolder"):WaitForChild("HelpRequests")
local HelpRequestsList = helpReqs:WaitForChild("Requests")

local mainselection = main:WaitForChild("MainSelection")

local closeBttn = lsbar:WaitForChild("Buttons"):WaitForChild("Close"):WaitForChild("Button")

local panelTheme = main:WaitForChild("UserTheme")


local psetup = false
local prefixChanging = false



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


function setupPanel()
	if psetup then return end
	psetup = true


	local defaultPage = mainselection:WaitForChild("Home")
	local currPage = defaultPage

	local rID,rName,rClr = csc_func:InvokeServer("GETRANKINFO")
	rID,rName = tostring(rID),tostring(rName)
	local adminV = csc_func:InvokeServer("GETADMINVERSION")
	local sID = csc_func:InvokeServer("GETSERVERID")
	serverIDDisplay:WaitForChild("ID").Text = tostring(sID)
	local canUseAI = csc_func:InvokeServer("CANUSEAI")
	local canViewHelpReq = csc_func:InvokeServer("CANVIEWHELPREQ")
	local currUserTheme,currThemeTransparency = csc_func:InvokeServer("GETPLAYERTHEME")
	local currUserPrefix = csc_func:InvokeServer("GETPLAYERPREFIX")
	--print(currUserPrefix)
	local allHelpRequests = csc_func:InvokeServer("GETALLHELPREQUESTS")
	local canUseCommandConsole = csc_func:InvokeServer("CANUSECOMMANDCONSOLE")

	local onCMDCooldown = false

	local cmdCooldown = tonumber(csc_func:InvokeServer("GETCMDCOOLDOWN"))
	if cmdCooldown == nil then cmdCooldown = math.huge warn("SRX | Failed to get command cooldown") end

	local commandActivateButtons = {
		mainselection:WaitForChild("CMDPanel"):WaitForChild("Activate"),
		mainselection:WaitForChild("Commands"):WaitForChild("CommandConsole"):WaitForChild("Activate")
	}

	local function commandCooldown()
		onCMDCooldown = true

		for _,v in pairs(commandActivateButtons) do
			if v:IsA("TextButton") then
				v.Active = false
				v.TextTransparency = 0.5
				local uistroke = v:FindFirstChildOfClass("UIStroke")
				if uistroke then
					uistroke.Transparency = 0.5
				end
			end
		end


		task.wait(cmdCooldown)

		for _,v in pairs(commandActivateButtons) do
			if v:IsA("TextButton") then
				v.Active = true
				v.TextTransparency = 0
				local uistroke = v:FindFirstChildOfClass("UIStroke")
				if uistroke then
					uistroke.Transparency = 0
				end
			end
		end

		onCMDCooldown = false

	end

	local function clearInputs(dPage:Frame)
		for _,v in pairs(dPage:GetDescendants()) do
			if v:IsA("TextBox") then v.Text = "" end
		end
	end

	local function changeVisibleStatus(dPage:Frame,CName,DName:string,Status:boolean,CaseSensitive:boolean)
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


	local function changePage(dPage:Frame,triggerFunction,tfp1,tfp2,tfp3,tfp4,tfp5)
		if dPage then
			for _,v in mainselection:GetChildren() do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end
			dPage.Visible = true
			currPage = dPage

			pgNameDisplay.Text = string.upper(currPage.Name)


			if triggerFunction then
				pcall(function()
					task.spawn(triggerFunction,tfp1,tfp2,tfp3,tfp4,tfp5)
				end)
			end
		end

	end

	local cmdpanelloadcounter=0
	local function loadCMDPanel(cmd,cmdParams)
		if cmd and cmdParams then
			cmdpanelloadcounter+=1
			local cmdParameterList = mainselection:WaitForChild("CMDPanel"):WaitForChild("Parameters"):WaitForChild("List")
			local cmdParameterTemplate = cmdParameterList:WaitForChild("Template")
			local cmdNoParametersMsg = mainselection:WaitForChild("CMDPanel"):WaitForChild("NoParametersMsg")
			local currCMDNameText = mainselection:WaitForChild("CMDPanel"):WaitForChild("Titles"):WaitForChild("CMDName")
			local cmdActivateBttn = mainselection:WaitForChild("CMDPanel"):WaitForChild("Activate")
			cmdNoParametersMsg.Visible = false
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

			if idx == 1 then
				cmdNoParametersMsg.Visible = true
			end

			if cmdpanelloadcounter <= 1 then
				cmdActivateBttn.Activated:Connect(function()
					if currPage == mainselection:WaitForChild("CMDPanel") and not onCMDCooldown then
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
							task.spawn(changeVisibleStatus,mainselection:WaitForChild("CMDPanel"),"TextLabel","WarnMessage",false,false)
							task.spawn(clearInputs,mainselection:WaitForChild("CMDPanel"))
							task.defer(commandCooldown)
						end

						--onCMDCooldown = false

					end
				end)
			end



		end
	end


	local CustomFrameFunctions = {
		["home"] = {
			Update = function()

			end,
			Setup = function()
				if mainselection:FindFirstChild("Home") then
					local homeFrame = mainselection:WaitForChild("Home")
					local qact = homeFrame:WaitForChild("QuickActions")
					local updatelog = homeFrame:WaitForChild("UpdateLog")
					local servstats = homeFrame:WaitForChild("ServerStats")

					local serverUptime = csc_func:InvokeServer("GETSERVERUPTIME")

					local function formatTime(totalSeconds)
						local days = math.floor(totalSeconds / 86400)
						local hours = math.floor((totalSeconds % 86400) / 3600)
						local minutes = math.floor((totalSeconds % 3600) / 60)
						local seconds = totalSeconds % 60

						return days,hours,minutes,seconds
					end

					local function manageServerTimeDisplay()
						serverUptime += 1
						local d,h,m,s = formatTime(serverUptime)

						servstats:WaitForChild("SubFrame"):WaitForChild("Server"):WaitForChild("DayValue").Text = tostring(d).." Day(s)"
						servstats:WaitForChild("SubFrame"):WaitForChild("Server"):WaitForChild("HourValue").Text = tostring(h).." Hour(s)"
						servstats:WaitForChild("SubFrame"):WaitForChild("Server"):WaitForChild("MinuteValue").Text = tostring(m).." Minute(s)"
						servstats:WaitForChild("SubFrame"):WaitForChild("Server"):WaitForChild("SecondValue").Text = tostring(s).." Second(s)"
						task.delay(1,manageServerTimeDisplay)
					end

					task.spawn(manageServerTimeDisplay)

					local qActCmds = csc_func:InvokeServer("GETMOSTUSEDCMDS",5)

					if qActCmds == nil or #qActCmds <= 0 then 
						qact.Visible = false 
					else
						local tempBttn = qact:WaitForChild("SubFrame"):WaitForChild("TEMPLATE")

						for _,v in qActCmds do
							local newCMD = tempBttn:Clone()
							newCMD.Name = v["Command"]
							newCMD.Text = v["Command"]
							newCMD.Parent = tempBttn.Parent
							newCMD.Visible = true
							
							local cmdDesc,cmdParams = csc_func:InvokeServer("GETCMDINFO",v["Command"])

							newCMD.Activated:Connect(function()
								changePage(mainselection:WaitForChild("CMDPanel"),loadCMDPanel,v["Command"],cmdParams)
							end)

						end
					end




					local updTxt = csc_func:InvokeServer("GETUPDATELOG")
					if updTxt then
						updatelog:WaitForChild("SubFrame"):WaitForChild("Description").Text = tostring(updTxt)
					else
						updatelog.Visible = false
					end

					local isStaff,currPlrs = 0,#game.Players:GetChildren()

					for _,v in pairs(game.Players:GetChildren()) do
						if v:GetAttribute("SRX_IS_STAFF") then
							isStaff+=1
						end

						v:GetAttributeChangedSignal("SRX_IS_STAFF"):Connect(function()
							if v:GetAttribute("SRX_IS_STAFF") then
								isStaff += 1
							else
								isStaff = math.max(0,isStaff-1)
							end
							servstats:WaitForChild("SubFrame"):WaitForChild("Staff"):WaitForChild("Value").Text = tostring(isStaff)
						end)
					end

					servstats:WaitForChild("SubFrame"):WaitForChild("Staff"):WaitForChild("Value").Text = tostring(isStaff)
					servstats:WaitForChild("SubFrame"):WaitForChild("Players"):WaitForChild("Value").Text = tostring(currPlrs)

					game.Players.PlayerAdded:Connect(function(plr)
						currPlrs += 1
						servstats:WaitForChild("SubFrame"):WaitForChild("Players"):WaitForChild("Value").Text = tostring(currPlrs)
						plr:GetAttributeChangedSignal("SRX_IS_STAFF"):Connect(function()
							if plr:GetAttribute("SRX_IS_STAFF") then
								isStaff += 1
							else
								isStaff = math.max(0,isStaff-1)
							end
							servstats:WaitForChild("SubFrame"):WaitForChild("Staff"):WaitForChild("Value").Text = tostring(isStaff)
						end)
					end)

					game.Players.PlayerRemoving:Connect(function(plr)
						currPlrs = math.max(0,currPlrs-1)
						servstats:WaitForChild("SubFrame"):WaitForChild("Players"):WaitForChild("Value").Text = tostring(currPlrs)
						if plr:GetAttribute("SRX_IS_STAFF") then
							isStaff = math.max(0,isStaff-1)
							servstats:WaitForChild("SubFrame"):WaitForChild("Staff"):WaitForChild("Value").Text = tostring(isStaff)
						end
					end)
				end
			end,

			ExtraFunctions = {
				["qactupdate"] = function()
					local homeFrame = mainselection:WaitForChild("Home")
					local qact = homeFrame:WaitForChild("QuickActions")
					local qActCmds = csc_func:InvokeServer("GETMOSTUSEDCMDS",5)
					local tempBttn = qact:WaitForChild("SubFrame"):WaitForChild("TEMPLATE")

					for _,v in qact:WaitForChild("SubFrame"):GetChildren() do
						if v:IsA("TextButton") and string.lower(v.Name) ~= "template" then
							v:Destroy()
						end
					end

					if qActCmds == nil or #qActCmds <= 0 then qact.Visible = false return end



					for _,v in qActCmds do
						local newCMD = tempBttn:Clone()
						newCMD.Name = v["Command"]
						newCMD.Text = v["Command"]
						newCMD.Parent = tempBttn.Parent
						newCMD.Visible = true

						newCMD.Activated:Connect(function()
							local cmdDesc,cmdParams = csc_func:InvokeServer("GETCMDINFO",v["Command"])
							changePage(mainselection:WaitForChild("CMDPanel"),loadCMDPanel,v["Command"],cmdParams)
						end)

					end
				end,
			}
		};

		["commands"] = {
			Update = function(CFF)

				if currPage == mainselection:WaitForChild("CMDPanel") then
					task.spawn(changePage,mainselection:WaitForChild("Commands"))
				end
				if CFF then
					task.spawn(CFF["commands"]["Setup"],true)
				end


			end,

			Setup = function(reload:boolean)
				local canUseCommandConsole = csc_func:InvokeServer("CANUSECOMMANDCONSOLE")

				local cmdList = mainselection:WaitForChild("Commands"):WaitForChild("MainCMDS"):WaitForChild("CMDFrame"):WaitForChild("CMDList")
				local ccCMDDropdownList = mainselection:WaitForChild("Commands"):WaitForChild("CommandConsole"):WaitForChild("CMDNameDropdown"):WaitForChild("List")

				local cmdLoadingMsg = mainselection:WaitForChild("Commands"):WaitForChild("MainCMDS"):WaitForChild("CMDFrame"):WaitForChild("LoadingCMDSMessage")

				local cmdSearch = mainselection:WaitForChild("Commands"):WaitForChild("MainCMDS"):WaitForChild("CMDSearch"):WaitForChild("SearchBox")
				local ccCommandInput = mainselection:WaitForChild("Commands"):WaitForChild("CommandConsole"):WaitForChild("InputAreas"):WaitForChild("CommandName")
				local ccParameterHint = mainselection:WaitForChild("Commands"):WaitForChild("CommandConsole"):WaitForChild("ParameterHint")
				local ccCMDNameDropdown = mainselection:WaitForChild('Commands'):WaitForChild('CommandConsole'):WaitForChild("CMDNameDropdown")

				local cmdTemplate = cmdList:WaitForChild("Template")
				local ccCMDTemplate = ccCMDDropdownList:WaitForChild("Template")

				for _,v in pairs(cmdList:GetChildren()) do
					if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
						v:Destroy()
					end
				end

				for _,v in pairs(ccCMDDropdownList:GetChildren()) do
					if v:IsA("TextButton") and string.lower(v.Name) ~= "template" then
						v:Destroy()
					end
				end

				if not canUseCommandConsole then
					mainselection:WaitForChild("Commands"):WaitForChild("CommandConsole").Visible = false
					mainselection:WaitForChild("Commands"):WaitForChild("Divider").Visible = false
				end

				cmdLoadingMsg.Visible = true

				local newCMDS = csc_func:InvokeServer("GETPLAYERCMDS")

				cmdLoadingMsg.Visible = false

				for _,v in pairs(newCMDS) do
					-- regular command
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
						task.spawn(changePage,mainselection:WaitForChild("CMDPanel"),loadCMDPanel,tostring(v),cmdParams)
					end)

					-- command console command
					if canUseCommandConsole then
						local new_ccCMDTemplate = ccCMDTemplate:Clone()
						new_ccCMDTemplate.Name = string.upper(tostring(v))
						new_ccCMDTemplate.Text = string.upper(tostring(v))
						new_ccCMDTemplate.Visible = true
						new_ccCMDTemplate.Parent = ccCMDDropdownList

						new_ccCMDTemplate.Activated:Connect(function()
							ccCommandInput.Text = string.upper(tostring(v))
							ccCMDNameDropdown.Visible = false
						end)
					end
				end

				if not reload then
					local function filterCMDS(txt:string)
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

					local function filterConsoleCMDList(txt:string)
						if txt == nil then return end
						txt = string.lower(tostring(txt))
						for _,v in pairs(ccCMDDropdownList:GetChildren()) do
							if string.lower(v.Name) ~= "template" and v:IsA("TextButton") then
								if txt == "" then
									v.Visible = true
								else
									local userTxt = string.lower(v.Name)
									if string.match(userTxt,txt) ~= nil then
										v.Visible = true
									else
										v.Visible = false
									end
								end
							end
						end
					end

					local function loadCommandConsoleParameterHint()
						if ccCommandInput.Text == " " or ccCommandInput.Text == nil or ccCommandInput.Text == "" then
							ccParameterHint.Visible = false
						else
							local cmdDesc,cmdParams = csc_func:InvokeServer("GETCMDINFO",ccCommandInput.Text)
							if cmdDesc == nil and cmdParams == nil then
								ccParameterHint.TextColor3 = Color3.fromRGB(255, 0, 0)
								ccParameterHint.Text = "ERROR | COMMAND DOES NOT EXIST"
							elseif cmdParams ~= nil then
								ccParameterHint.TextColor3 = Color3.fromRGB(255,255,255)
								ccParameterHint.Text = "PARAMETERS: "
								for paramName,paramVal in pairs(cmdParams) do
									ccParameterHint.Text = ccParameterHint.Text.." ["..string.upper(tostring(paramName)).."]"
								end
							end
							ccParameterHint.Visible = true
						end
					end

					local ccInputChanged = false


					cmdSearch:GetPropertyChangedSignal("Text"):Connect(function()
						filterCMDS(cmdSearch.Text)
					end)

					ccCommandInput.Focused:Connect(function()
						ccCMDNameDropdown.Visible = true
					end)

					ccCommandInput.FocusLost:Connect(function()
						task.delay(1,function()
							if not ccInputChanged then ccCMDNameDropdown.Visible = false end
							loadCommandConsoleParameterHint()
						end)
					end)

					ccCommandInput:GetPropertyChangedSignal("Text"):Connect(function()
						ccInputChanged = true
						filterConsoleCMDList(ccCommandInput.Text)
						ccInputChanged = false
					end)


				end




			end,
		};

		["logs"] = {
			Update = function()

			end,

			Setup = function(addLog,lInfo,lType)
				local logs = mainselection:WaitForChild("Logs")
				local chatlogSearch = logs:WaitForChild("SearchAreas"):WaitForChild("ChatLogSearchBox")
				local cmdlogSearch = logs:WaitForChild("SearchAreas"):WaitForChild("CMDLogSearchBox")

				local chatLogsList = logs:WaitForChild("LogFrame"):WaitForChild("ChatLogList")
				local commandLogsList = logs:WaitForChild("LogFrame"):WaitForChild("CMDLogList")

				local cmdlogTemplate = commandLogsList:WaitForChild("Template")
				local chatlogTemplate = chatLogsList:WaitForChild("Template")


				local function createLog(logType:string,logInfo:table)
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

				if addLog and lInfo and lType then
					task.spawn(createLog,lInfo,lType)
					return
				end


				local function filterLogs(txt:string,listFrame:ScrollingFrame)
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

				chatlogSearch:GetPropertyChangedSignal("Text"):Connect(function()
					filterLogs(chatlogSearch.Text,chatLogsList)
				end)

				cmdlogSearch:GetPropertyChangedSignal("Text"):Connect(function()
					filterLogs(cmdlogSearch.Text,commandLogsList)
				end)

			end,
		};

		["userlookup"] = {
			Update = function()
				local cmi = csc_func:InvokeServer("CANMANAGEINFRACTIONS")
				local ulFrame = mainselection:WaitForChild("UserLookup")
				local infractionList = ulFrame:WaitForChild("Infractions"):WaitForChild("InfractionList")

				for _,v in infractionList:GetChildren() do
					if v:IsA("Frame") and string.lower(v.Name) ~= "template" then
						if v:FindFirstChild("Delete",true) then
							v:FindFirstChild("Delete",true).Visible = cmi
						end
					end
				end
			end,

			Setup = function()
				local cmi = csc_func:InvokeServer("CANMANAGEINFRACTIONS")
				local ulFrame = mainselection:WaitForChild("UserLookup")
				local userLookupMainFrame = ulFrame:WaitForChild("UFrame")
				local userLookupGeneralMessage = ulFrame:WaitForChild("LoadingUserMsg")
				local infractionList = ulFrame:WaitForChild("Infractions"):WaitForChild("InfractionList")
				local infractionTemplate = infractionList:WaitForChild("Template")
				local infracMsgTL = ulFrame:WaitForChild("LoadingInfracMsg")

				local userLookupSearchBox = ulFrame:WaitForChild("Search"):WaitForChild("SearchBox")




				local function loadUserInfractions(targUID)
					for _,v in pairs(infractionList:GetChildren()) do
						if string.lower(v.Name) ~= "template" and v:IsA("Frame") then v:Destroy() end
					end
					if targUID then
						infracMsgTL.Text = "LOADING INFRACTIONS...."
						infracMsgTL.Visible = true
						local uInfracs = csc_func:InvokeServer("GETPLAYERINFRACTIONS",targUID)
						if uInfracs ~= nil then
							local function hasInfractions()
								for a1,b1 in pairs(uInfracs) do
									if b1 ~= nil then return true end
								end
								return false
							end
							if hasInfractions() == false then
								infracMsgTL.Text = "USER HAS NO INFRACTIONS"
							else
								infracMsgTL.Visible = false
							end
							for infracID,infracInfo in pairs(uInfracs) do

								local staffMemID = tonumber(tostring(infracInfo["StaffMemberID"]))
								local newInfractionTemplate = infractionTemplate:Clone()
								newInfractionTemplate.Name = tostring(infracID)

								local infracReason = tostring(infracInfo["Reason"])
								local staffMem = "UNKNOWN"
								if staffMemID ~= nil then
									staffMem = game.Players:GetNameFromUserIdAsync(staffMemID)
								end
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

								if canDelete and cmi then
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

							infractionList.Parent.Visible = true
						else
							infracMsgTL.Text = "COULD NOT GET INFRACTIONS"
						end
					else
						infracMsgTL.Visible  = false
					end
				end

				local function loadUserInformation(inquiredUser:string)
					userLookupMainFrame.Visible = false
					if inquiredUser == "" or inquiredUser == nil then
						userLookupGeneralMessage.Text = "COULD NOT FIND USER"
						userLookupGeneralMessage.Visible = true
					else
						userLookupGeneralMessage.Text = "LOADING USER INFORMATION...."
						userLookupGeneralMessage.Visible = true
						local info = csc_func:InvokeServer("GETPLAYERINFO",inquiredUser)

						if info == nil then
							userLookupGeneralMessage.Text = "COULD NOT FIND USER"
							ulFrame:WaitForChild("Infractions").Visible = false
						else
							if info["UserID"] ~= nil then
								userLookupGeneralMessage.Visible = false
								local accAge = info["AccountAge"]
								if accAge == nil or accAge == "" then accAge = "COULD NOT RETRIEVE" end
								task.spawn(loadUserInfractions,info["UserID"])
								userLookupMainFrame:WaitForChild("PFP").Image = game.Players:GetUserThumbnailAsync(tonumber(info["UserID"]),Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
								userLookupMainFrame:WaitForChild("UID").Text = "USER ID: "..tostring(info["UserID"])
								userLookupMainFrame:WaitForChild("UserName").Text = "USERNAME: "..tostring(info["Username"])
								userLookupMainFrame:WaitForChild("DisplayName").Text = "DISPLAY NAME: "..tostring(info["DisplayName"])
								userLookupMainFrame:WaitForChild("BanStatus").Text = "IS BANNED: "..tostring(info["IsBanned"])
								userLookupMainFrame:WaitForChild("JoinCount").Text = "JOIN COUNT: "..tostring(info["JoinCount"]).." Joins"
								userLookupMainFrame:WaitForChild("AccountAge").Text = "ACCOUNT AGE: "..tostring(accAge)

								userLookupMainFrame.Visible = true
							else
								userLookupGeneralMessage.Text = "COULD NOT FIND USER"
							end


						end
					end
				end

				userLookupSearchBox.FocusLost:Connect(function()
					loadUserInformation(userLookupSearchBox.Text)
				end)

				userLookupSearchBox.Focused:Connect(function()
					userLookupGeneralMessage.Visible = false
				end)

			end,
		};

		["settings"] = {
			Update = function()
				local allThemes = csc_func:InvokeServer("GETALLTHEMES")
				local ThemeList = mainselection:WaitForChild('Settings'):WaitForChild("MainFrame"):WaitForChild("SettingsList"):WaitForChild("Theme"):WaitForChild("ThemesList")

				local ThemeTemplate = ThemeList:WaitForChild("TEMPLATE")
				for _,v in pairs(ThemeList:GetChildren()) do
					if v:IsA("ImageButton") and string.lower(v.Name) ~= "template" then
						v:Destroy() 
					end
				end

				if allThemes ~= nil and typeof(allThemes) == 'table' then
					for tN,tID in pairs(allThemes) do
						local nThemeBttn = ThemeTemplate:Clone()
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
			end,

			Setup = function()
				local PrefixButton = mainselection:WaitForChild("Settings"):WaitForChild("MainFrame"):WaitForChild("SettingsList"):WaitForChild("Prefix"):WaitForChild("PrefixButton")
				local ThemeChangebutton = mainselection:WaitForChild("Settings"):WaitForChild("MainFrame"):WaitForChild("SettingsList"):WaitForChild("Theme"):WaitForChild("ThemeButton")

				local ThemeList = mainselection:WaitForChild('Settings'):WaitForChild("MainFrame"):WaitForChild("SettingsList"):WaitForChild("Theme"):WaitForChild("ThemesList")
				local PrefixMsg = mainselection:WaitForChild("Settings"):WaitForChild("MainFrame"):WaitForChild("SettingsList"):WaitForChild("Prefix"):WaitForChild("Message")

				local ThemeTemplate = ThemeList:WaitForChild("TEMPLATE")

				local currUserTheme,currThemeTransparency = csc_func:InvokeServer("GETPLAYERTHEME")
				local currUserPrefix = csc_func:InvokeServer("GETPLAYERPREFIX")

				local allThemes = csc_func:InvokeServer("GETALLTHEMES")

				for _,v in pairs(ThemeList:GetChildren()) do
					if v:IsA("ImageButton") and string.lower(v.Name) ~= "template" then
						v:Destroy() 
					end
				end

				if allThemes ~= nil and typeof(allThemes) == 'table' then
					for tN,tID in pairs(allThemes) do
						local nThemeBttn = ThemeTemplate:Clone()
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


				PrefixButton.Activated:Connect(function()
					if prefixChanging then return end
					prefixChanging = true
					PrefixMsg.Visible = true
				end)

				ThemeChangebutton.Activated:Connect(function()
					ThemeList.Visible = not ThemeList.Visible
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
			end,
		}
	};







	local function setupButtons()
		for _,v in mainselection:GetChildren() do
			if v:IsA("Frame") and not v:GetAttribute("Ignore") then


				local function createButton()
					pcall(function()
						if CustomFrameFunctions[string.lower(v.Name)] ~= nil then
							task.spawn(CustomFrameFunctions[string.lower(v.Name)]["Setup"])
						end
					end)

					local b = buttonTemplate:Clone()
					b.Name = v.Name
					b:WaitForChild("OptionName").Text = v:GetAttribute("ButtonDisplayName")
					b:WaitForChild("ImageLabel").Image = v:GetAttribute("Icon")
					b:WaitForChild("ImageLabel").ImageColor3 = v:GetAttribute("IconColour")
					b:WaitForChild("OptionName").TextColor3 = v:GetAttribute("IconTextColour")

					b.LayoutOrder = v.LayoutOrder
					b.Visible = true
					b.Parent = buttons

					b:WaitForChild("Button").Activated:Connect(function()
						changePage(v)
					end)
				end

				if v:GetAttribute("MinRank") then
					if rID >= v:GetAttribute("MinRank") then
						task.spawn(createButton)
					end
				else
					task.spawn(createButton)
				end


			end
		end
	end

	task.spawn(setupButtons)


	local function setupProfile()
		rID,rName,rClr = csc_func:InvokeServer("GETRANKINFO")
		rID,rName = tostring(rID),tostring(rName)

		userDisplay:WaitForChild("Info"):WaitForChild("Username").Text = string.upper(player.Name)
		userDisplay:WaitForChild("Info"):WaitForChild("DisplayName").Text = "@"..string.upper(player.DisplayName)
		userDisplay:WaitForChild("Info"):WaitForChild("Rank").Text = string.upper(rName)

		userDisplay:WaitForChild("PFPHolder"):WaitForChild("PFP").Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

		if rClr then
			userDisplay:WaitForChild("Info"):WaitForChild("Rank").TextColor3 = rClr
		else
			userDisplay:WaitForChild("Info"):WaitForChild("Rank").TextColor3 = Color3.fromRGB(255,255,255)
		end
	end

	task.spawn(setupProfile)

	local function setupAIChat()
		if not canUseAI then aiChat.Visible = false end
		local AIDebounce,AIMsgCount = false,0
		local AI_SearchBox = aiChat:WaitForChild("Input")
		local AICommList = aiChat:WaitForChild("Messages")
		local AI_UTemplate = AICommList:WaitForChild("UserTemplate")
		local AI_AITemplate = AICommList:WaitForChild("AITemplate")

		local function newAIPrompt(prmpt:string)
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

		AI_SearchBox.FocusLost:Connect(function()
			task.spawn(newAIPrompt,AI_SearchBox.Text)
		end)
	end

	task.spawn(setupAIChat)

	local function setupHelpRequests(newHRQ:boolean,newHRQPlr:Player)
		if not canViewHelpReq then helpReqs.Visible = false end

		local HelpRequestTemplate = HelpRequestsList:WaitForChild("Template")
		local function createHelpRequest(plr:Player)

			if plr and canViewHelpReq then
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

				newHelpReqTemplate:WaitForChild("Time").Text = helpReqTime

				newHelpReqTemplate.Parent = HelpRequestsList
				newHelpReqTemplate.Visible = true
				newHelpReqTemplate:WaitForChild("TeleportButton").Activated:Connect(function()
					csc_event:FireServer("HANDLEHELPREQ",plr)
				end)

			end
		end

		if newHRQ and newHRQPlr and newHRQPlr:IsA("Player") then
			task.spawn(createHelpRequest,newHRQPlr)
			return
		end

		local function filterHelpRequests(txt:string)
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

		local HelpRequestSearch = helpReqs:WaitForChild("Search")

		HelpRequestSearch:GetPropertyChangedSignal("Text"):Connect(function()
			filterHelpRequests(HelpRequestSearch.Text)
		end)


	end

	task.spawn(setupHelpRequests)





	local function manageTime()
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

		timeDisplay:WaitForChild("Time").Text = tostring(cHour)..":"..tostring(cMin).." "..AM_PM

	end




	panelcsc_event.OnClientEvent:Connect(function(act,p1,p2,p3,p4,p5)
		act = string.lower(tostring(act))
		print(act,p1,p2,p3,p4,p5)
		if act == "updatepanel" or "updatepaneltheme" then
			if act == "updatepaneltheme" then
				panelTheme.Image = p1

				p1 = tonumber(tostring(p1))
				if p2 ~= nil then
					p2 = math.min(math.max(p2,0),1)
					panelTheme.ImageTransparency = p2
				end
				return
			end
			task.spawn(setupProfile)

			canUseAI = csc_func:InvokeServer("CANUSEAI")
			canViewHelpReq = csc_func:InvokeServer("CANVIEWHELPREQ")

			if not canUseAI then aiChat.Visible = false else aiChat.Visible = true end


			for _,v in CustomFrameFunctions do
				if v["Update"] then
					task.spawn(v["Update"],CustomFrameFunctions)
				end
			end
			return
		end


		if act == "createhelpreq" and p1 then
			if p1:IsA("Player") then 
				task.spawn(setupHelpRequests,true,p1)
			end
			return
		end

		if act == "removehelpreq" and p1 then
			if p1:IsA("Player") then
				local dHelpReq = HelpRequestsList:FindFirstChild(tostring(p1.UserId))
				if dHelpReq then dHelpReq:Destroy() end
			end
			return
		end

		if act == "newmsglog" and p1 then
			if CustomFrameFunctions["logs"] and CustomFrameFunctions["logs"]["Setup"] then
				task.spawn(CustomFrameFunctions["logs"]["Setup"],true,"msg",p1)
			end
			return

		end

		if act == "newcmdlog" and p1 then
			if CustomFrameFunctions["logs"] and CustomFrameFunctions["logs"]["Setup"] then
				task.spawn(CustomFrameFunctions["logs"]["Setup"],true,"cmd",p1)
			end
			return
		end


		if p1 and typeof(act) == 'string' and typeof(p1) == 'string' and CustomFrameFunctions[string.lower(p1)] and CustomFrameFunctions[string.lower(p1)]["ExtraFunctions"] and CustomFrameFunctions[string.lower(p1)]["ExtraFunctions"][act] then
			task.spawn(CustomFrameFunctions[string.lower(p1)]["ExtraFunctions"][act])
			return
		end

	end)



	RNS.Heartbeat:Connect(function()
		task.defer(manageTime)
		pingDisplay:WaitForChild("Value").Text = string.format("%.3f",player:GetNetworkPing() * 1000)
		fpsDisplay:WaitForChild("Value").Text = tostring(math.round(1/game.Stats.FrameTime))
	end)

	closeBttn.Activated:Connect(function()
		csc_event:FireServer("closeadminpanel")
	end)



	---------------------
	-- Draggable UI Stuff

	local dragToggle = nil
	local dragSpeed = 0.25
	local dragStart = nil
	local startPos = nil

	local function updateDragInput(input)
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






end

task.defer(setupPanel)

