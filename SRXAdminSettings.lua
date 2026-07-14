local module = {}



module.Prefix = "!" -- default prefix for the admin system || staff members will be able to set their own prefixes

module.Ranks = { -- ranks for the admin system to use
	
	--[[
	
	[rank_name] = { -- rank name
		RankId = 0; -- rank id
		RankColour = Color3.fromRGB(255,255,255); -- rank colour (optional parameter) | not including this means the user will not have a chat tag and an overhead tag if enabled
		CanUsePanel = false; -- whether the person at this rank can use the built-in admin panel
		IsStaffRank = false; -- whether this rank is officially considered as a staff rank for the game or not (for example, scenario's with games that contain contributor and VIP ranks)
	}
	
	]]
	
	["Owner"] = { 
		RankId = 5;
		RankColour = Color3.fromRGB(0, 120, 180);
		CanUsePanel = true;
		IsStaffRank = true;
		
	};
	["Head Administrator"] = { 
		RankId = 4;
		RankColour = Color3.fromRGB(85, 255, 0);
		CanUsePanel = true;
		IsStaffRank = true;

	};
	["Developer"] = { 
		RankId = 3;
		RankColour = Color3.fromRGB(255, 170, 0);
		CanUsePanel = true;
		IsStaffRank = true;

	};
	["Administrator"] = { 
		RankId = 2;
		RankColour = Color3.fromRGB(255, 0, 0);
		CanUsePanel = true;
		IsStaffRank = true;

	};
	["Moderator"] = { 
		RankId = 1;
		RankColour = Color3.fromRGB(255, 255, 0);
		CanUsePanel = true;
		IsStaffRank = true;

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
		--[[
		
		[group_id] = {
			[rankid] = min_group_rank;
			[rankid] = min_group_rank;
		};
		
		[0] = {
			[0] = 0;
			[1] = 123;
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
	
	DefaultAdminRank = 5; -- what rank you want everybody who isn't already ranked to be at
};

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


module.DatastoreSettings = {
	DatastoreName = "SRX_DEFAULT_DS0001"; -- !! CHANGE THIS TO WHATEVER YOU NEED IT TO BE || DO NOT LEAVE THE DATASTORE NAME AS IT CURRENTLY IS !!

	SaveRanks = false; -- whether or not if ranks transfer from server to server (permanent rank changes) || PRIVATE SERVER RANKS WILL NOT SAVE
}


module.CommandSettings = {
	
	CommandCooldown = 5; -- how long the cooldown is in-between each command execution
	
	IncludeChatSlashCommands = false; -- whether or not if you want to include the "/" commands in the chat instead of relying just on the prefix (these slash commands also don't appear in the chat)
	
};

module.AdministrativeSettings = {
	
	ManageInfractionRank = 0; -- the rank required to manage other infractions (I.E. being able to delete other people's infractions if said infraction is deletable)
	
	HelpCMDSettings = { -- settings for the help requests feature
		Enabled = false; -- whether this feature is enabled or not
		Command = "/help"; -- the command to use the help feature
		HandlerMinRank = 1; -- the minimum rank to respond to help requests
	};

	HelpTickets = { -- help tickets allow users to submit reports that get directly sent to the staff
		Enabled = false; -- whether this feature is enabled or not
		Cooldown = 5; -- cooldown (in seconds) between every help ticket submission
		BackgroundImage = "rbxassetid://89822929422262"; -- the background image for the help ticket ui
		BackgroundImageTransparency = 0.5; -- the background image transparency for the help ticket ui
	};
	
};


module.GeneralSettings = {
	
	RequestTimeout = 60; -- how long the system waits to receive a response back from a request across all the servers before deleting the request (in seconds) || Higher value = longer wait times (which could lead to delayed actions and a ton of backlog)
	
	ToolLocations = { -- locations of where the tools are at in the game
		game.ReplicatedStorage,
		game.ServerStorage,
	};
	
	VIPServerSettings = { -- settings for VIP servers
		VIPCommands = false; -- whether vip server owners get commands or not
		ServerOwnerRankId = 0; -- rank id for vip server owners
	};
	
	EnableDebugComments = false; -- whether or not if you want debug information to be printed out or not
	
};


module.AI_Services = { -- if you wish to include a "chatbot" in the admin panel || THIS SERVICE USES OPENROUTER: https://openrouter.ai/
	Enabled = false; -- whether this feature is enabled
	OpenCloudAPI_Key = ""; -- put your OpenRouter API key here
	MinRank = 0; -- minimum rank required to be able to use this feature if enabled
	AI_Model = ""; -- the model of which is used through OpenRouter | Ex: "deepseek/deepseek-chat-v3.1:free"
	Max_Tokens = 2048; -- how long the response is based on tokens || higher the token amount, the longer the response and vice versa
	FilterAIMessages = true; -- whether to filter AI messages or not through Roblox's Filtering System
}


module.DecorativeSettings = {

	ChatTags = true; -- whether or not if chat  tags should appear for each staff rank (any rank with an id > 0)

	OverheadTags = {
		Enabled = true; -- whether or not if there should be a tag over the player's head (any rank with an id > 0)
		Command = "/tag"; -- what command can be used to enable or disable the tag
	};

};


module.PanelSettings = { 
	UIVersion = "v2"; -- default: v2 || set to "v1" or 'v2" for whichever version of the user-interface you want to use || WARNING: "v1" USER INTERFACE WILL EVENTUALLY BE DEPRECEATED AND ALL USERS WILL HAVE TO MIGRATE TO THE "v2" USER INTERFACE
	-- also note that module.UIVersion is not required to be included in your config file
	
	SystemAccessType = "Tool"; -- whether you use a tool to bring up the UI, or you click on a button at the top || "Tool" -> a tool that you equip to bring up the UI, "Button"  -> a button that you click at the top of your screen to bring up the UI || any invalid options will be treated by the default option of a "tool"
	
	UpdateLog = { -- update log description area
		Enabled = true; -- whether to show the update log inside of the admin panel
		Text = "SRX Admin V2 Release 🔥"; -- description for the update log - supports richtext
	};
	
	CommandConsoleSettings = { -- settings for the built-in command console
		Enabled = false; -- whether this feature is enabled or not
		MinRank = 1; -- the minimum rank to access this feature on the panel
	};
	
	ClientThemes = { -- themes for the admin panel that people can chose from
		["NO THEME"] = {
			ThemeID = "";
			ThemeTransparency = 0;
		};

		["SRX THEME"] = {
			ThemeID = "rbxassetid://117504597000768";
			ThemeTransparency = 0.8;
		};

		["SRX THEME 2"] = {
			ThemeID = "rbxassetid://86679539820484";
			ThemeTransparency = 0.8;
		};
	};
};



module.WebhookProxies = { -- proxies for the webhooks
	-- {proxy link, can queue (so like adding /queue to the end of the link, but make sure the proxy service supports links with /queue)}

	{"http://c4.play2go.cloud:20894/api/webhooks/",false},
	{"https://webhook.newstargeted.com/api/webhooks/",false},
	{"https://webhook.lewisakura.moe/api/webhooks/",true},
}

module.WebhookSettings = { -- settings for discord webhooks
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
				-- discord role id's
				-- Ex: 123456789
			};

			Users = {
				-- discord user id's
				-- Ex: 987654321
			};

		};
	};
	["INFRACTION_LOGS"] = { 
		Enabled = false; -- whether or not if the system sends a log every time an infraction is created or removed
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = ""; -- webhook link
		Mentionable_Ids = { --ids to mention when the webhook is sent

			Roles = {
				-- discord role id's
				-- Ex: 123456789
			};

			Users = {
				-- discord user id's
				-- Ex: 987654321
			};

		};
	};
	["JOIN_LOGS"] = { 
		Enabled = false; -- whether or not if the system sends a log every time a user joins / leaves || NOT RECOMMENDED TO HAVE ENABLED DUE TO POTENTIAL RATELIMIT ISSUES
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = ""; -- webhook link
		Mentionable_Ids = { --ids to mention when the webhook is sent

			Roles = {
				-- discord role id's
				-- Ex: 123456789
			};

			Users = {
				-- discord user id's
				-- Ex: 987654321
			};

		};
	};
	["CHAT_LOGS"] = {
		Enabled = false; -- whether or not if the system sends a log every time a user sends a message || HEAVILY NOT RECOMMENDED TO HAVE ENABLED DUE TO POTENTIAL RATELIMIT ISSUES
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = "";
		Mentionable_Ids = { --ids to mention when the webhook is sent

			Roles = {
				-- discord role id's
				-- Ex: 123456789
			};

			Users = {
				-- discord user id's
				-- Ex: 987654321
			};

		};
	};
	["HELP_TICKET_LOGS"] = {
		Enabled = false; -- whether or not if the system sends a log every time a user submits a help ticket
		EmbedColour = Color3.fromRGB(255,255,255);
		WebhookLink = "";
		Mentionable_Ids = { --ids to mention when the webhook is sent

			Roles = {
				-- discord role id's
				-- Ex: 123456789
			};

			Users = {
				-- discord user id's
				-- Ex: 987654321
			};

		};
	};
}



return module
