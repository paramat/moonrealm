minetest.register_node("moonrealm:stone", {
	description = "Moon Stone",
	tiles = {"moonrealm_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:ironore", {
	description = "Iron Ore",
	tiles = {"moonrealm_stone.png^default_mineral_iron.png"},
	is_ground_content = false,
	groups = {cracky=2},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:copperore", {
	description = "Copper Ore",
	tiles = {"moonrealm_stone.png^default_mineral_copper.png"},
	is_ground_content = false,
	groups = {cracky=2},
	drop = "default:copper_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:goldore", {
	description = "Gold Ore",
	tiles = {"moonrealm_stone.png^default_mineral_gold.png"},
	is_ground_content = false,
	groups = {cracky=2},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:diamondore", {
	description = "Diamond Ore",
	tiles = {"moonrealm_stone.png^default_mineral_diamond.png"},
	is_ground_content = false,
	groups = {cracky=1},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:mese", {
	description = "Mese Block",
	tiles = {"moonrealm_mese.png"},
	paramtype = "light",
	light_source = 3,
	is_ground_content = false,
	groups = {cracky=1, level=2},
	drop = "default:mese",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:dust", {
	description = "Moon Dust",
	tiles = {"moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.05},
	}),
})

minetest.register_node("moonrealm:dustprint1", {
	description = "Moon Dust Footprint1",
	tiles = {"moonrealm_dustprint1.png", "moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	drop = "moonrealm:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.05},
	}),
})

minetest.register_node("moonrealm:dustprint2", {
	description = "Moon Dust Footprint2",
	tiles = {"moonrealm_dustprint2.png", "moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	drop = "moonrealm:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.05},
	}),
})

minetest.register_node("moonrealm:vacuum", {
	description = "Vacuum",
	drawtype = "airlike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drowning = 1,
})

minetest.register_node("moonrealm:air", {
	description = "Life Support Air",
	drawtype = "glasslike",
	tiles = {"moonrealm_air.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
})

minetest.register_node("moonrealm:airgen", {
	description = "Air Generator",
	tiles = {"moonrealm_airgen.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:vacuum" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:air"})
					minetest.get_meta({x=x+i,y=y+j,z=z+k}):set_int("spread", 16)
					print ("[moonrealm] Added moonrealm air node")
				end
			end
		end
		end
		end
		
	end
})

minetest.register_node("moonrealm:waterice", {
	description = "Water Ice",
	tiles = {"default_ice.png"},
	light_source = 1,
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:hlflowing", {
	description = "Flowing Hydroponics",
	inventory_image = minetest.inventorycube("moonrealm_hl.png"),
	drawtype = "flowingliquid",
	tiles = {"moonrealm_hl.png"},
	special_tiles = {
		{
			image="moonrealm_hlflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="moonrealm_hlflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = 224,
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "moonrealm:hlflowing",
	liquid_alternative_source = "moonrealm:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("moonrealm:hlsource", {
	description = "Hydroponic Source",
	inventory_image = minetest.inventorycube("moonrealm_hl.png"),
	drawtype = "liquid",
	tiles = {"moonrealm_hl.png"},
	alpha = 224,
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	pointable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "moonrealm:hlflowing",
	liquid_alternative_source = "moonrealm:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("moonrealm:soil", {
	description = "Moonsoil",
	tiles = {"moonrealm_soil.png"},
	is_ground_content = false,
	groups = {crumbly=3},
	drop = "moonrealm:dust",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("moonrealm:airlock", {
	description = "Airlock",
	tiles = {"moonrealm_airlock.png"},
	paramtype = "light",
	light_source = 14,
	is_ground_content = false,
	walkable = false,
	post_effect_color = {a=255, r=0, g=0, b=0},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {"default_obsidian_glass.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	groups = {cracky=3, oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:sapling", {
	description = "Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	groups = {snappy=2, dig_immediate=3, flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("moonrealm:appleleaf", {
	description = "Appletree leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"moonrealm:sapling"},rarity = 20,},
			{items = {"moonrealm:appleleaf"},}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("moonrealm:light", {
	description = "Light",
	tiles = {"moonrealm_light.png"},
	paramtype = "light",
	light_source = 14,
	is_ground_content = false,
	groups = {cracky=3, oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:stonebrick", {
	description = "Moon Stone Brick",
	tiles = {"moonrealm_stonebricktop.png", "moonrealm_stonebrickbot.png", "moonrealm_stonebrick.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:stoneslab", {
	description = "Moon Stone Slab",
	tiles = {"moonrealm_stonebricktop.png", "moonrealm_stonebrickbot.png", "moonrealm_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:stonestair", {
	description = "Moon Stone Stair",
	tiles = {"moonrealm_stonebricktop.png", "moonrealm_stonebrickbot.png", "moonrealm_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:shell", {
	description = "Spawn Shell",
	tiles = {"moonrealm_shell.png"},
	is_ground_content = false,
	groups = {cracky=3, oddly_breakable_by_hand=1},
	drop = "",
	sounds = default.node_sound_stone_defaults(),
})

-- Items

minetest.register_craftitem("moonrealm:spacesuit", {
	description = "Spacesuit",
	inventory_image = "moonrealm_spacesuit.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_craftitem("moonrealm:helmet", {
	description = "Mesetint Helmet",
	inventory_image = "moonrealm_helmet.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_craftitem("moonrealm:lifesupport", {
	description = "Life Support",
	inventory_image = "moonrealm_lifesupport.png",
	groups = {not_in_creative_inventory=1},
})

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
		{"moonrealm:leaves", "moonrealm:leaves", "moonrealm:leaves"},
		{"moonrealm:leaves", "moonrealm:waterice", "moonrealm:leaves"},
		{"moonrealm:leaves", "moonrealm:leaves", "moonrealm:leaves"},
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
	output = "moonrealm:sapling",
	recipe = {
		{"default:mese_crystal"},
		{"default:sapling"},
	}
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

