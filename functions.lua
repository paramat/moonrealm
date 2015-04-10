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

	print ("[moonrealm] Appletree sapling grows")
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
						print ("[moonrealm] MR air flows into hole")
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
	print ("[moonrealm] Vacuum flows into hole")
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
						print ("[moonrealm] MR air spreads")
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
						print ("[moonrealm] Hydroponic liquid saturates")
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

		print ("[moonrealm] Moon soil dries")
	end,
})


-- Space appletree from sapling ABM

minetest.register_abm({
	nodenames = {"moonrealm:sapling"},
	interval = 31,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_appletree(pos)
	end,
})


-- Spawn player function, dependant on chunk size of 80 nodes

function moonrealm_spawnplayer(player)
	local GRADCEN = 0 --  -- Gradient centre / terrain centre average level
	local CENAMP = 64 --  -- Grad centre amplitude, terrain centre is varied by this
	local HIGRAD = 128 --  -- Surface generating noise gradient above gradcen, controls depth of upper terrain
	local LOGRAD = 128 --  -- Surface generating noise gradient below gradcen, controls depth of lower terrain
	local HEXP = 0.5 --  -- Noise offset exponent above gradcen, 1 = normal 3D perlin terrain
	local LEXP = 2 --  -- Noise offset exponent below gradcen
	local STOT = 0.04 --  -- Stone density threshold, depth of dust
	local PSCA = 16 -- Player scatter from world centre in chunks (80 nodes).
	local xsp
	local ysp
	local zsp
	local np_terrain = {
		offset = 0,
		scale = 1,
		spread = {x=512, y=512, z=512},
		seed = 58588900033,
		octaves = 6,
		persist = 0.67
	}
	local np_terralt = {
		offset = 0,
		scale = 1,
		spread = {x=414, y=414, z=414},
		seed = 13331930910,
		octaves = 6,
		persist = 0.67
	}
	local np_smooth = {
		offset = 0,
		scale = 1,
		spread = {x=828, y=828, z=828},
		seed = 113,
		octaves = 4,
		persist = 0.4
	}
	local np_fault = {
		offset = 0,
		scale = 1,
		spread = {x=414, y=828, z=414},
		seed = 14440002,
		octaves = 4,
		persist = 0.5
	}
	local np_gradcen = {
		offset = 0,
		scale = 1,
		spread = {x=1024, y=1024, z=1024},
		seed = 9344,
		octaves = 4,
		persist = 0.4
	}
	local np_terblen = {
		offset = 0,
		scale = 1,
		spread = {x=2048, y=2048, z=2048},
		seed = -13002,
		octaves = 3,
		persist = 0.4
	}
	for chunk = 1, 64 do
		print ("[moonrealm] searching for spawn "..chunk)

		local x0 = 80 * math.random(-PSCA, PSCA) - 32
		local z0 = 80 * math.random(-PSCA, PSCA) - 32
		local y0 = 80 * math.floor((GRADCEN + 32) / 80) - 32
		local x1 = x0 + 79
		local z1 = z0 + 79
		local y1 = y0 + 79
	
		local sidelen = 80
		local chulens = {x=sidelen, y=sidelen, z=sidelen}
		local minpos = {x=x0, y=y0, z=z0}
		local minposd = {x=x0, y=z0}
	
		local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minpos)
		local nvals_terralt = minetest.get_perlin_map(np_terralt, chulens):get3dMap_flat(minpos)
		local nvals_smooth = minetest.get_perlin_map(np_smooth, chulens):get3dMap_flat(minpos)
		local nvals_fault = minetest.get_perlin_map(np_fault, chulens):get3dMap_flat(minpos)
	
		local nvals_terblen = minetest.get_perlin_map(np_terblen, chulens):get2dMap_flat(minposd)
		local nvals_gradcen = minetest.get_perlin_map(np_gradcen, chulens):get2dMap_flat(minposd)
	
		local nixz = 1
		local nixyz = 1
		local stable = {}
		for z = z0, z1 do
			for y = y0, y1 do
				for x = x0, x1 do
					local si = x - x0 + 1
					local grad
					local density
					local terblen = math.max(math.min(math.abs(nvals_terblen[nixz]) * 4, 1.5), 0.5) - 0.5
					local gradcen = GRADCEN + nvals_gradcen[nixz] * CENAMP
					if y > gradcen then
						grad = -((y - gradcen) / HIGRAD) ^ HEXP
					else
						grad = ((gradcen - y) / LOGRAD) ^ LEXP
					end
					if nvals_fault[nixyz] >= 0 then
						density = (nvals_terrain[nixyz] + nvals_terralt[nixyz]) / 2 * (1 - terblen)
						+ nvals_smooth[nixyz] * terblen + grad
					else	
						density = (nvals_terrain[nixyz] - nvals_terralt[nixyz]) / 2 * (1 - terblen)
						- nvals_smooth[nixyz] * terblen + grad
					end
					if density >= STOT then
						stable[si] = true
					elseif stable[si] and density < 0 and terblen == 1 then
						ysp = y + 4
						xsp = x
						zsp = z
						break
					end
					nixz = nixz + 1
					nixyz = nixyz + 1
				end
				if ysp then
					break
				end
				nixz = nixz - 80
			end
			if ysp then
				break
			end
			nixz = nixz + 80
		end
		if ysp then
			break
		end
	end

	print ("[moonrealm] spawn player ("..xsp.." "..ysp.." "..zsp..")")

	player:setpos({x=xsp, y=ysp, z=zsp})
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "moonrealm:spacesuit")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "moonrealm:sapling 4")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "moonrealm:airlock 4")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "moonrealm:airgen 4")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "moonrealm:hlsource 4")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "default:apple 64")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "default:pick_diamond")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "default:axe_diamond")
	minetest.add_item({x=xsp, y=ysp+1, z=zsp}, "default:shovel_diamond")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x=xsp-3, y=ysp-3, z=zsp-3}
	local pos2 = {x=xsp+3, y=ysp+6, z=zsp+3}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
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
end


local SPAWNEGG = true
if SPAWNEGG then
	minetest.register_on_newplayer(function(player)
		moonrealm_spawnplayer(player)
	end)

	minetest.register_on_respawnplayer(function(player)
		moonrealm_spawnplayer(player)
		return true
	end)
end

