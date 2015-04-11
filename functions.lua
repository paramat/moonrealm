-- Space apple tree

function moonrealm_appletree(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	local top = 3 + math.random(2)
	local c_tree = minetest.get_content_id("default:tree")
	local c_apple = minetest.get_content_id("default:apple")
	local c_appleleaf = minetest.get_content_id("moonrealm:appleleaf")
	local c_soil = minetest.get_content_id("moonrealm:soil")
	local c_lsair = minetest.get_content_id("moonrealm:air")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x=x-2, y=y-2, z=z-2}
	local pos2 = {x=x+2, y=y+5, z=z+2}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local data = vm:get_data()

	for j = -2, -1 do -- check for soil
		local vi = area:index(x, y + j, z)
		if data[vi] ~= c_soil then
			return
		end
	end

	for j = 1, 5 do -- check for life support air
	for k = -2, 2 do
		local vi = area:index(x - 2, y + j, z + k)
		for i = -2, 2 do
			if data[vi] ~= c_lsair then
				return
			end
			vi = vi + 1
		end
	end
	end

	for j = -2, top do
		if j == top - 1 or j == top then
			for k = -2, 2 do
				local vi = area:index(x - 2, y + j, z + k)
				local viu = area:index(x - 2, y + j - 1, z + k)
				for i = -2, 2 do
					if math.random() < 0.8 then
						data[vi] = c_appleleaf
						if j == top and math.random() < 0.08 then
							data[viu] = c_apple
						end
					end
					vi = vi + 1
					viu = viu + 1
				end
			end
		elseif j == top - 2 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				for i = -1, 1 do
					if math.abs(i) + math.abs(k) == 2 then
						data[vi] = c_tree
					end
					vi = vi + 1
				end
			end
		else
			local vi = area:index(x, y + j, z)
			data[vi] = c_tree
		end
	end
	
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()

	print ("[moonrealm] moonrealm apple tree sapling grows")
end


-- Vacuum or air flows into a dug hole

minetest.register_on_dignode(function(pos, oldnode, digger)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	local c_lsair = minetest.get_content_id("moonrealm:air")
	local c_vacuum = minetest.get_content_id("moonrealm:vacuum")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x=x-1, y=y-1, z=z-1}
	local pos2 = {x=x+1, y=y+1, z=z+1}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local data = vm:get_data()

	local vic = area:index(x, y, z)
	for j = -1,1 do
	for k = -1,1 do
		local vi = area:index(x-1, y+j, z+k)
		for i = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodid = data[vi]
				if nodid == c_lsair then	
					local spread = minetest.get_meta({x=x+i,y=y+j,z=z+k}):get_int("spread")
					if spread > 0 then
						data[vic] = c_lsair
						minetest.get_meta(pos):set_int("spread", (spread - 1))
						vm:set_data(data)
						vm:write_to_map()			
						vm:update_map()
						print ("[moonrealm] moonrealm air flows into hole")
						return
					end
				end
			end
			vi = vi + 1
		end
	end
	end
	data[vic] = c_vacuum
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
	print ("[moonrealm] moonrealm vacuum flows into hole")
end)


-- Air spread ABM

minetest.register_abm({
	nodenames = {"moonrealm:air"},
	neighbors = {"moonrealm:vacuum"},
	interval = 13,
	chance = 9,
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
		local pos1 = {x=x-1, y=y-1, z=z-1}
		local pos2 = {x=x+1, y=y+1, z=z+1}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		for j = -1,1 do
		for k = -1,1 do
			local vi = area:index(x-1, y+j, z+k)
			for i = -1,1 do
				if not (i == 0 and j == 0 and k == 0) then
					local nodid = data[vi]
					if nodid == c_vacuum then
						data[vi] = c_lsair
						minetest.get_meta({x=x+i,y=y+j,z=z+k}):set_int("spread", (spread - 1))
						print ("[moonrealm] moonrealm air spreads")
					end
				end
				vi = vi + 1
			end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})


-- Hydroponic saturation ABM

minetest.register_abm({
	nodenames = {"moonrealm:hlsource"},
	neighbors = {"moonrealm:dust", "moonrealm:dustprint1", "moonrealm:dustprint2"},
	interval = 29,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local x = pos.x
		local y = pos.y
		local z = pos.z

		local c_dust = minetest.get_content_id("moonrealm:dust")
		local c_dustp1 = minetest.get_content_id("moonrealm:dustprint1")
		local c_dustp2 = minetest.get_content_id("moonrealm:dustprint2")
		local c_soil = minetest.get_content_id("moonrealm:soil")
	
		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-2, y=y-4, z=z-2}
		local pos2 = {x=x+2, y=y, z=z+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		for j = -4,0 do
		for k = -2,2 do
			local vi = area:index(x-2, y+j, z+k)
			for i = -2,2 do
				if not (i == 0 and j == 0 and k == 0) then
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
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})


-- Soil drying ABM

minetest.register_abm({
	nodenames = {"moonrealm:soil"},
	interval = 31,
	chance = 9,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local c_dust = minetest.get_content_id("moonrealm:dust")
		local c_hlsource = minetest.get_content_id("moonrealm:hlsource")
	
		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-2, y=y, z=z-2}
		local pos2 = {x=x+2, y=y+4, z=z+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		local vic = area:index(x, y, z)
		for j = 0, 4 do
		for k = -2, 2 do
			local vi = area:index(x-2, y+j, z+k)
			for i = -2, 2 do
				if not (i == 0 and j == 0 and k == 0) then
					local nodid = data[vi]
					if nodid == c_hlsource then
						return
					end
				end
				vi = vi + 1
			end
		end
		end
		data[vic] = c_dust

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()

		print ("[moonrealm] moonrealm soil dries")
	end,
})


-- Space appletree from sapling ABM

minetest.register_abm({
	nodenames = {"moonrealm:sapling"},
	interval = 31,
	chance = 7,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_appletree(pos)
	end,
})

