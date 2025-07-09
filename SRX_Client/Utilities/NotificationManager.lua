local module = {}

module.GetClientTime = function(utcTime)
	local utc_curr = os.time()
	local client_curr = math.floor(tick())
	local diff = client_curr - utc_curr
	return utcTime + diff
end

-----------------------------------------



return module
