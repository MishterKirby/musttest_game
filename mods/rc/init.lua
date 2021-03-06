
-- Realm Control Mod.
-- This mod manages realm boundaries and prevents players from moving freely
-- between realms/dimensions without programmatic intervention.
rc = rc or {}
rc.players = rc.players or {}
rc.modpath = minetest.get_modpath("rc")

-- Known realms. Min/max area positions should not overlap!
rc.realms = {
	{
		id = 1, -- REALM ID. Code relies on this.
		name = "overworld", -- Default/overworld realm.
		description = "Overworld",
		minp = {x=-30912, y=-30912, z=-30912},
		maxp = {x=30927, y=500, z=30927},
		gate_minp = {x=-30000, y=-30800, z=-30000},
		gate_maxp = {x=30000, y=-10, z=30000},
		orig = {x=0, y=-7, z=0}, -- Respawn point, if necessary.
		ground = -10,
		underground = -32, -- Affects sky color, see sky mod.
		sealevel = 0,
		windlevel = 20,
		realm_origin = {x=-1067, y=-10, z=8930},
		disabled = false, -- Whether realm can be "gated" to. Use when testing!
	},
	{
		id = 2, -- REALM ID. Code relies on this.
		name = "channelwood", -- Forest realm. 250 meters high.
		description = "Channelwood",
		minp = {x=-30912, y=3050, z=-30912},
		maxp = {x=30927, y=3300, z=30927},
		gate_minp = {x=-30000, y=3065, z=-30000},
		gate_maxp = {x=30000, y=3067, z=30000},
		orig = {x=0, y=-7, z=0}, -- Respawn point, if necessary.
		ground = 3066,
		underground = 3050,
		sealevel = 3066,
		windlevel = 3100,
		realm_origin = {x=2019, y=3066, z=-1992},
		disabled = false, -- Whether realm can be "gated" to.
	},
	{
		id = 3, -- REALM ID. Code relies on this.
		name = "jarkati",
		description = "Jarkati",
		minp = {x=-30912, y=3600, z=-30912},
		maxp = {x=30927, y=3900, z=30927},
		gate_minp = {x=-30000, y=3620, z=-30000},
		gate_maxp = {x=30000, y=3640, z=30000},
		orig = {x=0, y=-7, z=0}, -- Respawn point, if necessary.
		ground = 3740,
		underground = 3730,
		sealevel = 3740,
		windlevel = 3750,
		realm_origin = {x=1986, y=3700, z=-1864},
		disabled = false,
	},
	{
		id = 4, -- REALM ID. Code relies on this.
		name = "abyss",
		description = "Outback",
		minp = vector.add({x=-9174, y=4100, z=5782}, {x=-100, y=-100, z=-100}),
		maxp = vector.add({x=-9174, y=4100, z=5782}, {x=100, y=100, z=100}),
		gate_minp = vector.add({x=-9174, y=4100, z=5782}, {x=-80, y=-80, z=-80}),
		gate_maxp = vector.add({x=-9174, y=4100, z=5782}, {x=80, y=80, z=80}),
		orig = {x=-9223, y=4169, z=5861}, -- Same as server's static spawnpoint!
		ground = 4200,
		underground = 4160, -- Affects sky color, see sky mod.
		sealevel = 4200,
		windlevel = 4200,
		realm_origin = {x=-9174, y=4100, z=5782},
		disabled = true, -- Realm cannot receive an incoming gate. OFFICIAL.
	},
}

-- Return true if a position is underground in some realm.
-- False is returned if not underground.
-- Returns nil if position isn't in any valid realm.
function rc.position_underground(pos)
	local p = vector.round(pos)

	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is position within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			if p.y < v.underground then
				return true
			else
				return false
			end
		end
	end

	-- Not in any realm?
	return nil
end

-- Used by ice/ice-brick/snow nodes to determine if they should melt away.
-- This is also used by the tree-snowdust code to determine whether a tree
-- should spawn with snow on top.
function rc.ice_melts_at_pos(pos)
	if pos.y < -26000 or pos.y > 1000 then
		return true
	end
end

-- Convert realm position to absolute coordinate. May return NIL if not valid!
function rc.realmpos_to_pos(realm, pos)
	local data = rc.get_realm_data(realm:lower())
	if data then
		local origin = data.realm_origin
		return {
			x = origin.x + pos.x,
			y = origin.y + pos.y,
			z = origin.z + pos.z,
		}
	end

	-- Indicate failure.
	return nil
end

-- Convert absolute coordinate to realm position. May return NIL if not valid!
function rc.pos_to_realmpos(pos)
	local origin = rc.get_realm_origin_at_pos(pos)
	if origin then
		return {
			x = pos.x - origin.x,
			y = pos.y - origin.y,
			z = pos.z - origin.z,
		}
	end

	-- Indicate failure.
	return nil
end

function rc.pos_to_namestr(pos)
	local name = rc.pos_to_name(pos)
	local str = rc.pos_to_string(pos)

	str = string.gsub(str, "[%(%)]", "")

	return "(" .. name .. ": " .. str .. ")"
end

function rc.pos_to_name(pos)
	return rc.realm_description_at_pos(pos)
end

function rc.get_realm_origin_at_pos(p)
	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is position within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			local o = table.copy(v.realm_origin)
			return o
		end
	end

	-- Not in any realm?
	return nil
end

-- Obtain a string in the format "(x,y,z)".
function rc.pos_to_string(pos)
	local realpos = rc.pos_to_realmpos(pos)
	if realpos then
		return minetest.pos_to_string(realpos)
	end

	-- Indicate failure.
	return "(Nan,Nan,Nan)"
end

function rc.get_realm_data(name)
	for k, v in ipairs(rc.realms) do
		if v.name == name then
			return v
		end
		if v.name == "overworld" then
			-- Alternate names.
			if name == "netherworld" or name == "nether" or name == "caverns" or name == "caves" then
				return v
			end
		end
		if v.name == "abyss" then
			-- Alternate names.
			if name == "outback" then
				return v
			end
		end
	end
	return nil
end

function rc.get_random_enabled_realm_data()
	if (#rc.realms) < 1 then
		return
	end

	local tries = 1
	local realm = rc.realms[math.random(1, #rc.realms)]
	while realm.disabled and tries < 10 do
		tries = tries + 1
		realm = rc.realms[math.random(1, #rc.realms)]
	end

	if realm.disabled then
		return
	end

	return realm
end

function rc.get_random_realm_gate_position(pname, origin)
	if rc.is_valid_realm_pos(origin) then
		if origin.y >= 128 and origin.y <= 1000 then
			-- If gateway is positioned in the Overworld mountains,
			-- permit easy realm hopping.
			local realm = rc.get_random_enabled_realm_data()
			if not realm then
				return nil
			end
			assert(realm)

			local pos = {
				x = math.random(realm.gate_minp.x, realm.gate_maxp.x),
				y = math.random(realm.gate_minp.y, realm.gate_maxp.y),
				z = math.random(realm.gate_minp.z, realm.gate_maxp.z),
			}

			local below = vector.add(origin, {x=0, y=-16, z=0})
			local minp = vector.add(below, {x=-16, y=-16, z=-16})
			local maxp = vector.add(below, {x=16, y=16, z=16})

			-- Should find 30K stone.
			local positions, counts = minetest.find_nodes_in_area(minp, maxp, {"default:stone"})

			--for k, v in pairs(counts) do
			--	minetest.chat_send_player(pname, "# Server: " .. k .. " = " .. v .. "!")
			--end

			if counts["default:stone"] > math.random(10000, 30000) then
				-- Search again, even deeper. The stone amount should be MUCH higher.
				below = vector.add(below, {x=0, y=-32, z=0})
				minp = vector.add(below, {x=-16, y=-16, z=-16})
				maxp = vector.add(below, {x=16, y=16, z=16})
				positions, counts = minetest.find_nodes_in_area(minp, maxp, {"default:stone"})

				--for k, v in pairs(counts) do
				--	minetest.chat_send_player(pname, "# Server: " .. k .. " = " .. v .. "!")
				--end

				if counts["default:stone"] > math.random(20000, 32000) then
					--minetest.chat_send_player("MustTest", "# Server: Success! " .. counts["default:stone"])
					return pos
				end
			end
			return nil
		elseif origin.y > 1000 then
			-- The gateway is positioned in a realm somewhere.
			-- 9/10 times the exit point stays in the same realm.
			-- Sometimes a realm hop is possible.
			local realm
			if math.random(1, 10) == 1 then
				realm = rc.get_random_enabled_realm_data()
			else
				realm = rc.get_realm_data(rc.current_realm_at_pos(origin))
			end
			if not realm then
				return nil
			end
			assert(realm)

			-- Not more than 5000 meters away from origin!
			local pos = {
				x = math.random(-5000, 5000) + origin.x,
				y = math.random(-5000, 5000) + origin.y,
				z = math.random(-5000, 5000) + origin.z,
			}

			local min = math.min
			local max = math.max

			-- Clamp position to ensure we remain within realm boundaries.
			pos.x = max(realm.gate_minp.x, min(pos.x, realm.gate_maxp.x))
			pos.y = max(realm.gate_minp.y, min(pos.y, realm.gate_maxp.y))
			pos.z = max(realm.gate_minp.z, min(pos.z, realm.gate_maxp.z))

			return pos
		end
	end

	local realm = rc.get_realm_data("overworld")
	assert(realm)

	-- Player is in the Overworld or Nether. Use old Gateway behavior!
	-- Not more than 5000 meters in any direction, and MUST stay in the Overworld
	-- (or the Nether).
	local pos = {
		x = math.random(-5000, 5000) + origin.x,
		y = math.random(-5000, 5000) + origin.y,
		z = math.random(-5000, 5000) + origin.z,
	}

	local min = math.min
	local max = math.max

	-- Clamp position.
	pos.x = max(realm.gate_minp.x, min(pos.x, realm.gate_maxp.x))
	pos.y = max(realm.gate_minp.y, min(pos.y, realm.gate_maxp.y))
	pos.z = max(realm.gate_minp.z, min(pos.z, realm.gate_maxp.z))

	return pos
end

function rc.is_valid_gateway_region(pos)
	local p = vector.round(pos)
	for k, v in ipairs(rc.realms) do
		local gate_minp = v.gate_minp
		local gate_maxp = v.gate_maxp

		-- Is position within realm boundaries suitable for a gateway?
		if p.x >= gate_minp.x and p.x <= gate_maxp.x and
				p.y >= gate_minp.y and p.y <= gate_maxp.y and
				p.z >= gate_minp.z and p.z <= gate_maxp.z then
			return true
		end
	end

	-- Not in any realm?
	return false
end

function rc.is_valid_realm_pos(pos)
	local p = vector.round(pos)
	for i = 1, #rc.realms, 1 do
		local v = rc.realms[i]

		local minp = v.minp
		local maxp = v.maxp

		-- Is position within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			return true
		end
	end

	-- Not in any realm?
	return false
end

function rc.get_ground_level_at_pos(pos)
	local p = vector.round(pos)
	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is position within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			return true, v.ground
		end
	end

	-- Not in any realm?
	return false, nil
end

function rc.get_sea_level_at_pos(pos)
	local p = vector.round(pos)
	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is position within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			return true, v.sealevel
		end
	end

	-- Not in any realm?
	return false, nil
end

function rc.get_wind_level_at_pos(pos)
	local p = vector.round(pos)
	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is position within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			return true, v.windlevel
		end
	end

	-- Not in any realm?
	return false, nil
end

-- API function. Get string name of the current realm the player is in.
function rc.current_realm(player)
	local p = vector.round(player:get_pos())
	return rc.current_realm_at_pos(p)
end

-- API function. Get string name of the current realm at a position.
function rc.current_realm_at_pos(p)
	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is player within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			return v.name
		end
	end

	-- Not in any realm?
	return ""
end

-- API function. Get static spawn point of a named realm.
function rc.static_spawn(name)
	for k, v in ipairs(rc.realms) do
		if v.name == name then
			return table.copy(v.orig)
		end
	end

	-- Not in any realm?
	return {x=0, y=-7, z=0}
end

function rc.same_realm(p1, p2)
	return (rc.current_realm_at_pos(p1) == rc.current_realm_at_pos(p2))
end

function rc.realm_description_at_pos(p)
	-- Special realm name.
	if p.y < -25000 then
		return "Netherworld"
	elseif p.y < -5000 then
		return "Caverns"
	end

	for k, v in ipairs(rc.realms) do
		local minp = v.minp
		local maxp = v.maxp

		-- Is player within realm boundaries?
		if p.x >= minp.x and p.x <= maxp.x and
				p.y >= minp.y and p.y <= maxp.y and
				p.z >= minp.z and p.z <= maxp.z then
			return v.description
		end
	end

	-- Not in any realm?
	return "Void"
end

-- API function.
-- Check player position and current realm. If not valid, reset player to last
-- valid location. If last valid location not found, reset them to 0,0,0.
-- This function should be called from a global-step callback somewhere.
function rc.check_position(player)
	local p = vector.round(player:get_pos())
	local n = player:get_player_name()

	-- Data not initialized yet.
	if not rc.players[n] then
		return
	end

	local reset -- Table set if player out-of-bounds.

	-- Bounds check to avoid an engine bug. These coordinates should be the last
	-- row of nodes at the map edge. This way, we never teleport the player to a
	-- location that is strictly outside the world boundaries, if they trigger it.
	if p.x < -30912 or p.x > 30927 or
			p.y < -30912 or p.y > 30927 or
			p.z < -30912 or p.z > 30927 then
		-- Some old clients, it seems, can randomly cause this problem.
		-- Or someone is deliberately triggering it.
		reset = {}
		reset.spawn = rc.static_spawn("abyss")
	end

	-- Check if player is currently in the void.
	if not reset then
		if rc.players[n].realm == "" then
			reset = {}
			reset.spawn = rc.static_spawn("abyss")
		end
	end

	-- Do bounds checks for individual realms.
	if not reset then
		for k, v in ipairs(rc.realms) do
			-- Is player within boundaries of the realm they are supposed to be in?
			if rc.players[n].realm == v.name then
				local minp = v.minp
				local maxp = v.maxp

				if p.x < minp.x or p.x > maxp.x or
						p.y < minp.y or p.y > maxp.y or
						p.z < minp.z or p.z > maxp.z then
					reset = {}
					reset.spawn = v.orig -- Use current realm's respawn coordinates.
					break
				end
			end
		end
	end

	if reset then
		-- Player is out-of-bounds. Reset to last known good position.
		if not gdac.player_is_admin(n) then
			minetest.chat_send_all("# Server: Player <" .. rename.gpn(n) ..
				"> was caught in the inter-dimensional void!")
		end

		-- Notify wield3d we're adjusting the player position.
		-- Wielded item entities don't like sudden movement.
		wield3d.on_teleport()

		if player:get_hp() > 0 and rc.players[n] then
			-- Return player to last known good position.
			player:set_pos(rc.players[n].pos)
		else
			-- Return to realm's origin point.
			player:set_pos(reset.spawn)

			-- Update which realm the player is supposed to be in.
			-- (We might have crossed realms depending on what happened above.)
			rc.notify_realm_update(player, reset.spawn)
		end

		-- Damage player. Prevents them triggering this indefinitely.
		if player:get_hp() > 0 then
			player:set_hp(player:get_hp() - 2)
			if player:get_hp() <= 0 then
				if not gdac.player_is_admin(n) then
					minetest.chat_send_all("# Server: <" .. rename.gpn(n) ..
						"> found death in the void.")
				end
			end
		end

		return
	end

	-- If we got this far, the player is not out of bounds.
	-- Record last known good position. Realm name should be same as before.
	do
		local ps = rc.players[n].pos
		ps.x = p.x
		ps.y = p.y
		ps.z = p.z
	end
end

function rc.on_joinplayer(player)
	local n = player:get_player_name()
	local p = player:get_pos()
	-- Player's current dimension is determined from position on login.
	rc.players[n] = {
		pos = p,
		realm = rc.current_realm(player),
	}
end

function rc.on_leaveplayer(player, timeout)
	local n = player:get_player_name()
	rc.players[n] = nil
end

-- API function. Call this whenever a player teleports,
-- or lawfully changes realm. You can pass a player object or a name.
function rc.notify_realm_update(player, pos)
	local p = vector.round(pos)
	local n = ""
	if type(player) == "string" then
		n = player
	else
		n = player:get_player_name()
	end
	local tb = rc.players[n]
	if not tb then
		minetest.log("action", "could not find data for player " .. n .. " when updating realm info")
		return
	end
	tb.pos = p
	tb.realm = rc.current_realm_at_pos(p)
end

if not rc.registered then
	minetest.register_on_joinplayer(function(...)
		return rc.on_joinplayer(...)
	end)

	minetest.register_on_leaveplayer(function(...)
		return rc.on_leaveplayer(...)
	end)

	local c = "rc:core"
	local f = rc.modpath .. "/init.lua"
	reload.register_file(c, f, false)

	rc.registered = true
end
