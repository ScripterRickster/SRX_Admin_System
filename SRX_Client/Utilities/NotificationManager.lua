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
local notification_template = assets:WaitForChild("NotificationTemplate")

-----------------------------------------
local notifCount = 0
local lowestY = 0.923
local notifYSpacing = 0.15
local updatingNotifPositions = false
local notificationStorage = {
	--[[
	["N#"] = {
		Object = object; -- object reference
		YPos = y; -- y position of the notification ui
		ANum = 0; -- notification number
		ToDelete = false; -- should it be deleted
	}
	]]
}

function updateNotificationPositions()
	if updatingNotifPositions then return end
	updatingNotifPositions = true


	local activeNotifs = {}
	for _, v in pairs(notificationStorage) do
		if v ~= nil and v.Object ~= nil and not v.ToDelete then
			table.insert(activeNotifs, v)
		end
	end

	table.sort(activeNotifs, function(a,b)
		return a.ANum < b.ANum
	end)


	for i, notif in ipairs(activeNotifs) do
		local targetY = lowestY - ((i-1) * notifYSpacing)
		notif.YPos = targetY

		local vMain = notif.Object:WaitForChild("Main")
		local tweenGoal = UDim2.new(0.91,0,targetY,0)
		local tweenInfo = TweenInfo.new(0.5)
		TWS:Create(vMain, tweenInfo, {Position = tweenGoal}):Play()
	end

	for idx, v in pairs(notificationStorage) do
		if v.ToDelete and v.Object and v.Object:FindFirstChild("Main") then
			local vMain = v.Object.Main
			local tweenGoal = UDim2.new(2,0,v.YPos,0)
			local tweenInfo = TweenInfo.new(0.5)
			local tween = TWS:Create(vMain, tweenInfo, {Position = tweenGoal})
			tween:Play()
			tween.Completed:Once(function()
				if vMain.Parent then vMain.Parent:Destroy() end
				notificationStorage[idx] = nil
			end)
		end
	end

	updatingNotifPositions = false
end


function getCurrentNotificationCount()
	local c = 0
	for _,v in pairs(notificationStorage) do
		if v ~= nil then
			c += 1
		end
	end
	return c
end
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
		task.wait(0.5)
		outlineCLR.Color = Color3.new(255,0,0)
		task.delay(0.5,flashBorder)
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

module.CreateNotification = function(notifName:string,notifMessage:text,manualDelete:boolean)
	if notifName == nil or notifMessage == nil then return end
	
	notifCount += 1
	local newNotif = notification_template:Clone()
	newNotif:WaitForChild("Main"):WaitForChild("Title").Text = "<u>"..string.upper(tostring(notifName)).."</u>"
	newNotif:WaitForChild("Main"):WaitForChild("Message").Text = tostring(notifMessage)
	
	local cNotifCount = notifCount
	newNotif:SetAttribute("NOTIFNUM",cNotifCount)
	
	local close = newNotif:WaitForChild("Main"):WaitForChild("Close")
	
	local currY = 0.923 - (notifYSpacing * getCurrentNotificationCount())
	newNotif:WaitForChild("Main").Position = UDim2.new(2,0,currY,0)
	
	local tweenGoal = UDim2.new(0.91,0,currY,0)
	--local tweenGoal2 = UDim2.new(2,0,0.923,0)
	local tweenInfo = TweenInfo.new(1)
	
	local tween = TWS:Create(newNotif:WaitForChild("Main"),tweenInfo,{Position = tweenGoal})
	--local tween2 = TWS:Create(newNotif:WaitForChild("Main"),tweenInfo,{Position = tweenGoal2})
	
	notificationStorage["N"..tostring(cNotifCount)] = {
		Object = newNotif;
		YPos = currY;
		ANum = cNotifCount;
		ToDelete = false;
		
	}
	
	newNotif.Parent = plr.PlayerGui
	
	tween:Play()
	
	tween.Completed:Connect(function()
		local closed = false
		local function closeNotif()
			if closed then return end
			close.Active = false
			closed = true
			
			notificationStorage["N"..tostring(cNotifCount)]["ToDelete"] = true
			repeat task.wait() until not updatingNotifPositions
			updateNotificationPositions()
			
		end
		
		close.Activated:Connect(function()
			task.defer(closeNotif)
		end)
		
		if manualDelete ~= true then
			task.delay(20,closeNotif) -- change back to 10
		end
		
	end)
	
end


return module
