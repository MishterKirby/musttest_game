
network_whois = network_whois or {}
network_whois.modpath = minetest.get_modpath("network_whois")



function network_whois.display(name, target)
	local player = minetest.get_player_by_name(target)
	if not player then
		minetest.chat_send_player(name, "# Server: Player <" .. rename.gpn(target) .. "> not found.")
		return
	end

	local info = minetest.get_player_information(target)
	if not info then
		minetest.chat_send_player(name, "# Server: Information for player <" .. rename.gpn(target) .. "> not found!")
		return
	end

	minetest.chat_send_player(name, "# Server: Account <" .. rename.gpn(target) ..
		">: ADR " .. info.address ..
		", IPV " .. info.ip_version ..
		", CU " .. info.connection_uptime ..
		", AVG RTT " .. info.avg_rtt ..
		", PV " .. info.protocol_version ..
		", RN <" .. rename.grn(target) .. ">" ..
		".")
end



function network_whois.whois(name, param)
	if param == nil or param == "" then
		local players = minetest.get_connected_players()
		for k, v in pairs(players) do
			local pname = v:get_player_name()
			network_whois.display(name, pname)
		end
		return true
	end

	network_whois.display(name, param)
	return true
end



if not network_whois.registered then
	minetest.register_privilege("whois", {
		description = "Enables an authorized user to obtain information about a player's connection to the server.",
		give_to_singleplayer = false,
	})

	minetest.register_chatcommand("whois", {
		params = "[<player>]",
		description = "Get information about a player's connection to the server.",
		privs = {whois=true},

		func = function(...)
			return network_whois.whois(...)
		end
	})

	local c = "whois:core"
	local f = network_whois.modpath .. "/init.lua"
	reload.register_file(c, f, false)

	network_whois.registered = true
end

