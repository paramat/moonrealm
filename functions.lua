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

	for z = pos1.z, pos2.z do
	for y = pos1.y, pos2.y do
		local vi = area:index(pos1.x, y, z)
		for x = pos1.x, pos2.x do
			if not (x == px and y == py and z == pz) then
				if data[vi] == c_air then	
					data[vip] = c_air
					vm:set_data(data)
					vm:write_to_map()			
					print ("[moonrealm] air flows into hole")
					return
				end
			end
			vi = vi + 1
		end
	end
	end

	data[vip] = c_vacuum

	vm:set_data(data)
	vm:write_to_map()

	print ("[moonrealm] vacuum flows into hole")
end)


-- Air spread ABM

--[[minetest.register_abm({
	nodenames = {"moonrealm:air"},
	neighbors = {"moonrealm:vacuum"},
	interval = 13,
	chance = 9,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local spread = minetest.get_meta(pos):get_int("spread")
		if spread <= 0 then
			return
		end

		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_lsair = minetest.get_content_id("moonrealm:air")
		local c_vacuum = minetest.get_content_id("moonrealm:vacuum")
	
		local vm = minetest.get_voxel_manip()
		local pos1 = {x = x - 1, y = y - 1, z = z - 1}
		local pos2 = {x = x + 1, y = y + 1, z = z + 1}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local data = vm:get_data()

		for j = -1, 1 do
		for k = -1, 1 do
			local vi = area:index(x - 1, y + j, z + k)
			for i = -1, 1 do
				if not (i == 0 and j == 0 and k == 0) then
					local nodid = data[vi]
					if nodid == c_vacuum then
						data[vi] = c_lsair
						minetest.get_meta({x = x + i, y = y + j, z = z + k}):set_int("spread", (spread - 1))
						print ("[moonrealm] air spreads")
					end
				end
				vi = vi + 1
			end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
		--vm:update_map() not needed as no effect on lighting
	end
})--]]


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
				if not (x == px and z == pz) then
					local nodid = data[vi]
					if nodid == c_dust
					or nodid == c_dustp1
					or nodid == c_dustp2 then
						data[vi] = c_soil
						print ("[moonrealm] hydroponic liquid saturates")
					end
				end
				vi = vi + 1
			end
		end

		vm:set_data(data)
		vm:write_to_map()
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
					return
				end
				vi = vi + 1
			end
		end

		data[vip] = c_dust

		vm:set_data(data)
		vm:write_to_map()

		print ("[moonrealm] soil dries")
	end,
})


-- Space appletree from sapling ABM

minetest.register_abm({
	nodenames = {"moonrealm:sapling"},
	interval = 31,
	chance = 7,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_appletree(pos)
	end,
})
