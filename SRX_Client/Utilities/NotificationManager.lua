local module = {}

module.GetClientTime = function(utcTime)
	local utc_curr = os.time()
	local client_curr = math.floor(tick())
	local diff = client_curr - utc_curr
	return utcTime + diff
end

-----------------------------------------
local TWS = game:GetService("TweenService")

-----------------------------------------

local assets = script.Parent.Parent:WaitForChild("Assets")
local events = game.ReplicatedStorage:WaitForChild("SRX_Events")
-----------------------------------------
local plr = game.Players.LocalPlayer
-----------------------------------------

local announcement_template = assets:WaitForChild("AnnouncementTemplate")
local warning_template = assets:WaitForChild("WarningTemplate")

-----------------------------------------

module.CreateAnnouncement = function(posterID:number,text:string)
	if text == nil or posterID == nil or tonumber(tostring(posterID)) == nil then return end
	local newAnnouncement = announcement_template:Clone()
	newAnnouncement.Name = "SRX_ANNOUNCEMENT"
	
	local msg = newAnnouncement:WaitForChild("Main"):WaitForChild("Message")
	msg.Text = text
	
	local pfp = newAnnouncement:WaitForChild("Main"):WaitForChild("UserInfo"):WaitForChild("PFP")
	local username = newAnnouncement:WaitForChild("Main"):WaitForChild("UserInfo"):WaitForChild("Name")
	
	local timeText = newAnnouncement:WaitForChild("Main"):WaitForChild("Time"):WaitForChild("LocalTime")
	
	local posterName = game.Players:GetNameFromUserIdAsync(posterID)
	username.Text = string.upper(posterName)
	pfp.Image = game.Players:GetUserThumbnailAsync(posterID,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
	
	local hour,minute,ampm = os.date("%I"),os.date("%M"),os.date("%p")

	timeText.Text = tostring(hour)..":"..tostring(minute).." "..tostring(ampm)
	
	local close = newAnnouncement:WaitForChild("Main"):WaitForChild("Close")
	newAnnouncement.Parent = plr.PlayerGui
	
	local tweenGoal = UDim2.new(0.5,0,0.5,0)
	local tweenGoal2 = UDim2.new(0.5,0,-1,0)
	local tweenInfo = TweenInfo.new(1)
	
	

	
	local tween = TWS:Create(newAnnouncement:WaitForChild("Main"),tweenInfo,{Position = tweenGoal})
	local tween2 = TWS:Create(newAnnouncement:WaitForChild("Main"),tweenInfo,{Position = tweenGoal2})
	
	tween:Play()
	tween.Completed:Connect(function()
		close.Active = true
		
		local closed = false
		close.Activated:Connect(function()
			if not closed then
				closed = true
				close.Active = false
				
				tween2:Play()
				tween2.Completed:Connect(function()
					newAnnouncement:Destroy()
				end)
				
			end
		end)
		
	end)
end


module.CreateWarning = function(posterID:number,text:string)
	if text == nil or posterID == nil or tonumber(tostring(posterID)) == nil then return end
	local newWarning = warning_template:Clone()
	newWarning.Name = "SRX_WARNING"

	local msg = newWarning:WaitForChild("Main"):WaitForChild("Message")
	msg.Text = text

	local pfp = newWarning:WaitForChild("Main"):WaitForChild("UserInfo"):WaitForChild("PFP")
	local username = newWarning:WaitForChild("Main"):WaitForChild("UserInfo"):WaitForChild("Name")

	local timeText = newWarning:WaitForChild("Main"):WaitForChild("Time"):WaitForChild("LocalTime")

	local posterName = game.Players:GetNameFromUserIdAsync(posterID)
	username.Text = string.upper(posterName)
	pfp.Image = game.Players:GetUserThumbnailAsync(posterID,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)

	local hour,minute,ampm = os.date("%I"),os.date("%M"),os.date("%p")

	timeText.Text = tostring(hour)..":"..tostring(minute).." "..tostring(ampm)

	local close = newWarning:WaitForChild("Main"):WaitForChild("Close")
	
	local outlineCLR = newWarning:WaitForChild("Main"):WaitForChild("OutlineCLR")
	local function flashBorder()
		if newWarning == nil or newWarning.Parent == nil then return end
		outlineCLR.Color = Color3.new(255,255,255)
		task.wait(1)
		outlineCLR.Color = Color3.new(255,0,0)
		task.delay(1,flashBorder)
	end
	
	newWarning.Parent = plr.PlayerGui
	
	task.defer(flashBorder)

	local tweenGoal = UDim2.new(0.5,0,0.5,0)
	local tweenGoal2 = UDim2.new(0.5,0,-1,0)
	local tweenInfo = TweenInfo.new(1)




	local tween = TWS:Create(newWarning:WaitForChild("Main"),tweenInfo,{Position = tweenGoal})
	local tween2 = TWS:Create(newWarning:WaitForChild("Main"),tweenInfo,{Position = tweenGoal2})

	tween:Play()
	tween.Completed:Connect(function()
		close.Active = true

		local closed = false
		close.Activated:Connect(function()
			if not closed then
				closed = true
				close.Active = false

				tween2:Play()
				tween2.Completed:Connect(function()
					newWarning:Destroy()
				end)

			end
		end)

	end)
end


return module
