-- services
local UIS = game:GetService('UserInputService')

-- core
local events = game.ReplicatedStorage:WaitForChild("SRX_Events")
local csc_event = events:WaitForChild("CSC_Event")
local csc_func = events:WaitForChild("CSC_Func")

-- variables

local main = script.Parent:WaitForChild("Main")
local mainUI = main:WaitForChild("MainUI")
local closeBttn = mainUI:WaitForChild("Close")
local submitBttn = mainUI:WaitForChild("Submit")
local bg = main:WaitForChild("BackgroundImage")

local evidenceFrame = mainUI:WaitForChild("Evidence")
local reasonFrame = mainUI:WaitForChild("Reason")
local notesFrame = mainUI:WaitForChild("Notes")
local userFrame = mainUI:WaitForChild("Target")


local evidenceInput = evidenceFrame:WaitForChild("Input")
local userInput = userFrame:WaitForChild("Input")
local notesInput = notesFrame:WaitForChild("Input")
local reasonInput = reasonFrame:WaitForChild("Input")

local userList = userFrame:WaitForChild("UserList")
local userListTemplate = userList:WaitForChild("TEMPLATE")

local ticketCooldown = csc_func:InvokeServer("GETHELPTICKETCD")

-- miscellaneous functions

function setupPlayerList()
	local filterText = ""
	local isUserInputFocused = false
	
	local function filterUserList()
		for _,v in userList:GetChildren() do
			if string.lower(v.Name) ~= "template" and v:IsA("TextButton") then
				if filterText == "" then
					v.Visible = true
				else
					if string.match(string.lower(v.Name),string.lower(filterText)) ~= nil then
						v.Visible = true
					else
						v.Visible = false
					end
				end
			end
			
		end
	end
	
	
	for _,v in game.Players:GetChildren() do
		local newTemplate = userListTemplate:Clone()
		newTemplate.Name = v.Name
		newTemplate.Text = string.upper(v.Name)
		newTemplate.Parent = userList
		newTemplate.Visible = true
		
		newTemplate.Activated:Connect(function()
			userInput.Text = newTemplate.Text
		end)
		
	end
	
	game.Players.PlayerAdded:Connect(function(plr)
		local newTemplate = userListTemplate:Clone()
		newTemplate.Name = plr.Name
		newTemplate.Text = string.upper(plr.Name)
		newTemplate.Parent = userList
		
		if filterText ~= "" then
			if string.match(string.lower(plr.Name),string.lower(filterText)) ~= nil then
				newTemplate.Visible = true
			else
				newTemplate.Visible = false
			end
		else
			newTemplate.Visible = true
		end
		
		newTemplate.Activated:Connect(function()
			userInput.Text = newTemplate.Text
		end)
		
	end)
	
	game.Players.PlayerRemoving:Connect(function(plr)
		local obj = userList:FindFirstChild(plr.Name)
		if obj then obj:Destroy() end
	end)
	
	userInput.FocusLost:Connect(function()
		isUserInputFocused = false
		task.delay(1,function()
			if not isUserInputFocused then
				userList.Visible = false
			end
		end)
	end)
	
	userInput.Focused:Connect(function()
		userList.Visible = true
		isUserInputFocused = true
	end)
	
	userInput:GetPropertyChangedSignal("Text"):Connect(function()
		filterText = userInput.Text
		filterUserList()
	end)
	
	
end

function clearInputs()
	userInput.Text = ""
	reasonInput.Text = ""
	evidenceInput.Text = ""
	notesInput.Text = ""
end

-- main code

bg.Image = csc_func:InvokeServer("GETHELPTICKETBG")


submitBttn.Activated:Connect(function()
	csc_event:FireServer("SUBMITHELPTICKET",userInput.Text,reasonInput.Text,evidenceInput.Text,notesInput.Text)
end)

closeBttn.Activated:Connect(function()
	main.Parent.Enabled = false
	csc_event:FireServer("CLOSEHELPTICKET")
end)

task.defer(setupPlayerList)
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
