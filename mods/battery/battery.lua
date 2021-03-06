
-- The battery item. Used to 'upgrade' battery array boxes so they can
-- store energy consistent with the number of batteries stored in them.
-- Also used as a craftitem in recipes.
minetest.register_craftitem("battery:battery", {
  description = "RE Battery\n\nReduces the power requirements of a machine, if used as an upgrade.\nStores energy when wired into battery box housings.",
  inventory_image = "technic_battery.png",
  stack_max = 1, -- May store meta in the future. Used as upgrade item.
})
minetest.register_alias("battery:re_battery", "battery:battery")

minetest.register_craft({
  output = 'battery:battery',
  recipe = {
    {'group:wood', 'default:copper_ingot', 'group:wood'},
    {'default:mese_crystal', 'moreores:tin_ingot',   'default:mese_crystal'},
    {'group:wood', 'default:copper_ingot', 'group:wood'},
  }
})
