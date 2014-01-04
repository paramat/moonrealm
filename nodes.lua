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

minetest.register_node("moonrealm:moondust", {
	description = "Moon Dust",
	tiles = {"moonrealm_moondust.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.05},
	}),
})

minetest.register_node("moonrealm:moonsand", {
	description = "Moonsand",
	tiles = {"moonrealm_moonsand.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("moonrealm:luxoff", {
	description = "MR Lux Ore Temporary",
	tiles = {"moonrealm_luxore.png"},
	light_source = 13,
	groups = {cracky=2},
	drop = "moonrealm:luxcrystal 9",
	sounds = default.node_sound_stone_defaults(),
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
	groups = {crumbly=3, falling_node=1},
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

minetest.register_node("moonrealm:sapling", {
	description = "MR Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("moonrealm:leaves", {
	description = "MR Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"moonrealm:sapling"},rarity = 20,},
			{items = {"moonrealm:leaves"},}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
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
	alpha = 192,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "moonrealm:lhcflowing",
	liquid_alternative_source = "moonrealm:lhcsource",
	liquid_viscosity = 1,
	post_effect_color = {a=128, r=140, g=19, b=0},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("moonrealm:lhcsource", {
	description = "Liquid Hydrocarbon Source",
	inventory_image = minetest.inventorycube("moonrealm_lhc.png"),
	drawtype = "liquid",
	tiles = {"moonrealm_lhc.png"},
	alpha = 192,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "moonrealm:lhcflowing",
	liquid_alternative_source = "moonrealm:lhcsource",
	liquid_viscosity = 1,
	post_effect_color = {a=128, r=140, g=19, b=0},
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
        {"moonrealm:leaves", "moonrealm:leaves", "moonrealm:leaves"},
        {"moonrealm:leaves", "moonrealm:waterice", "moonrealm:leaves"},
        {"moonrealm:leaves", "moonrealm:leaves", "moonrealm:leaves"},
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
	recipe = "moonrealm:moonsand",
})

-- Fuel

minetest.register_craft({
	type = "fuel",
	recipe = "moonrealm:luxcrystal",
	burntime = 50,
})