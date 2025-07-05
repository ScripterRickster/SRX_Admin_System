local module = {}

module.Prefix = "!"

module.Ranks = { -- ranks for the admin system to use
	--{rank id, rank name}
	{5,"Owner"};
	{4,"Head Administrator"};
	{3,"Developer"};
	{2,"Administrator"};
	{1,"Moderator"};
	{0,"Regular"};
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
			Min_Group_Rank = 5;
			Rank = 0;
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

module.DatastoreName = "SRX_DEFAULT" -- !! CHANGE THIS TO WHATEVER YOU NEED IT TO BE !!

module.WebhookSettings = {
	["COMMANDS"] = {
		Enabled = true; -- whether to log commands or not
		WebhookLink = ""; -- webhook link
	};
	["DEV_CONSOLE"] = {
		Enabled = true; -- whether to log stuff that goes through the dev console or not
		WebhookLink = "";
	}
}


module.Version = "1.0.0"; -- !! DO NOT DELETE OR MODIFY || THIS IS USED TO KEEP TRACK OF THE VERSION THE ADMIN SYSTEM IS RUNNING ON !! | if the version includes a "C" at the end, like "1.0.0C" then it means it is on the canary version


return module
