local module = {}

module.Prefix = "!"

module.Ranks = { -- ranks for the admin system to use
	
	--[[
	
	[rank_name] = { -- rank name
		RankId = 0; -- rank id
		RankColour = Color3.fromRGB(255,255,255); -- rank colour (optional parameter) | not including this means the user will not have a chat tag and an overhead tag if enabled
	}
	
	]]
	
	["Owner"] = { 
		RankId = 5;
		RankColour = Color3.fromRGB(0, 120, 180);
		
	};
	["Head Administrator"] = { 
		RankId = 4;
		RankColour = Color3.fromRGB(85, 255, 0);

	};
	["Developer"] = { 
		RankId = 3;
		RankColour = Color3.fromRGB(255, 170, 0);

	};
	["Administrator"] = { 
		RankId = 2;
		RankColour = Color3.fromRGB(255, 0, 0);

	};
	["Moderator"] = { 
		RankId = 1;
		RankColour = Color3.fromRGB(255, 255, 0);

	};
	["Regular"] = { 
		RankId = 0;

	};
	
}

module.RankBinds = {
	Users = {
		--{user_id OR username, rank id}
		{"Scripter_Rickster",0};
		{3422141408,0};
	};
	Groups = {
		--[group_id]  = {min_rank, rank id}
		
		[0] = {
			Min_Group_Rank = 0;
			RankId = 0;
		}
	};
	Gamepasses = {
		--[gamepass id] = rank id
		[0] = 0;
	};
	OtherAssets = {
		--[asset id] = rank id
		[0] = 0;
	}
}


module.ChatTags = true; -- whether or not if chat  tags should appear for each staff rank (any rank with an id > 0)
module.OverheadTags = {
	Enabled = true; -- whether or not if there should be a tag over the player's head (any rank with an id > 0)
	Command = "/tag"; -- what command can be used to enable or disable the tag
}

module.DatastoreName = "SRX_DEFAULT_DS" -- !! CHANGE THIS TO WHATEVER YOU NEED IT TO BE || DO NOT LEAVE THE DATASTORE NAME AS IT CURRENTLY IS !!

module.SaveRanks = true; -- whether or not if ranks transfer from server to server (permanent rank changes)

module.IncludeChatSlashCommands = true; -- whether or not if you want to include the "/" commands in the chat instead of relying just on the prefix (these slash commands also don't appear in the chat)

module.VIPServerSettings = { -- settings for VIP servers
	VIPCommands = false; -- whether vip server owners get commands or not
	ServerOwnerRankId = 0; -- rank id for vip server owners
}

module.WebhookSettings = {
	["COMMANDS"] = {
		Enabled = true; -- whether to log commands or not
		WebhookLink = ""; -- webhook link
	};
	["DEV_CONSOLE"] = {
		Enabled = true; -- whether to log commands that goes through the developer console or not || note that it is currently impossible to detect who inputted what into roblox's developer console
		WebhookLink = "";
	}
}


module.Version = "1.0.0"; -- !! DO NOT DELETE OR MODIFY || THIS IS USED TO KEEP TRACK OF THE VERSION THE ADMIN SYSTEM IS RUNNING ON !! | if the version includes a "C" at the end, like "1.0.0C" then it means it is on the canary version


return module
