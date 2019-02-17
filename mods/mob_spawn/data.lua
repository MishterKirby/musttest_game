
-- Clear registration table afresh. Allows loading file multiple times.
mob_spawn.registered = {}
local register = mob_spawn.register_spawn

register({
	name = "dm:dm",
	nodes = {
    "default:stone",
    "cavestuff:cobble_with_moss",
    "cavestuff:cobble_with_lichen",
    "cavestuff:cobble_with_algae",
  },
	min_light = 0,
	max_light = 2,
	max_height = -2048,
	spawn_height = 3,
})

register({
	name = "dm:dm",
	nodes = {
    "rackstone:rackstone",
    "rackstone:redrack",
    "rackstone:mg_rackstone",
    "rackstone:mg_redrack",
  },
	min_light = 0,
	max_light = 4,
	max_height = -25000,
	spawn_height = 3,
})

register({
	name = "golem:stone_golem",
	nodes = {"whitestone:stone"},
	min_light = 0,
	max_light = 6,
	max_height = -25000,
	spawn_height = 3,
})

-- Caverealm griefer mob.
-- Spawning behavior is similar to icemen on the surface.
register({
  name = "griefer:griefer",
  nodes = {
    "cavestuff:dark_obsidian",
		"cavestuff:cobble_with_moss",
		"cavestuff:cobble_with_algae",
  },
  min_light = 0,
  max_light = 4,
  min_height = -31000,
  max_height = -5000,
  day_toggle = true,
})

register({
  name = "iceman:iceman",
  nodes = {
		-- Does not spawn on tree snow or ice.
    "default:snow",
		"snow:footprints",
  },
  min_light = 0,
  max_light = 4,
  mob_limit = 20,
  min_height = -21,
  max_height = 70,
  day_toggle = false,

	-- The hight limit for this mob means we can afford more spawn checks.
	saturation_time_min = 20,
	saturation_time_max = 60,
})

register({
	name = "obsidianmonster:obsidianmonster",
	nodes = {"air"},
	min_light = 0,
	max_light = 0,
	max_height = -256,
})

-- That flying thing.
register({
	name = "oerkki:oerkki",
	nodes = {"air"},
	min_light = 0,
	max_light = 0,
	min_height = -31000,
	max_height = -10,
})

register({
	name = "rat:rat",
	nodes = {"default:stone"},
	min_light = 0,
	max_light = default.LIGHT_MAX,
	min_height = -128,
	max_height = 31000,
	spawn_height = 1,
})

register({
	name = "sheep:sheep",
	nodes = {"default:dirt_with_grass", "moregrass:darkgrass", "default:dirt_with_dry_grass"},
	min_light = 10,
	max_light = default.LIGHT_MAX,
	min_height = -30,
	max_height = 31000,
	day_toggle = nil, -- They spawn anytime.
})

register({
	name = "skeleton:skeleton",
	nodes = {
    "rackstone:rackstone",
    "rackstone:redrack",
    "rackstone:mg_rackstone",
    "rackstone:mg_redrack",
  },
	min_light = 0,
	max_light = 6,
	mob_limit = 10,
	max_height = -25000,
	spawn_height = 3,
})

register({
	name = "stoneman:stoneman",
	nodes = {"default:stone", "default:cobble"},
	min_light = 0,
	max_light = 1,
	mob_limit = 10,
	max_height = -128,
})

register({
	name = "warthog:warthog",
	nodes = {
    "rackstone:rackstone",
    "rackstone:redrack",
    "rackstone:mg_rackstone",
    "rackstone:mg_redrack",
  },
	min_light = 0,
	max_light = 6,
	mob_limit = 10,
	max_height = -25000,
	min_count = 7,
	max_count = 16,
})

-- Reinit per-player data.
mob_spawn.players = {}
local players = minetest.get_connected_players()
for k, v in ipairs(players) do
	-- This is an indexed array.
	local pname = v:get_player_name()
	mob_spawn.reinit_player(pname)
end