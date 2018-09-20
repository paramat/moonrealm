-- Space apple tree

function moonrealm_appletree(pos)
	local px = pos.x
	local py = pos.y
	local pz = pos.z
	local c_tree = minetest.get_content_id("default:tree")
	local c_apple = minetest.get_content_id("default:apple")
	local c_appleleaf = minetest.get_content_id("moonrealm:appleleaf")
	local c_soil = minetest.get_content_id("moonrealm:soil")
	local c_air = minetest.get_content_id("moonrealm:air")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x = px - 2, y = py - 1, z = pz - 2}
	local pos2 = {x = px + 2, y = py + 4, z = pz + 2}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()

	-- check for soil
	if data[area:index(px, py - 1, pz)] ~= c_soil then
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
		return
	end

	-- check for air
	for z = pos1.z, pos2.z do
	for y = py, pos2.y do
		local vi = area:index(pos1.x, y, z)
		for x = pos1.x, pos2.x do
			if data[vi] ~= c_air then
				vm:set_data(data)
				vm:write_to_map()
				vm:update_map()
				return
			end
			vi = vi + 1
		end
	end
	end

	for y = pos2.y, pos1.y, -1 do
		if y >= py + 2 then
			-- branches, leaves, apples underneath
			for z = pos1.z, pos2.z do
				local vi = area:index(pos1.x, y, z)
				local viu = area:index(pos1.x, y - 1, z)
				for x = pos1.x, pos2.x do
					if math.abs(x - px) + math.abs(z - pz) == 2 then
						data[vi] = c_tree
					elseif math.random() < 0.8 then
						data[vi] = c_appleleaf
						if math.random() < 0.08 then
							data[viu] = c_apple
						end
					end
					vi = vi + 1
					viu = viu + 1
				end
			end
		else
			-- trunk
			local vi = area:index(px, y, pz)
			data[vi] = c_tree
		end
	end
	
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()

	print ("[moonrealm] apple tree sapling grows")
end


minetest.register_abm({
	nodenames = {"moonrealm:sapling"},
	interval = 31,
	chance = 7,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_appletree(pos)
	end,
})


-- Vacuum or air flows into a dug hole

minetest.register_on_dignode(function(pos, oldnode, digger)
	local px = pos.x
	local py = pos.y
	local pz = pos.z
	local c_air = minetest.get_content_id("moonrealm:air")
	local c_vacuum = minetest.get_content_id("moonrealm:vacuum")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x = px - 1, y = py - 1, z = pz - 1}
	local pos2 = {x = px + 1, y = py + 1, z = pz + 1}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()

	local vip = area:index(px, py, pz)
	local vacuum_at_face = false

	for z = pos1.z, pos2.z do
	for y = pos1.y, pos2.y do
		local vi = area:index(pos1.x, y, z)
		for x = pos1.x, pos2.x do
			-- if face connected neighbour
			if math.abs(x - px) + math.abs(y - py) + math.abs(z - pz) == 1 then
				local nodid = data[vi]
				if nodid == c_air then
					-- air gets priority
					data[vip] = c_air
					vm:set_data(data)
					vm:write_to_map()
					vm:update_map()
					print ("[moonrealm] air flows into hole")
					return
				elseif nodid == c_vacuum then
					vacuum_at_face = true
				end
			end
			vi = vi + 1
		end
	end
	end

	-- no air detected, place vacuum if detected
	if vacuum_at_face then
		data[vip] = c_vacuum
		print ("[moonrealm] vacuum flows into hole")
	end

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end)


-- Vacuum spread ABM (through cube faces only)

minetest.register_abm({
	nodenames = {"moonrealm:air"},
	neighbors = {"moonrealm:vacuum"},
	interval = 4,
	chance = 64,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local px = pos.x
		local py = pos.y
		local pz = pos.z
		local c_air = minetest.get_content_id("moonrealm:air")
		local c_vacuum = minetest.get_content_id("moonrealm:vacuum")
	
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = px - 1, y = py - 1, z = pz - 1}
		local pos2 = {x = px + 1, y = py + 1, z = pz + 1}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		local vip = area:index(px, py, pz)

		for z = pos1.z, pos2.z do
		for y = pos1.y, pos2.y do
			local vi = area:index(pos1.x, y, z)
			for x = pos1.x, pos2.x do
				-- if face connected neighbour
				if math.abs(x - px) + math.abs(y - py) + math.abs(z - pz) == 1 then
					if data[vi] == c_vacuum then
						data[vip] = c_vacuum
						vm:set_data(data)
						vm:write_to_map()
						vm:update_map()
						print ("[moonrealm] vacuum spreads")
						return
					end
				end
				vi = vi + 1
			end
		end
		end

		-- no face connected vacuum detected
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})


-- Hydroponic saturation ABM

minetest.register_abm({
	nodenames = {"moonrealm:hlsource", "moonrealm:hlflowing"},
	neighbors = {"moonrealm:dust", "moonrealm:dustprint1", "moonrealm:dustprint2"},
	interval = 29,
	chance = 9,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local px = pos.x
		local py = pos.y
		local pz = pos.z
		local c_dust = minetest.get_content_id("moonrealm:dust")
		local c_dustp1 = minetest.get_content_id("moonrealm:dustprint1")
		local c_dustp2 = minetest.get_content_id("moonrealm:dustprint2")
		local c_soil = minetest.get_content_id("moonrealm:soil")
	
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = px - 2, y = py, z = pz - 2}
		local pos2 = {x = px + 2, y = py, z = pz + 2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		for z = pos1.z, pos2.z do
			local vi = area:index(pos1.x, py, z)
			for x = pos1.x, pos2.x do
				local nodid = data[vi]
				if nodid == c_dust or
				nodid == c_dustp1 or
				nodid == c_dustp2 then
					data[vi] = c_soil
				end
				vi = vi + 1
			end
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()

		print ("[moonrealm] hydroponic liquid saturates")
	end
})


-- Soil drying ABM

minetest.register_abm({
	nodenames = {"moonrealm:soil"},
	interval = 31,
	chance = 9,
	catch_up = false,
	action = function(pos, node)
		local px = pos.x
		local py = pos.y
		local pz = pos.z
		local c_dust = minetest.get_content_id("moonrealm:dust")
		local c_hlsource = minetest.get_content_id("moonrealm:hlsource")
		local c_hlflowing = minetest.get_content_id("moonrealm:hlflowing")
	
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = px - 2, y = py, z = pz - 2}
		local pos2 = {x = px + 2, y = py, z = pz + 2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		local vip = area:index(px, py, pz)

		for z = pos1.z, pos2.z do
			local vi = area:index(pos1.x, py, z)
			for x = pos1.x, pos2.x do
				local nodid = data[vi]
				if nodid == c_hlsource or nodid == c_hlflowing then
					vm:set_data(data)
					vm:write_to_map()
					vm:update_map()
					return
				end
				vi = vi + 1
			end
		end

		-- no hydroponic liquids detected
		data[vip] = c_dust

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()

		print ("[moonrealm] soil dries")
	end,
})


-- Spawn newplayer function

minetest.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	inv:add_item("main", "default:pick_diamond 4")
	inv:add_item("main", "default:shovel_diamond 4")
	inv:add_item("main", "default:axe_diamond 4")
	inv:add_item("main", "default:apple 64")
	inv:add_item("main", "moonrealm:photovoltaic 256")
	inv:add_item("main", "moonrealm:light 16")
	inv:add_item("main", "moonrealm:glass 16")
	inv:add_item("main", "moonrealm:storage 4")
	inv:add_item("main", "moonrealm:airlock 4")
	inv:add_item("main", "moonrealm:airgen 4")
	inv:add_item("main", "moonrealm:air_cylinder 4")
	inv:add_item("main", "moonrealm:hlsource 4")
	inv:add_item("main", "moonrealm:sapling 4")
	inv:add_item("main", "moonrealm:spacesuit 4")
	inv:add_item("main", "moonrealm:rover")
end)


-- Respawn player function

minetest.register_on_respawnplayer(function(player)
	local inv = player:get_inventory()
	inv:add_item("main", "default:pick_diamond")
	inv:add_item("main", "default:shovel_diamond 4")
	inv:add_item("main", "default:apple 16")
	inv:add_item("main", "moonrealm:spacesuit")

	return true
end)


-- Player positions, spacesuit texture status
-- Set gravity and skybox, override light

local player_pos = {}
local player_pos_previous = {}
local player_spacesuit = {} -- To avoid unnecessary resetting of character model

local skytextures = {
	"moonrealm_posy.png",
	"moonrealm_negy.png",
	"moonrealm_posz.png",
	"moonrealm_negz.png",	
	"moonrealm_negx.png",
	"moonrealm_posx.png",
}

minetest.register_on_joinplayer(function(player)
	player_pos_previous[player:get_player_name()] = {x = 0, y = 0, z = 0}

	if player:get_inventory():contains_item("main", "moonrealm:spacesuit") then
		player:set_properties({textures = {"moonrealm_space_character.png"}})
		player_spacesuit[player:get_player_name()] = true
		player:get_inventory():set_stack("hand", 1, "moonrealm:glove")
	else
		player:set_properties({textures = {"character.png"}})
		player_spacesuit[player:get_player_name()] = false
		player:get_inventory():set_stack("hand", 1, "")
	end

	player:set_physics_override(1, 0.6, 0.2) -- Speed, jump, gravity
	player:set_sky({r = 0, g = 0, b = 0, a = 0}, "skybox", skytextures, false)
	player:override_day_night_ratio(1)
end)

minetest.register_on_leaveplayer(function(player)
	player_pos_previous[player:get_player_name()] = nil
	player_spacesuit[player:get_player_name()] = nil
end)


-- Globalstep function

local FOOT = true

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do

		-- Footprints
		if FOOT and not default.player_attached[player:get_player_name()] and
				math.random() < 0.15 and
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

		-- Spacesuit. Restore breath, reset spacesuit texture and glove
		if math.random() < 0.04 then
			if player:get_inventory():contains_item("main", "moonrealm:spacesuit") then
				-- Spacesuit in inventory
				if player:get_breath() < 10 then
					player:set_breath(10)
				end
				if player_spacesuit[player:get_player_name()] == false then
					player:set_properties({textures = {"moonrealm_space_character.png"}})
					player_spacesuit[player:get_player_name()] = true
					player:get_inventory():set_stack("hand", 1, "moonrealm:glove")
				end
			else
				-- No spacesuit in inventory
				if player_spacesuit[player:get_player_name()] == true then
					player:set_properties({textures = {"character.png"}})
					player_spacesuit[player:get_player_name()] = false
					player:get_inventory():set_stack("hand", 1, "")
				end
			end
		end
	end
end)
