
shout = shout or {}
shout.modpath = minetest.get_modpath("shout")
shout.worldpath = minetest.get_worldpath()
shout.datafile = shout.worldpath .. "/hints.txt"
shout.players = shout.players or {}

local SHOUT_COLOR = core.get_color_escape_sequence("#ff2a00")
local TEAM_COLOR = core.get_color_escape_sequence("#a8ff00")
local WHITE = core.get_color_escape_sequence("#ffffff")



shout.HINTS = {}
shout.BUILTIN_HINTS = {
	"You can ignore players who create drama or ruin chat by using the chat-filter interface, accessed through the Key of Citizenship.",
	"Mobs sometimes place blocks in protected areas. This is not griefing, because the blocks are not protected. Anyone may remove them.",
	"You may use the '/r <message>' command to quickly reply via PM to the last player to send you a PM.",
	"Strenuous activity increases your exhaustion and therefore hunger over time. This includes swimming, mining, or sprinting.",
	"Fallen blocks can be dug by anyone, even in protected areas.",
	"Use /channel to join a group PM channel, and /x to communicate to the channel's members.",
	"Stamina comes back faster when you are not hungry and resting in one place.",
	"Use the /players command when part of a group PM channel to see others on your channel.",
	"The ID Marker item hides your name, and obfuscates the public bones report when you die or pick bones.",
	"Most plants grow poorly near ice. Some plants won't grow at all.",
	"You can test protection without harming yourself by punching nodes with a stick.",
	"Falling nodes dropped above farms and gardens will do no damage to protected plants.",
	"Use teleports, gateways, and flameportals to get around quickly.",
	"Place city marker blocks to mark your land as part of the city, to help suppress unwanted PvP.",
	"Some rare foods heal hearts immediately. You may prefer to save these for combat situations.",
	"Most trees will refuse to grow underground. Firetrees do not suffer this limitation.",
	"You can get information about a node using the node inspector tool.",
	"To maintain your account, always keep a passport token (Proof or Key) in your main inventory.",
	"Players are not sent to jail for kills committed with ranged weapons or other indirect munitions.",
	"Prevent griefing by protecting your structures. Serious builders are advised to protect the land around their builds as well.",
	"Protect your bases to prevent griefing by others.",
	"Protection stops most types of environment damage, but does not prevent damage from lava.",
	"Certain blocks are vulnerable to lava griefing even when protected, such as stone and cobble.",
	"Certain foods refresh stamina, and can be used to give your avatar an extra endurance boost.",
	"A hurt player will usually heal slowly, up to the last two hearts. Use bandages to speed this up.",
	"Travel speed is affected by the surfaces you travel on. Prefer using roads and avoid deep snow.",
	"Flowers, plants, and saplings can be found in the deep wastes far from the city.",
	"Use the /mapfix command to correct issues with lighting or liquid flow. See /help mapfix.",
	"Lava does not respect protection and is very dangerous; however lava cannot exist above sea level.",
	"You can place water for farms above sea level by melting ice with torches or fire.",
	"You can travel over flat snow or ice quickly using a sled.",
	"Icemen are the primary source of mossy cobble, which is used as a fuel in some teleports.",
	"You can place a public bed (not ownable by anyone) by holding 'E' when you place it.",
	"You can place nearly any block as a falling node by holding 'E' when you place it, with air below.",
	"The brimstone ocean contains a few resources not found anywhere else; however the entire underworld is very dangerous.",
	"Locked chests are unlocked (and items may be stolen) if the chest lid is open.",
	"When you die, sometimes your bones are placed in odd places. Look around very carefully before giving up.",
	"Starvation will drain your health down to half a heart, but will not kill you.",
	"You can sleep in a bed to set your respawn position on death.",
	"Use bandages to keep your health full. Stamina and hunger will benefit.",
	"Being hurt reduces your ability to sprint and jump.",
	"Prefer traveling by road or teleport when possible for faster transit times.",
	"Your speech is published live on channel 40,000. Please do not swear.",
	"Bonebox deployment is part of this adventure.",
	"Information-latency can be a nuisance.",
	"A diving helmet and canisters of compressed air will allow you to stay underwater longer.",
	"Lava causes strong, localized convection currents.",
	"Water is wet.",
	"Beware the guards of the Deep.",
	"This is a useless message.",
	"Obsidian Gateways and Flameportals are fragile methods of transportation. Protect them!",
	"This is a confused message.",
	"This message doesn't have any meaning.",
	"Pay no attention to the man behind the curtain.",
	"Shears and silver picks can sometimes be used to obtain materials or resources that other tools cannot.",
	"Walk softly and carry a big stick.",
	"Punching an itemframe or pedestal with a stick will restore missing item entities.",
	"Items placed in itemframes or pedestals may occasionally become invisible. Punch with a stick to restore them.",
	"Dry shrubs and torches (lit or not) may be crafted into sticks.",
	"New player short on fuel? You can burn wooden armor in stone furnaces.",
	"That's a Waitabit Tree. Don't go near a Waitabit Tree. They grab you.",
	"Most trees are sensitive to cold conditions and may refuse to grow. The Firetree is particularly ornery.",
	"All positions given in server messages are in realm-coordinates. Absolute (F5) coordinates are not used.",
	"Found a bug? You can send in-game email to MustTest to report it.",
	"This sentence is false.",
	"You can send game-balance suggestions to MustTest using the in-game email system.",
	"Mr. Momoa, your trailer's on fire.",
	"You can use a trade booth to buy and sell items remotely, for shops set up to support it.",
}

function shout.hint_add(name, param)
	name = name:trim()
	param = param:trim()
	param = param:gsub("%s+", " ")

	if param:len() == 0 then
		minetest.chat_send_player(name, "# Server: Not adding an empty hint message.")
		return
	end

	minetest.chat_send_player(name, "# Server: Will add hint message: \"" .. param .. "\".")

	-- Will store all hints loaded from file.
	local loaded_hints = {}

	-- Load all hints from world datafile.
	local file, err = io.open(shout.datafile, "r")
	if err then
		minetest.chat_send_player(name, "# Server: Failed to open \"" .. shout.datafile .. "\" for reading: " .. err)
	else
		local datastring = file:read("*all")
		if datastring and datastring ~= "" then
			local records = string.split(datastring, "\n")
			for record_number, record in ipairs(records) do
				local data = record:trim()
				if data:len() > 0 then
					table.insert(loaded_hints, data)
				end
			end
		end
		file:close()
	end

	minetest.chat_send_player(name, "# Server: Loaded " .. #loaded_hints .. " previously saved hints.")

	-- Add the new hint message.
	table.insert(loaded_hints, param)

	-- Custom file format. minetest.serialize() is unusable for large tables.
	local datastring = ""
	for k, record in ipairs(loaded_hints) do
		datastring = datastring .. record .. "\n"
	end

	-- Now save all non-builtin hints back to the file.
	local file, err = io.open(shout.datafile, "w")
	if err then
		minetest.chat_send_player(name, "# Server: Failed to open \"" .. shout.datafile .. "\" for writing: " .. err)
	else
		file:write(datastring)
		file:close()
	end

	-- Recombine both tables.
	shout.HINTS = {}
	for k, v in ipairs(shout.BUILTIN_HINTS) do
		table.insert(shout.HINTS, v)
	end
	for k, v in ipairs(loaded_hints) do
		table.insert(shout.HINTS, v)
	end
end

-- Load any saved hints whenever mod is reloaded or server starts.
do
	-- Will store all hints loaded from file.
	local loaded_hints = {}

	-- Load all hints from world datafile.
	local file, err = io.open(shout.datafile, "r")
	if err then
		minetest.log("error", "Failed to open " .. shout.datafile .. " for reading: " .. err)
	else
		local datastring = file:read("*all")
		if datastring and datastring ~= "" then
			local records = string.split(datastring, "\n")
			for record_number, record in ipairs(records) do
				local data = record:trim()
				if data:len() > 0 then
					table.insert(loaded_hints, data)
				end
			end
		end
		file:close()
	end

	-- Recombine both tables.
	shout.HINTS = {}
	for k, v in ipairs(shout.BUILTIN_HINTS) do
		table.insert(shout.HINTS, v)
	end
	for k, v in ipairs(loaded_hints) do
		table.insert(shout.HINTS, v)
	end
end

local HINT_DELAY_MIN = 60*45
local HINT_DELAY_MAX = 60*90

function shout.print_hint()
	local HINTS = shout.HINTS

	-- Only if hints are available.
	if #HINTS > 0 then
		minetest.chat_send_all("# Server: " .. HINTS[math.random(1, #HINTS)])
	end

	-- Print another hint after some delay.
	minetest.after(math.random(HINT_DELAY_MIN, HINT_DELAY_MAX), function() shout.print_hint() end)
end



-- Shout a message.
function shout.shout(name, param)
	param = string.trim(param)
	if #param < 1 then
		minetest.chat_send_player(name, "# Server: No message specified.")
		easyvend.sound_error(name)
		return
	end

	if command_tokens.mute.player_muted(name) then
		minetest.chat_send_player(name, "# Server: You cannot shout while gagged!")
		easyvend.sound_error(name)
		return
	end

	-- If this succeeds, the player was either kicked, or muted and a message about that sent to everyone else.
	if chat_core.check_language(name, param) then return end

	local mk = chat_core.generate_coord_string(name)
	local dname = rename.gpn(name)
	local players = minetest.get_connected_players()

	for _, player in ipairs(players) do
		local target_name = player:get_player_name() or ""
		if not chat_controls.player_ignored_shout(target_name, name) or target_name == name then
			chat_core.alert_player_sound(target_name)
			minetest.chat_send_player(target_name, "<!" .. chat_core.nametag_color .. dname .. WHITE .. mk .. "!> " .. SHOUT_COLOR .. param)
		end
	end

	afk_removal.reset_timeout(name)
	chat_logging.log_public_shout(name, param, mk)
end


function shout.player_channel(pname)
	if shout.players[pname] and shout.players[pname] ~= "" then
		return shout.players[pname]
	end
end

function shout.channel_players(channel)
	local players = minetest.get_connected_players()
	local result = {}
	for k, v in ipairs(players) do
		local n = v:get_player_name()
		if shout.players[n] and shout.players[n] == channel then
			result[#result+1] = n
		end
	end
	return result
end

function shout.notify_channel(channel, message)
	local players = minetest.get_connected_players()

	-- Send message to all players in the same channel.
	for k, v in ipairs(players) do
		local n = v:get_player_name()
		if shout.players[n] and shout.players[n] == channel then
			minetest.chat_send_player(n, TEAM_COLOR .. message)
		end
	end
end

-- let player join, leave channels
function shout.channel(name, param)
	param = string.trim(param)

	if param == "" then
		if shout.players[name] then
			shout.notify_channel(shout.players[name],
				"# Server: Player <" .. rename.gpn(name) .. "> has left channel '" .. shout.players[name] .. "'.")
		end
		minetest.chat_send_player(name, "# Server: Channel cleared.")
		shout.players[name] = nil
		return
	end

	if shout.players[name] and shout.players[name] == param then
		minetest.chat_send_player(name, "# Server: You are already on channel '" .. param .. "'.")
		return
	end

	-- Require channel names to match specific format.
	if not string.find(param, "^[_%w]+$") then
		minetest.chat_send_player(name, "# Server: Invalid channel name! Use only alphanumeric characters and underscores.")
		easyvend.sound_error(name)
		return
	end

	if shout.players[name] and param ~= shout.players[name] then
		shout.notify_channel(shout.players[name],
			"# Server: Player <" .. rename.gpn(name) .. "> has left channel '" .. shout.players[name] .. "'.")
	end

	minetest.chat_send_player(name, "# Server: Chat channel set to '" .. param .. "'.")
	shout.players[name] = param
	shout.notify_channel(shout.players[name], "# Server: Player <" .. rename.gpn(name) .. "> has joined channel '" .. shout.players[name] .. "'.")
end

-- let player put a message onto a channel
function shout.x(name, param)
	param = string.trim(param)
	if not shout.players[name] then
		minetest.chat_send_player(name, "# Server: You have not specified a channel.")
		easyvend.sound_error(name)
		return
	end

	if #param < 1 then
		minetest.chat_send_player(name, "# Server: No message specified.")
		easyvend.sound_error(name)
		return
	end

	if command_tokens.mute.player_muted(name) then
		minetest.chat_send_player(name, "# Server: You cannot talk while gagged!")
		easyvend.sound_error(name)
		return
	end

	-- If this succeeds, the player was either kicked, or muted and a message about that sent to everyone else.
	if chat_core.check_language(name, param) then return end

	local mk = ""
	if command_tokens.mark.player_marked(name) then
		local pos = minetest.get_player_by_name(name):getpos()
		mk = " [" .. math.floor(pos.x) .. "," .. math.floor(pos.y) .. "," .. math.floor(pos.z) .. "]"
	end

	local dname = rename.gpn(name)
	local channel = shout.players[name]
	local players = minetest.get_connected_players()

	-- Send message to all players in the same channel.
	-- The player who sent the message always receives it.
	for k, v in ipairs(players) do
		local n = v:get_player_name()
		if shout.players[n] and shout.players[n] == channel then
			local ignored = false

			-- Don't send teamchat if player is ignored.
			if chat_controls.player_ignored(n, name) then
				ignored = true
			end

			if not ignored then
				minetest.chat_send_player(n, "<!" .. chat_core.nametag_color .. rename.gpn(name) .. WHITE .. mk .. "!> " .. TEAM_COLOR .. param)
			end
		end
	end

	--minetest.chat_send_all(SHOUT_COLOR .. "<!" .. dname .. mk .. "!> " .. param)
	--chat_logging.log_public_shout(name, param, mk)

	chat_logging.log_team_chat(name, param, channel)
	afk_removal.reset_timeout(name)
end



if not shout.run_once then
	minetest.after(10, function()
		minetest.chat_send_all("# Server: Startup complete.")
	end)

	minetest.register_chatcommand("shout", {
		params = "<message>",
		description = "Yell a message to everyone on the server. You can also prepend your chat with '!'.",
		privs = {shout=true},
		func = function(name, param)
			shout.shout(name, param)
			return true
		end,
	})

	minetest.register_chatcommand("channel", {
		params = "<id>",
		description = "Set channel name.",
		privs = {shout=true},
		func = function(name, param)
			shout.channel(name, param)
			return true
		end,
	})

	minetest.register_chatcommand("x", {
		params = "<message>",
		description = "Speak on current channel.",
		privs = {shout=true},
		func = function(name, param)
			shout.x(name, param)
			return true
		end,
	})

	-- Start hints. A hint is written into public chat every so often.
	-- But not too often, or it becomes annoying.
	minetest.after(math.random(HINT_DELAY_MIN, HINT_DELAY_MAX), function() shout.print_hint() end)

	local c = "shout:core"
	local f = shout.modpath .. "/init.lua"
	reload.register_file(c, f, false)

	shout.run_once = true
end

if not shout.run_once2 then
	minetest.register_chatcommand("hint_add", {
		params = "<message>",
		description = "Add a hint message to the hint list. Example between quotes: '/hint_add This is a hint message. Another sentance.'",
		privs = {server=true},
		func = function(name, param)
			shout.hint_add(name, param)
			return true
		end,
	})

	shout.run_once2 = true
end
