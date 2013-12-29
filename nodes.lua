minetest.register_node("moonrealm:moonstone", {
	description = "Moon Stone",
	tiles = {"moonrealm_moonstone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:ironore", {
	description = "Iron Ore",
	tiles = {"moonrealm_moonstone.png^default_mineral_iron.png"},
	groups = {cracky=2},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moondust1", {
	description = "Moon Dust 1",
	tiles = {"moonrealm_moondust1.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.09},
	}),
})

minetest.register_node("moonrealm:moondust2", {
	description = "Moon Dust 2",
	tiles = {"moonrealm_moondust2.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.08},
	}),
})

minetest.register_node("moonrealm:moondust3", {
	description = "Moon Dust 3",
	tiles = {"moonrealm_moondust3.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:moondust4", {
	description = "Moon Dust 4",
	tiles = {"moonrealm_moondust4.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.06},
	}),
})

minetest.register_node("moonrealm:moondust5", {
	description = "Moon Dust 5",
	tiles = {"moonrealm_moondust5.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.05},
	}),
})

minetest.register_node("moonrealm:luxore", {
	description = "MR Lux Ore",
	tiles = {"moonrealm_luxore.png"},
	light_source = 13,
	groups = {cracky=2},
	drop = "moonrealm:luxcrystal 9",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:luxnode", {
	description = "MR Lux Node",
	tiles = {"moonrealm_luxnode.png"},
	light_source = 14,
	groups = {cracky=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:atmos", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	post_effect_color = {a=16, r=255, g=148, b=0},
})

minetest.register_node("moonrealm:air", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
})

minetest.register_node("moonrealm:airgen", {
	description = "Air Generator",
	tiles = {"moonrealm_airgen.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local env = minetest.env
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = env:get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:atmos" then
					env:add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:air"})
					print ("[moonrealm] Added air node")
				end
			end
		end
		end
		end
		
	end
})

minetest.register_node("moonrealm:waterice", {
	description = "Water Ice",
	tiles = {"moonrealm_waterice.png"},
	light_source = 1,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,melts=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:hlflowing", {
	description = "Flowing HL",
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
	description = "HL Source",
	inventory_image = minetest.inventorycube("moonrealm_hl.png"),
	drawtype = "liquid",
	tiles = {"moonrealm_hl.png"},
	alpha = 224,
	paramtype = "light",
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

minetest.register_node("moonrealm:moonsoil", {
	description = "Moon Soil",
	tiles = {"moonrealm_moonsoil.png"},
	groups = {crumbly=3},
	drop = "moonrealm:moondust5",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("moonrealm:airlock", {
	description = "Airlock",
	tiles = {"moonrealm_airlock.png"},
	light_source = 14,
	walkable = false,
	post_effect_color = {a=255, r=0, g=0, b=0},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moonstonebrick", {
	description = "Moonstone Brick",
	tiles = {"moonrealm_moonstonebricktop.png", "moonrealm_moonstonebrickbot.png", "moonrealm_moonstonebrick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moonglass", {
	description = "Moon Glass",
	drawtype = "glasslike",
	tiles = {"moonrealm_moonglass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:needles", {
	description = "MR Pine Needles",
	visual_scale = 1.3,
	tiles = {"moonrealm_needles.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"moonrealm:psapling"}, rarity = 20},
			{items = {"moonrealm:needles"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("moonrealm:psapling", {
	description = "MR Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"moonrealm_psapling.png"},
	inventory_image = "moonrealm_psapling.png",
	wield_image = "moonrealm_psapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})


minetest.register_node("moonrealm:moonstoneslab", {
	description = "Moonstone Slab",
	tiles = {"moonrealm_moonstonebricktop.png", "moonrealm_moonstonebrickbot.png", "moonrealm_moonstonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
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

minetest.register_node("moonrealm:moonstonestair", {
	description = "MR Moonstone Stair",
	tiles = {"moonrealm_moonstonebricktop.png", "moonrealm_moonstonebrickbot.png", "moonrealm_moonstonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
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

minetest.register_node("moonrealm:lhcflowing", {
	description = "Flowing Liquid Hydrocarbons",
	inventory_image = minetest.inventorycube("moonrealm_lhc.png"),
	drawtype = "flowingliquid",
	tiles = {"moonrealm_lhc.png"},
	special_tiles = {
		{
			image="moonrealm_lhcflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="moonrealm_lhcflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = LHCALP,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "moonrealm:lhcflowing",
	liquid_alternative_source = "moonrealm:lhcsource",
	liquid_viscosity = 1,
	post_effect_color = {a=192, r=140, g=19, b=0},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("moonrealm:lhcsource", {
	description = "Liquid Hydrocarbon Source",
	inventory_image = minetest.inventorycube("moonrealm_lhc.png"),
	drawtype = "liquid",
	tiles = {"moonrealm_lhc.png"},
	alpha = LHCALP,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "moonrealm:lhcflowing",
	liquid_alternative_source = "moonrealm:lhcsource",
	liquid_viscosity = 1,
	post_effect_color = {a=192, r=140, g=19, b=0},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

-- Item

minetest.register_craftitem("moonrealm:luxcrystal", {
	description = "MR Lux Crystal",
	inventory_image = "moonrealm_luxcrystal.png",
})

-- Crafting

minetest.register_craft({
    output = "moonrealm:luxnode",
    recipe = {
        {"moonrealm:luxcrystal", "moonrealm:luxcrystal", "moonrealm:luxcrystal"},
        {"moonrealm:luxcrystal", "moonrealm:luxcrystal", "moonrealm:luxcrystal"},
        {"moonrealm:luxcrystal", "moonrealm:luxcrystal", "moonrealm:luxcrystal"},
    },
})

minetest.register_craft({
    output = "moonrealm:airgen",
    recipe = {
        {"default:steel_ingot", "moonrealm:waterice", "default:steel_ingot"},
        {"moonrealm:waterice", "moonrealm:luxnode", "moonrealm:waterice"},
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
        {"moonrealm:needles", "moonrealm:needles", "moonrealm:needles"},
        {"moonrealm:needles", "moonrealm:waterice", "moonrealm:needles"},
        {"moonrealm:needles", "moonrealm:needles", "moonrealm:needles"},
    },
})

minetest.register_craft({
	output = "moonrealm:moonstonebrick 4",
	recipe = {
		{"moonrealm:moonstone", "moonrealm:moonstone"},
		{"moonrealm:moonstone", "moonrealm:moonstone"},
	}
})

minetest.register_craft({
	output = "moonrealm:moonstonestair 4",
	recipe = {
		{"moonrealm:moonstone", ""},
		{"moonrealm:moonstone", "moonrealm:moonstone"},
	}
})

minetest.register_craft({
    output = "moonrealm:airlock",
    recipe = {
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"default:steel_ingot", "moonrealm:luxnode", "default:steel_ingot"},
        {"default:steel_ingot", "", "default:steel_ingot"},
    },
})

minetest.register_craft({
    output = "default:furnace",
    recipe = {
        {"moonrealm:moonstone", "moonrealm:moonstone", "moonrealm:moonstone"},
        {"moonrealm:moonstone", "", "moonrealm:moonstone"},
        {"moonrealm:moonstone", "moonrealm:moonstone", "moonrealm:moonstone"},
    },
})

minetest.register_craft({
	output = "moonrealm:moonstoneslab 4",
	recipe = {
		{"moonrealm:moonstone", "moonrealm:moonstone"},
	}
})

-- Cooking

minetest.register_craft({
	type = "cooking",
	output = "moonrealm:moonglass",
	recipe = "moonrealm:moondust1",
})

-- Fuel

minetest.register_craft({
	type = "fuel",
	recipe = "moonrealm:luxcrystal",
	burntime = 50,
})