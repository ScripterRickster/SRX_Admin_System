local module = {}

module.Prefix = "!" -- default prefix for the admin system || staff members will be able to set their own prefixes

module.Ranks = { -- ranks for the admin system to use

	--[[
	
	[rank_name] = { -- rank name
		RankId = 0; -- rank id
		RankColour = Color3.fromRGB(255,255,255); -- rank colour (optional parameter) | not including this means the user will not have a chat tag and an overhead tag if enabled
		CanUsePanel = false; -- whether the person at this rank can use the built-in admin panel
	}
	
	]]

	["Owner"] = { 
		RankId = 5;
		RankColour = Color3.fromRGB(0, 120, 180);
		CanUsePanel = true;

	};

	["Head Administrator"] = { 
		RankId = 4;
		RankColour = Color3.fromRGB(85, 255, 0);
		CanUsePanel = true;

	};
	["Developer"] = { 
		RankId = 3;
		RankColour = Color3.fromRGB(255, 170, 0);
		CanUsePanel = true;

	};
	["Administrator"] = { 
		RankId = 2;
		RankColour = Color3.fromRGB(255, 0, 0);
		CanUsePanel = true;

	};
	["Moderator"] = { 
		RankId = 1;
		RankColour = Color3.fromRGB(255, 255, 0);
		CanUsePanel = true;

	};
	["Regular"] = { 
		RankId = 0;
		CanUsePanel = false;

	};

}

module.RankBinds = {
	Users = {
		--{user_id OR username, rank id}
		--{"Scripter_Rickster",0};
		--{3422141408,0};
	};
	Groups = {
		--[group_id]  = {min_rank, rank id}
		--[[
		[0] = {
			Min_Group_Rank = 0;
			RankId = 0;
		}
		]]
	};
	Gamepasses = {
		--[gamepass id] = rank id
		--[0] = 0;
	};
	OtherAssets = {
		--[asset id] = rank id
		--[0] = 0;
	};

	DefaultAdminRank = 0; -- what rank you want everybody who isn't already ranked to be at
}


module.ChatTags = false; -- whether or not if chat  tags should appear for each staff rank (any rank with an id > 0)
module.OverheadTags = {
	Enabled = false; -- whether or not if there should be a tag over the player's head (any rank with an id > 0)
	Command = "/tag"; -- what command can be used to enable or disable the tag
}

module.DatastoreName = "SRX_DEFAULT_DS0000" -- !! CHANGE THIS TO WHATEVER YOU NEED IT TO BE || DO NOT LEAVE THE DATASTORE NAME AS IT CURRENTLY IS !!

module.SaveRanks = false; -- whether or not if ranks transfer from server to server (permanent rank changes) || PRIVATE SERVER RANKS WILL NOT SAVE

module.IncludeChatSlashCommands = false; -- whether or not if you want to include the "/" commands in the chat instead of relying just on the prefix (these slash commands also don't appear in the chat)

module.BanSettings = { -- ban settings
	BannedUsers = { -- who you want to manually perm-ban from your game (THIS DOES NOT GET RUN THROUGH ROBLOX'S BAN API
		-- [username] = reason;
		-- [userid] = reason;
		--[[
		EXAMPLE
		
		
		
		["Scripter_Rickster"] = "banned because why not";
		[3422141408] = "banned because why not";
		
		]]


	};

	ExcludeAltsInBans = false; -- whether you want to not ban their alt accounts as well | false = ban alts | true = don't ban alts
}

module.ManageInfractionRank = 0; -- the rank required to manage other infractions (I.E. being able to delete other people's infractions if said infraction is deletable)

module.CommandCooldown = 5; -- how long the cooldown is in-between each command execution

module.RequestTimeout = 60; -- how long the system waits to receive a response back from a request across all the servers before deleting the request (in seconds) || Higher value = longer wait times (which could lead to delayed actions and a ton of backlog)

module.VIPServerSettings = { -- settings for VIP servers
	VIPCommands = false; -- whether vip server owners get commands or not
	ServerOwnerRankId = 0; -- rank id for vip server owners
}

module.AI_Services = { -- if you wish to include a "chatbot" in the admin panel || THIS SERVICE USES OPENROUTER: https://openrouter.ai/
	Enabled = false; -- whether this feature is enabled
	OpenCloudAPI_Key = ""; -- put your OpenRouter API key here
	MinRank = 0; -- minimum rank required to be able to use this feature if enabled
	AI_Model = ""; -- the model of which is used through OpenRouter | Ex: "deepseek/deepseek-chat-v3.1:free"
	Max_Tokens = 2048; -- how long the response is based on tokens || higher the token amount, the longer the response and vice versa
	FilterAIMessages = true; -- whether to filter AI messages or not through Roblox's Filtering System
}

module.HelpCMDSettings = { -- settings for the help requests feature
	Enabled = false; -- whether this feature is enabled or not
	Command = "/help"; -- the command to use the help feature
	HandlerMinRank = 1; -- the minimum rank to respond to help requests
}

module.CommandConsoleSettings = { -- settings for the built-in command console
	Enabled = false; -- whether this feature is enabled or not
	MinRank = 1; -- the minimum rank to access this feature on the panel
}

module.ToolLocations = { -- locations of where the tools are at in the game
	game.ReplicatedStorage,
	game.ServerStorage,
}

module.HelpTickets = { -- help tickets allow users to submit reports that get directly sent to the staff
	Enabled = false; -- whether this feature is enabled or not
	Cooldown = 5; -- cooldown (in seconds) between every help ticket submission
	BackgroundImage = ""; -- the background image for the help ticket ui
};

module.ClientThemes = { -- themes that can be switched to for each client || available in Version 1.0.1 and onwards
	--[[
	["TEMPLATE"] = { -- theme name
		ThemeID = ""; -- asset id of this theme
		
	}
	]]

	["NO THEME"] = {
		ThemeID = "";
	};
	
	["SRX THEME"] = {
		ThemeID = "rbxassetid://117504597000768";
	}
}

module.WebhookProxies = { -- proxies for the webhooks
	-- {proxy link, can queue (so like adding /queue to the end of the link, but make sure the proxy service supports links with /queue)}

	{"http://c4.play2go.cloud:20894/api/webhooks/",false},
	{"https://webhook.newstargeted.com/api/webhooks/",false},
	{"https://webhook.lewisakura.moe/api/webhooks/",true},
}

module.WebhookSettings = {  -- settings for discord webhooks
	["COMMANDS"] = {
		Enabled = false; -- whether to log commands or not
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = ""; -- webhook link
		Mentionable_Ids = { --ids to mention when the webhook is sent
			
			Roles = {
				-- discord role id's (as a string)
				-- Ex: "123456789"
			};
			
			Users = {
				-- discord user id's (as a string)
				-- Ex: "987654321"
			};
			
		};
	};
	["DEV_CONSOLE"] = {
		Enabled = false; -- whether to log commands that goes through the developer console or not || note that it is currently impossible to detect who inputted what into roblox's developer console
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = ""; -- webhook link
		Mentionable_Ids = { --ids to mention when the webhook is sent
			
			Roles = {
				-- discord role id's (as a string)
				-- Ex: "123456789"
			};
			
			Users = {
				-- discord user id's (as a string)
				-- Ex: "987654321"
			};
			
		};
	};
	["INFRACTION_LOGS"] = { 
		Enabled = false; -- whether or not if the system sends a log every time an infraction is created or removed
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = ""; -- webhook link
		Mentionable_Ids = { --ids to mention when the webhook is sent
			
			Roles = {
				-- discord role id's (as a string)
				-- Ex: "123456789"
			};
			
			Users = {
				-- discord user id's (as a string)
				-- Ex: "987654321"
			};
			
		};
	};
	["JOIN_LOGS"] = { 
		Enabled = false; -- whether or not if the system sends a log every time a user joins / leaves || NOT RECOMMENDED TO HAVE ENABLED DUE TO POTENTIAL RATELIMIT ISSUES
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = ""; -- webhook link
		Mentionable_Ids = { --ids to mention when the webhook is sent
			
			Roles = {
				-- discord role id's (as a string)
				-- Ex: "123456789"
			};
			
			Users = {
				-- discord user id's (as a string)
				-- Ex: "987654321"
			};
			
		};
	};
	["CHAT_LOGS"] = {
		Enabled = false; -- whether or not if the system sends a log every time a user sends a message || HEAVILY NOT RECOMMENDED TO HAVE ENABLED DUE TO POTENTIAL RATELIMIT ISSUES
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = "";
		Mentionable_Ids = { --ids to mention when the webhook is sent
			
			Roles = {
				-- discord role id's (as a string)
				-- Ex: "123456789"
			};
			
			Users = {
				-- discord user id's (as a string)
				-- Ex: "987654321"
			};
			
		};
	};
	["HELP_TICKET_LOGS"] = {
		Enabled = false; -- whether or not if the system sends a log every time a user submits a help ticket
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = "";
		Mentionable_Ids = { --ids to mention when the webhook is sent
			
			Roles = {
				-- discord role id's (as a string)
				-- Ex: "123456789"
			};
			
			Users = {
				-- discord user id's (as a string)
				-- Ex: "987654321"
			};
			
		};
	}
}


return module
