-- Crafting

minetest.register_craft({
	output = "moonrealm:airlock",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "moonrealm:airgen",
	recipe = {
		{"default:steel_ingot", "moonrealm:waterice", "default:steel_ingot"},
		{"moonrealm:waterice", "default:mese", "moonrealm:waterice"},
		{"default:steel_ingot", "moonrealm:waterice", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "default:water_source",
	recipe = {
		{"moonrealm:waterice"},
	},
})

minetest.register_craft({
	output = "moonrealm:hlsource",
	recipe = {
		{"moonrealm:appleleaf", "moonrealm:appleleaf", "moonrealm:appleleaf"},
		{"moonrealm:appleleaf", "moonrealm:waterice", "moonrealm:appleleaf"},
		{"moonrealm:appleleaf", "moonrealm:appleleaf", "moonrealm:appleleaf"},
	},
})

minetest.register_craft({
	output = "moonrealm:stonebrick 4",
	recipe = {
		{"moonrealm:stone", "moonrealm:stone"},
		{"moonrealm:stone", "moonrealm:stone"},
	}
})

minetest.register_craft({
	output = "default:furnace",
	recipe = {
		{"moonrealm:stone", "moonrealm:stone", "moonrealm:stone"},
		{"moonrealm:stone", "", "moonrealm:stone"},
		{"moonrealm:stone", "moonrealm:stone", "moonrealm:stone"},
	},
})

minetest.register_craft({
	output = "moonrealm:stoneslab 4",
	recipe = {
		{"moonrealm:stone", "moonrealm:stone"},
	}
})

minetest.register_craft({
	output = "moonrealm:stonestair 4",
	recipe = {
		{"moonrealm:stone", ""},
		{"moonrealm:stone", "moonrealm:stone"},
	}
})

minetest.register_craft({
	output = "moonrealm:helmet",
	recipe = {
		{"default:mese_crystal"},
		{"default:glass"},
		{"default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "moonrealm:lifesupport",
	recipe = {
		{"default:steel_ingot","default:steel_ingot" , "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "moonrealm:spacesuit",
	recipe = {
		{"wool:white", "moonrealm:helmet", "wool:white"},
		{"", "moonrealm:lifesupport", ""},
		{"wool:white", "", "wool:white"},
	}
})

minetest.register_craft({
	output = "moonrealm:light 8",
	recipe = {
		{"moonrealm:glass", "moonrealm:glass", "moonrealm:glass"},
		{"moonrealm:glass", "default:mese", "moonrealm:glass"},
		{"moonrealm:glass", "moonrealm:glass", "moonrealm:glass"},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "moonrealm:light 1",
	recipe = {"moonrealm:glass", "default:mese_crystal"},
})


-- Cooking

minetest.register_craft({
	type = "cooking",
	output = "moonrealm:glass",
	recipe = "moonrealm:dust",
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:mese_crystal",
	burntime = 50,
})
