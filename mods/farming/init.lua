-- Global farming namespace
farming = {}
farming.path = minetest.get_modpath("farming")

farming.select = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
}

-- Load files
dofile(farming.path .. "/api.lua")
dofile(farming.path .. "/nodes.lua")
dofile(farming.path .. "/hoes.lua")

-- WHEAT
farming.register_plant("farming:wheat", {
	description = "Wheat Seed",
  paramtype2 = "meshoptions",
	inventory_image = "farming_wheat_seed.png",
	steps = 8,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
  groups = {flammable = 4},
  place_param2 = 3,
})
minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
	groups = {flammable = 1, foodrot=1},
})

minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	on_use = minetest.item_eat(5),
	groups = {flammable = 2, foodrot=1},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {"farming:wheat", "farming:wheat", "farming:wheat", "farming:wheat"}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 5,
	output = "farming:bread",
	recipe = "farming:flour"
})

-- Cotton
farming.register_plant("farming:cotton", {
	description = "Cotton Seed",
	inventory_image = "farming_cotton_seed.png",
	steps = 8,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland", "desert"},
    groups = {flammable = 4},
})

-- alias no longer used -- we have an actual string item that is craftable from cotton
--minetest.register_alias("farming:string", "farming:cotton")

minetest.register_craft({
	output = "wool:white",
	recipe = {
		{"farming:cotton", "farming:cotton"},
		{"farming:cotton", "farming:cotton"},
	}
})

-- Straw
minetest.register_craft({
	output = "farming:straw 3",
	recipe = {
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
	}
})

minetest.register_craft({
	output = "farming:straw_weathered 4",
	recipe = {
		{"farming:straw", "farming:straw"},
		{"farming:straw", "farming:straw"},
	}
})

minetest.register_craft({
	output = "farming:wheat 3",
	recipe = {
		{"farming:straw"},
	}
})
