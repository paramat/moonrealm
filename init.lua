-- Parameters

local YMIN = -8000 -- Approx lower limit
local GRADCEN = 1 -- Gradient centre / terrain centre average level
local YMAX = 8000 -- Approx upper limit
local XMIN = -8000 -- Approx horizontal limits
local XMAX = 8000
local ZMIN = -8000
local ZMAX = 8000

local CENAMP = 64 -- Grad centre amplitude, terrain centre is varied by this
local HIGRAD = 128 -- Surface generating noise gradient above gradcen, controls depth of upper terrain
local LOGRAD = 128 -- Surface generating noise gradient below gradcen, controls depth of lower terrain
local HEXP = 0.5 -- Noise offset exponent above gradcen, 1 = normal 3D perlin terrain
local LEXP = 2 -- Noise offset exponent below gradcen
local STOT = 0.04 -- Stone density threshold, depth of dust

local ICECHA = 1 / (13 * 13 * 13) -- Ice chance per dust node at terrain centre, decreases with altitude
local ICEGRAD = 128 -- Ice gradient, vertical distance for no ice
local ORECHA = 7 * 7 * 7 -- Ore 1/x chance per stone node
local TFIS = 0.01 -- Fissure threshold. Controls size of fissures
local FOOT = true -- Footprints in dust

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x = 512, y = 512, z = 512},
	seed = 58588900033,
	octaves = 6,
	persist = 0.67
}

-- 3D noise for alt terrain, 414 / 256 = golden ratio

local np_terralt = {
	offset = 0,
	scale = 1,
	spread = {x = 414, y = 414, z = 414},
	seed = 13331930910,
	octaves = 6,
	persist = 0.67
}

-- 2D noise for smooth terrain

local np_smooth = {
	offset = 0,
	scale = 1,
	spread = {x = 828, y = 828, z = 828},
	seed = 113,
	octaves = 4,
	persist = 0.4
}

-- 3D noise for fissures

local np_fissure = {
	offset = 0,
	scale = 1,
	spread = {x = 256, y = 256, z = 256},
	seed = 8181112,
	octaves = 5,
	persist = 0.5
}


-- 3D noise for faults

local np_fault = {
	offset = 0,
	scale = 1,
	spread = {x = 414, y = 828, z = 414},
	seed = 14440002,
	octaves = 4,
	persist = 0.5
}

-- 2D noise for terrain centre

local np_gradcen = {
	offset = 0,
	scale = 1,
	spread = {x = 1024, y = 1024, z = 1024},
	seed = 9344,
	octaves = 4,
	persist = 0.4
}

-- 2D noise for terrain blend

local np_terblen = {
	offset = 0,
	scale = 1,
	spread = {x = 2048, y = 2048, z = 2048},
	seed = -13002,
	octaves = 3,
	persist = 0.4
}


-- Do files

dofile(minetest.get_modpath("moonrealm") .. "/nodes.lua")
dofile(minetest.get_modpath("moonrealm") .. "/functions.lua")


-- Set mapgen parameters

minetest.set_mapgen_params({mgname = "singlenode", water_level = -32000})


-- Player positions, spacesuit texture status

local player_pos = {}
local player_pos_previous = {}
local player_spacesuit = {}

minetest.register_on_joinplayer(function(player)
	player_pos_previous[player:get_player_name()] = {x = 0, y = 0, z = 0}

	if player:get_inventory():contains_item("main", "moonrealm:spacesuit") then
		player:set_properties({textures = {"moonrealm_space_character.png"}})
		player_spacesuit[player:get_player_name()] = true
	else
		player:set_properties({textures = {"moonrealm_character.png"}})
		player_spacesuit[player:get_player_name()] = false
	end
end)

minetest.register_on_leaveplayer(function(player)
	player_pos_previous[player:get_player_name()] = nil
	player_spacesuit[player:get_player_name()] = nil
end)


-- Globalstep function

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		if FOOT and math.random() < 0.15 and -- footprints
				player_pos_previous[player:get_player_name()] ~= nil then
			local pos = player:getpos()
			player_pos[player:get_player_name()] = {
				x = math.floor(pos.x + 0.5),
				y = math.floor(pos.y + 0.2),
				z = math.floor(pos.z + 0.5)
			}
			local p_ground = {
				x = math.floor(pos.x + 0.5),
				y = math.floor(pos.y + 0.4),
				z = math.floor(pos.z + 0.5)
			}
			local n_ground  = minetest.get_node(p_ground).name
			local p_groundpl = {
				x = math.floor(pos.x + 0.5),
				y = math.floor(pos.y - 0.5),
				z = math.floor(pos.z + 0.5)
			}
			if player_pos[player:get_player_name()].x ~=
					player_pos_previous[player:get_player_name()].x or
					player_pos[player:get_player_name()].y <
					player_pos_previous[player:get_player_name()].y or
					player_pos[player:get_player_name()].z ~=
					player_pos_previous[player:get_player_name()].z then
				if n_ground == "moonrealm:dust" then
					if math.random() < 0.5 then
						minetest.add_node(
							p_groundpl,
							{name = "moonrealm:dustprint1"}
						)
					else
						minetest.add_node(
							p_groundpl,
							{name = "moonrealm:dustprint2"}
						)
					end
				end
			end
			player_pos_previous[player:get_player_name()] = {
				x = player_pos[player:get_player_name()].x,
				y = player_pos[player:get_player_name()].y,
				z = player_pos[player:get_player_name()].z
			}
		end

		if math.random() < 0.04 then -- spacesuit restores breath, reset spacesuit texture
			if player:get_inventory():contains_item("main", "moonrealm:spacesuit") then
				if player:get_breath() < 10 then
					player:set_breath(10)
				end

				if player_spacesuit[player:get_player_name()] == false then -- if no spacesuit texture, add
					player:set_properties({textures = {"moonrealm_space_character.png"}})
					player_spacesuit[player:get_player_name()] = true
				end
			else -- no spacesuit in inventory
				if player_spacesuit[player:get_player_name()] == true then -- if spacesuit texture, remove
					player:set_properties({textures = {"moonrealm_character.png"}})
					player_spacesuit[player:get_player_name()] = false
				end
			end
		end

		if math.random() < 0.01 then -- set gravity, skybox and override light
			local pos = player:getpos()
			if pos.y > YMIN and pos.y < YMAX then -- entering realm
				player:set_physics_override(1, 0.6, 0.2) -- speed, jump, gravity
				local skytextures = {
					"moonrealm_posy.png",
					"moonrealm_negy.png",
					"moonrealm_posz.png",
					"moonrealm_negz.png",	
					"moonrealm_negx.png",
					"moonrealm_posx.png",
				}
				player:set_sky({r = 0, g = 0, b = 0, a = 0}, "skybox", skytextures)
				player:override_day_night_ratio(1)
			else -- on leaving realm
				player:set_physics_override(1, 1, 1)
				player:set_sky({}, "regular", {})
				player:override_day_night_ratio(nil)
			end
		end
	end
end)


-- Initialize noise objects to nil

local nobj_terrain = nil
local nobj_terralt = nil
local nobj_fissure = nil
local nobj_fault = nil

local nobj_smooth = nil
local nobj_terblen = nil
local nobj_gradcen = nil


-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.x < XMIN or maxp.x > XMAX or
	minp.y < YMIN or maxp.y > YMAX or
	minp.z < ZMIN or maxp.z > ZMAX then
		return
	end
	
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()
	
	local c_air          = minetest.get_content_id("air")
	local c_ignore       = minetest.get_content_id("ignore")
	local c_mese         = minetest.get_content_id("moonrealm:mese")
	local c_mrironore    = minetest.get_content_id("moonrealm:ironore")
	local c_mrcopperore  = minetest.get_content_id("moonrealm:copperore")
	local c_mrgoldore    = minetest.get_content_id("moonrealm:goldore")
	local c_mrdiamondore = minetest.get_content_id("moonrealm:diamondore")
	local c_mrstone      = minetest.get_content_id("moonrealm:stone")
	local c_waterice     = minetest.get_content_id("moonrealm:waterice")
	local c_dust         = minetest.get_content_id("moonrealm:dust")
	local c_vacuum       = minetest.get_content_id("moonrealm:vacuum")
	
	local chulens = x1 - x0 + 1
	local pmaplens2d = {x = chulens, y = chulens, z = 1}
	local pmaplens3d = {x = chulens, y = chulens, z = chulens}
	local minpos2d = {x = x0, y = z0}
	local minpos3d = {x = x0, y = y0, z = z0}
	
	nobj_terrain = nobj_terrain or minetest.get_perlin_map(np_terrain, pmaplens3d)
	nobj_terralt = nobj_terralt or minetest.get_perlin_map(np_terralt, pmaplens3d)
	nobj_fissure = nobj_fissure or minetest.get_perlin_map(np_fissure, pmaplens3d)
	nobj_fault   = nobj_fault   or minetest.get_perlin_map(np_fault, pmaplens3d)
	
	nobj_smooth  = nobj_smooth  or minetest.get_perlin_map(np_smooth, pmaplens2d)
	nobj_terblen = nobj_terblen or minetest.get_perlin_map(np_terblen, pmaplens2d)
	nobj_gradcen = nobj_gradcen or minetest.get_perlin_map(np_gradcen, pmaplens2d)
	
	local nvals_terrain = nobj_terrain:get3dMap_flat(minpos3d)
	local nvals_terralt = nobj_terralt:get3dMap_flat(minpos3d)
	local nvals_fissure = nobj_fissure:get3dMap_flat(minpos3d)
	local nvals_fault   = nobj_fault  :get3dMap_flat(minpos3d)
	
	local nvals_smooth  = nobj_smooth :get2dMap_flat(minpos2d)
	local nvals_terblen = nobj_terblen:get2dMap_flat(minpos2d)
	local nvals_gradcen = nobj_gradcen:get2dMap_flat(minpos2d)
	
	local ni3d = 1
	local ni2d = 1
	local stable = {}

	for z = z0, z1 do
		local viu = area:index(x0, y0 - 1, z)

		for x = x0, x1 do
			local si = x - x0 + 1
			local nodid = data[viu]
			if nodid == c_vacuum then
				stable[si] = false
			else
				stable[si] = true
			end
			viu = viu + 1
		end

		for y = y0, y1 do
			local vi = area:index(x0, y, z) -- LVM index for first node in x row
			local icecha = ICECHA * (1 + (GRADCEN - y) / ICEGRAD)

			for x = x0, x1 do
				local nodid = data[vi]
				local empty = (nodid == c_air or nodid == c_ignore)
				local grad
				local density
				local si = x - x0 + 1
				local terblen = math.max(math.min(
					math.abs(nvals_terblen[ni2d]) * 4, 1.5), 0.5) - 0.5
				local gradcen = GRADCEN + nvals_gradcen[ni2d] * CENAMP

				if y > gradcen then
					grad = -((y - gradcen) / HIGRAD) ^ HEXP
				else
					grad = ((gradcen - y) / LOGRAD) ^ LEXP
				end

				if nvals_fault[ni3d] >= 0 then
					density = (nvals_terrain[ni3d] +
						nvals_terralt[ni3d]) / 2 * (1 - terblen) +
						nvals_smooth[ni2d] * terblen + grad
				else	
					density = (nvals_terrain[ni3d] -
						nvals_terralt[ni3d]) / 2 * (1 - terblen) -
						nvals_smooth[ni2d] * terblen + grad
				end

				if density > 0 and empty then -- if terrain and node empty
					local nofis = false
					if math.abs(nvals_fissure[ni3d]) > TFIS then
						nofis = true
					end
					if density >= STOT and nofis then -- stone, ores 
						if math.random(ORECHA) == 2 then
							local osel = math.random(25)
							if osel == 25 then
								data[vi] = c_mese
							elseif osel >= 22 then
								data[vi] = c_mrdiamondore
							elseif osel >= 19 then
								data[vi] = c_mrgoldore
							elseif osel >= 10 then
								data[vi] = c_mrcopperore
							else
								data[vi] = c_mrironore
							end
						else
							data[vi] = c_mrstone
						end
						stable[si] = true
					elseif density < STOT then -- fine materials
						if nofis and stable[si] then
							if math.random() < icecha then
								data[vi] = c_waterice
							else
								data[vi] = c_dust
							end
						else -- fissure
							data[vi] = c_vacuum
							stable[si] = false
						end
					else -- fissure or unstable missing node
						data[vi] = c_vacuum
						stable[si] = false
					end
				else -- vacuum or spawn egg
					if empty then
						data[vi] = c_vacuum
					end
					stable[si] = false
				end

				ni3d = ni3d + 1
				ni2d = ni2d + 1
				vi = vi + 1
			end
			ni2d = ni2d - chulens
		end
		ni2d = ni2d + chulens
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0}) -- not "nolight" because mapgen does not run in all chunks
	vm:calc_lighting()
	vm:write_to_map(data)

	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[moonrealm] " .. chugent .. " ms")
end)


-- Spawn point, localise here to make available to all spawn functions

local xsp, ysp, zsp

-- Find spawn function, dependant on chunk size of 80 nodes (TODO allow any chunksize)

local function moonrealm_find_spawn()
	local PSCA = 16
	xsp = nil
	ysp = nil
	zsp = nil

	local nobj_terrain = nil
	local nobj_terralt = nil
	local nobj_fault = nil

	local nobj_smooth = nil
	local nobj_terblen = nil
	local nobj_gradcen = nil

	for chunk = 1, 64 do
		print ("[moonrealm] searching for spawn " .. chunk)

		local x0 = 80 * math.random(-PSCA, PSCA) - 32
		local z0 = 80 * math.random(-PSCA, PSCA) - 32
		local y0 = 80 * math.floor((GRADCEN + 32) / 80) - 32
		local x1 = x0 + 79
		local z1 = z0 + 79
		local y1 = y0 + 79
	
		local chulens = x1 - x0 + 1
		local pmaplens2d = {x = chulens, y = chulens, z = 1}
		local pmaplens3d = {x = chulens, y = chulens, z = chulens}
		local minpos2d = {x = x0, y = z0}
		local minpos3d = {x = x0, y = y0, z = z0}
	
		nobj_terrain = nobj_terrain or minetest.get_perlin_map(np_terrain, pmaplens3d)
		nobj_terralt = nobj_terralt or minetest.get_perlin_map(np_terralt, pmaplens3d)
		nobj_fault   = nobj_fault   or minetest.get_perlin_map(np_fault, pmaplens3d)
	
		nobj_smooth  = nobj_smooth  or minetest.get_perlin_map(np_smooth, pmaplens2d)
		nobj_terblen = nobj_terblen or minetest.get_perlin_map(np_terblen, pmaplens2d)
		nobj_gradcen = nobj_gradcen or minetest.get_perlin_map(np_gradcen, pmaplens2d)
	
		local nvals_terrain = nobj_terrain:get3dMap_flat(minpos3d)
		local nvals_terralt = nobj_terralt:get3dMap_flat(minpos3d)
		local nvals_fault   = nobj_fault  :get3dMap_flat(minpos3d)
	
		local nvals_smooth  = nobj_smooth :get2dMap_flat(minpos2d)
		local nvals_terblen = nobj_terblen:get2dMap_flat(minpos2d)
		local nvals_gradcen = nobj_gradcen:get2dMap_flat(minpos2d)
	
		local ni3d = 1
		local ni2d = 1
		local stable = {}

		for z = z0, z1 do
			for y = y0, y1 do
				for x = x0, x1 do
					local si = x - x0 + 1
					local grad
					local density
					local terblen = math.max(math.min(
						math.abs(nvals_terblen[ni2d]) * 4, 1.5), 0.5) - 0.5
					local gradcen = GRADCEN + nvals_gradcen[ni2d] * CENAMP

					if y > gradcen then
						grad = -((y - gradcen) / HIGRAD) ^ HEXP
					else
						grad = ((gradcen - y) / LOGRAD) ^ LEXP
					end

					if nvals_fault[ni3d] >= 0 then
						density = (nvals_terrain[ni3d] +
							nvals_terralt[ni3d]) / 2 * (1 - terblen) +
							nvals_smooth[ni2d] * terblen + grad
					else	
						density = (nvals_terrain[ni3d] -
							nvals_terralt[ni3d]) / 2 * (1 - terblen) -
							nvals_smooth[ni2d] * terblen + grad
					end

					if density >= STOT then
						stable[si] = true
					-- just above ground, smooth terrain, away from faults
					elseif stable[si] and density < 0 and terblen == 1 and
							math.abs(nvals_fault[ni3d]) > 0.5 then
						ysp = y + 3
						xsp = x
						zsp = z
						break
					end

					ni3d = ni3d + 1
					ni2d = ni2d + 1
				end
				if ysp then
					break
				end
				ni2d = ni2d - chulens
			end
			if ysp then
				break
			end
			ni2d = ni2d + chulens
		end
		if ysp then
			break
		end
	end
end


-- Spawn newplayer function

minetest.register_on_newplayer(function(player)
	moonrealm_find_spawn()

	print ("[moonrealm] spawn player (" .. xsp .. " " .. ysp .. " " .. zsp .. ")")
	player:setpos({x = xsp, y = ysp, z = zsp})

	local inv = player:get_inventory()
	inv:add_item("main", "moonrealm:spacesuit 2")
	inv:add_item("main", "moonrealm:sapling 4")
	inv:add_item("main", "moonrealm:airlock 4")
	inv:add_item("main", "moonrealm:airgen 4")
	inv:add_item("main", "moonrealm:hlsource 4")
	inv:add_item("main", "default:apple 64")
	inv:add_item("main", "default:pick_diamond 4")
	inv:add_item("main", "default:axe_diamond 4")
	inv:add_item("main", "default:shovel_diamond 4")

	-- create spawn egg
	local vm = minetest.get_voxel_manip()
	local pos1 = {x = xsp - 3, y = ysp - 3, z = zsp - 3}
	local pos2 = {x = xsp + 3, y = ysp + 6, z = zsp + 3}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local c_shell = minetest.get_content_id("moonrealm:shell")
	local c_light = minetest.get_content_id("moonrealm:light")
	local c_lsair = minetest.get_content_id("moonrealm:air")

	for i = -3, 3 do
	for j = -3, 6 do
	for k = -3, 3 do
		local vi = area:index(xsp + i, ysp + j, zsp + k)
		local rad
		if j <= 0 then
			rad = math.sqrt(i ^ 2 + j ^ 2 + k ^ 2)
		else
			rad = math.sqrt(i ^ 2 + j ^ 2 * 0.3 + k ^ 2)
		end
		if rad <= 3.5 then
			if rad >= 2.5 then
				data[vi] = c_shell
			elseif rad >= 1.5 then
				data[vi] = c_light
			else
				data[vi] = c_lsair
			end
		end
	end
	end
	end

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end)


-- Respawn player function

minetest.register_on_respawnplayer(function(player)
	moonrealm_find_spawn()

	print ("[moonrealm] respawn player (" .. xsp .. " " .. ysp .. " " .. zsp .. ")")
	player:setpos({x = xsp, y = ysp, z = zsp})

	local inv = player:get_inventory()
	inv:add_item("main", "moonrealm:spacesuit")
	inv:add_item("main", "default:pick_diamond")
	inv:add_item("main", "default:apple 16")

	return true
end)
