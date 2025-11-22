local sys = script.Parent:WaitForChild("SystemDefault"):WaitForChild("SRX_Admin_System")

sys.Parent = game.ServerScriptService

local cmds = script.Parent:WaitForChild("SRX_Commands")
local adminSettings = script.Parent:WaitForChild("SRXAdminSettings")
cmds.Parent = sys
adminSettings.Parent = sys


local customAssets = script.Parent:WaitForChild("SRX_CustomizableAssets")

if customAssets then
	
	if customAssets:FindFirstChild("Server") then
		for _,v in sys:WaitForChild("SRX_Assets"):GetChildren() do
			local customVersion = customAssets:WaitForChild("Server"):FindFirstChild(v.Name)

			if customVersion then
				v:Destroy()
				customVersion.Parent = sys:WaitForChild("SRX_Assets")
			end
		end
	end
	
	if customAssets:FindFirstChild("Client") then
		for _,v in sys:WaitForChild("SRX_Client"):WaitForChild("Assets"):GetChildren() do
			local customVersion = customAssets:WaitForChild("Client"):FindFirstChild(v.Name)

			if customVersion then
				v:Destroy()
				customVersion.Parent = sys:WaitForChild("SRX_Client"):WaitForChild("Assets")
			end
		end
	end
	
end

sys.Enabled = true


script:Destroy()
