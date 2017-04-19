-- Clear stuff

minetest.clear_registered_biomes()
minetest.clear_registered_ores()
minetest.clear_registered_decorations()


-- Set mapgen settings

minetest.set_mapgen_setting("mg_name", "v7", true)
minetest.set_mapgen_setting("water_level", -15, true)
minetest.set_mapgen_setting("mg_flags", "caves,nodungeons,light,nodecorations", true)


-- Register biome

	minetest.register_biome({
		name = "moon",
		--node_dust = "",
		node_top = "moonrealm:dust",
		depth_top = 1,
		node_filler = "moonrealm:dust",
		depth_filler = 2,
		node_stone = "moonrealm:stone",
		--node_water_top = "",
		--depth_water_top = ,
		node_water = "moonrealm:dust",
		--node_river_water = "",
		--node_riverbed = "",
		--depth_riverbed = ,
		y_min = -31000,
		y_max = 31000,
		heat_point = 50,
		humidity_point = 50,
	})


-- Register ores

	-- Iron

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:ironore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 7 * 7 * 7,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = 0,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:ironore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 24 * 24 * 24,
		clust_num_ores = 27,
		clust_size     = 6,
		y_min          = -31000,
		y_max          = -64,
	})

	-- Copper

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:copperore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 12 * 12 * 12,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = -63,
		y_max          = -16,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:copperore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 9 * 9 * 9,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = -64,
	})

	-- Gold

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:goldore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 15 * 15 * 15,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = -255,
		y_max          = -64,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:goldore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 13 * 13 * 13,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = -256,
	})

	-- Mese block

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "default:mese",
		wherein        = "moonrealm:stone",
		clust_scarcity = 18 * 18 * 18,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = -255,
		y_max          = -64,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "default:mese",
		wherein        = "moonrealm:stone",
		clust_scarcity = 14 * 14 * 14,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = -256,
	})

	-- Diamond

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:diamondore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 17 * 17 * 17,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = -255,
		y_max          = -128,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:diamondore",
		wherein        = "moonrealm:stone",
		clust_scarcity = 15 * 15 * 15,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = -256,
	})

	-- Water ice

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:waterice",
		wherein        = "moonrealm:dust",
		clust_scarcity = 13 * 13 * 13,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = -31000,
		y_max          = 0,
	})


-- Localise data buffer

local dbuf = {}


-- On generated function
-- Convert air nodes to mod vacuum nodes

minetest.register_on_generated(function(minp, maxp, seed)
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z

	local c_air = minetest.CONTENT_AIR
	local c_vacuum = minetest.get_content_id("moonrealm:vacuum")

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data(dbuf)

	for z = z0, z1 do
	for y = y0 - 1, y1 + 1 do
		local vi = area:index(x0, y, z)
		for x = x0, x1 do
			if data[vi] == c_air then
				data[vi] = c_vacuum
			end
			vi = vi + 1
		end
	end
	end

	vm:set_data(data)
	vm:write_to_map(data)
end)
