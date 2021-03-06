-- Nodes

minetest.register_node("moonrealm:stone", {
	description = "Moon Stone",
	tiles = {"moonrealm_stone.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:ironore", {
	description = "Iron Ore",
	tiles = {"moonrealm_stone.png^default_mineral_iron.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:copperore", {
	description = "Copper Ore",
	tiles = {"moonrealm_stone.png^default_mineral_copper.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	drop = "default:copper_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:goldore", {
	description = "Gold Ore",
	tiles = {"moonrealm_stone.png^default_mineral_gold.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:diamondore", {
	description = "Diamond Ore",
	tiles = {"moonrealm_stone.png^default_mineral_diamond.png"},
	is_ground_content = false,
	groups = {cracky = 1},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:dust", {
	description = "Moon Dust",
	tiles = {"moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	sounds = default.node_sound_sand_defaults({
		footstep = {name = "default_sand_footstep", gain = 0.05},
	}),
})

minetest.register_node("moonrealm:dustprint1", {
	description = "Moon Dust Footprint 1",
	tiles = {"moonrealm_dustprint1.png", "moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	drop = "moonrealm:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name = "default_sand_footstep", gain = 0.05},
	}),
})

minetest.register_node("moonrealm:dustprint2", {
	description = "Moon Dust Footprint 2",
	tiles = {"moonrealm_dustprint2.png", "moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	drop = "moonrealm:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name = "default_sand_footstep", gain = 0.05},
	}),
})

minetest.register_node("moonrealm:dusttrack", {
	description = "Moon Rover Track",
	tiles = {"moonrealm_dusttrack.png", "moonrealm_dust.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	drop = "moonrealm:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name = "default_sand_footstep", gain = 0.05},
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
	floodable = true,
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
	floodable = true,
})

minetest.register_node("moonrealm:airgen", {
	description = "Air Generator",
	tiles = {"moonrealm_airgen.png"},
	is_ground_content = false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local px = pos.x
		local py = pos.y
		local pz = pos.z

		local c_air = minetest.get_content_id("moonrealm:air")
		local c_vacuum = minetest.get_content_id("moonrealm:vacuum")
		local c_airgen_empty = minetest.get_content_id("moonrealm:airgen_empty")

		local vm = minetest.get_voxel_manip()
		local pos1 = {x = px - 16, y = py - 16, z = pz - 16}
		local pos2 = {x = px + 16, y = py + 17, z = pz + 16}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()
		local viystride = emax.x - emin.x + 1

		-- replace vaccum with air in all but top layer
		for z = pos1.z, pos2.z do
		for y = pos1.y, pos2.y - 1 do
			local vi = area:index(pos1.x, y, z)
			for x = pos1.x, pos2.x do
				if data[vi] == c_vacuum then
					data[vi] = c_air
				end
				vi = vi + 1
			end
		end
		end
		
		-- spread vacuum down through columns to remove most air
		for z = pos1.z, pos2.z do
		for x = pos1.x, pos2.x do
			local vi = area:index(x, pos2.y, z)
			-- if vacuum at column top
			if data[vi] == c_vacuum then
				vi = vi - viystride
				for y = pos2.y - 1, pos1.y, -1 do
					if data[vi] == c_air then
						data[vi] = c_vacuum
					else
						break
					end
					vi = vi - viystride
				end
			end
		end
		end
		
		-- replace with empty airgen
		data[area:index(px, py, pz)] = c_airgen_empty

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()

		print ("[moonrealm] air generated")
	end
})

minetest.register_node("moonrealm:airgen_empty", {
	description = "Air Generator Empty",
	tiles = {"moonrealm_airgen_empty.png"},
	is_ground_content = false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:waterice", {
	description = "Water Ice",
	tiles = {"default_ice.png"},
	light_source = 1,
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	groups = {cracky = 3},
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
			backface_culling = false,
			animation = {type = "vertical_frames",
				aspect_w = 16, aspect_h = 16, length = 2}
		},
		{
			image = "moonrealm_hlflowing_animated.png",
			backface_culling = true,
			animation = {type = "vertical_frames",
				aspect_w = 16, aspect_h = 16, length = 2}
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
	post_effect_color = {a = 224, r = 115, g = 55, b = 24},
	groups = {water = 3, liquid = 3, puts_out_fire = 1,
		not_in_creative_inventory = 1},
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
	post_effect_color = {a = 224, r = 115, g = 55, b = 24},
	groups = {water = 3, liquid = 3, puts_out_fire = 1},
})

minetest.register_node("moonrealm:soil", {
	description = "Moonsoil",
	tiles = {"moonrealm_soil.png"},
	is_ground_content = false,
	groups = {crumbly = 3, soil = 1},
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
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {"default_obsidian_glass.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	groups = {cracky = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:sapling", {
	description = "Sapling",
	drawtype = "plantlike",
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("moonrealm:appleleaf", {
	description = "Appletree leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			{items = {"moonrealm:sapling"}, rarity = 16,},
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
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:stonebrick", {
	description = "Moon Stone Brick",
	tiles = {"moonrealm_stonebricktop.png", "moonrealm_stonebrickbot.png",
		"moonrealm_stonebrick.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:stoneslab", {
	description = "Moon Stone Slab",
	tiles = {"moonrealm_stonebricktop.png", "moonrealm_stonebrickbot.png",
		"moonrealm_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
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
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:stonestair", {
	description = "Moon Stone Stair",
	tiles = {"moonrealm_stonebricktop.png", "moonrealm_stonebrickbot.png",
		"moonrealm_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 3},
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

minetest.register_node("moonrealm:photovoltaic", {
	description = "Photovoltaic Panel",
	tiles = {"moonrealm_photovoltaic_top.png",
		"moonrealm_photovoltaic_base.png",
		"moonrealm_photovoltaic_side.png"},
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
		},
	},
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:air_cylinder", {
	description = "Air Cylinder",
	drawtype = "plantlike",
	tiles = {"moonrealm_air_cylinder.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
})


-- Storage

local chest_formspec =
	"size[8,9]" ..
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"list[current_name;main;0,0.3;8,4;]" ..
	"list[current_player;main;0,4.85;8,1;]" ..
	"list[current_player;main;0,6.08;8,3;8]" ..
	"listring[current_name;main]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0,4.85)

minetest.register_node("moonrealm:storage", {
	description = "Storage",
	tiles = {"moonrealm_storage_side.png", "moonrealm_storage_side.png",
		"moonrealm_storage_side.png", "moonrealm_storage_side.png",
		"moonrealm_storage_side.png", "moonrealm_storage_front.png"},
	paramtype2 = "facedir",
	groups = {dig_immediate = 3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", chest_formspec)
		meta:set_string("infotext", "Storage")
		local inv = meta:get_inventory()
		inv:set_size("main", 8 * 4)
	end,

	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in storage at " .. minetest.pos_to_string(pos))
	end,

    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to storage at " .. minetest.pos_to_string(pos))
	end,

    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes " .. stack:get_name() ..
			" from storage at " .. minetest.pos_to_string(pos))
	end,

	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "main", drops)
		drops[#drops + 1] = "moonrealm:storage"
		minetest.remove_node(pos)
		return drops
	end,
})


-- Items

minetest.register_craftitem("moonrealm:spacesuit", {
	description = "Spacesuit",
	inventory_image = "moonrealm_spacesuit.png",
})

minetest.register_craftitem("moonrealm:helmet", {
	description = "Mesetint Helmet",
	inventory_image = "moonrealm_helmet.png",
	groups = {not_in_creative_inventory = 1},
})

minetest.register_craftitem("moonrealm:lifesupport", {
	description = "Life Support",
	inventory_image = "moonrealm_lifesupport.png",
	groups = {not_in_creative_inventory = 1},
})


-- Glove

minetest.register_item("moonrealm:glove", {
    type = "none",
    wield_image = "moonrealm_glove.png",
    wield_scale = {x = 1, y = 1, z = 2.5},
	stack_max = 1,
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times = {[2] = 3.00, [3] = 0.70}, uses = 0, maxlevel = 1},
            snappy = {times = {[3] = 0.40}, uses = 0, maxlevel = 1},
            oddly_breakable_by_hand =
				{times = {[1] = 3.50, [2] = 2.00, [3] = 0.70}, uses = 0}
        },
        damage_groups = {fleshy = 1},
    }
})
