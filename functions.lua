-- Space apple tree

function moonrealm_appletree(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	for j = -2, -1 do
		local nodename = minetest.get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moonrealm:soil" then
			return
		end
	end
	for j = 1, 5 do
		local nodename = minetest.get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moonrealm:air" then
			return
		end
	end
	for j = -2, 4 do
		if j >= 1 then
			for i = -2, 2 do
			for k = -2, 2 do
				local nodename = minetest.get_node({x=x+i,y=y+j+1,z=z+k}).name
				if math.random() > (math.abs(i) + math.abs(k)) / 16 then
					if math.random(13) == 2 then
						minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="default:apple"})
					else
						minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="moonrealm:leaves"})
					end
				else
					minetest.add_node({x=x+i,y=y+j+1,z=z+k},{name="moonrealm:air"})
					minetest.get_meta({x=x+i,y=y+j+1,z=z+k}):set_int("spread", 16)
				end
			end
			end
		end
		minetest.add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
	end
	print ("[moonrealm] Appletree sapling grows")
end

-- Vacuum or air flows into a dug hole

minetest.register_on_dignode(function(pos, oldnode, digger)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	for i = -1,1 do
	for j = -1,1 do
	for k = -1,1 do
		if not (i == 0 and j == 0 and k == 0) then
			local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
			if nodename == "moonrealm:air" then	
				local spread = minetest.get_meta({x=x+i,y=y+j,z=z+k}):get_int("spread")
				if spread > 0 then
					minetest.add_node({x=x,y=y,z=z},{name="moonrealm:air"})
					minetest.get_meta(pos):set_int("spread", (spread - 1))
					print ("[moonrealm] MR air flows into hole "..(spread - 1))
					return
				end
			elseif nodename == "moonrealm:vacuum" then
				minetest.add_node({x=x,y=y,z=z},{name="moonrealm:vacuum"})
				print ("[moonrealm] Vacuum flows into hole")
				return
			end
		end
	end
	end
	end
end)

-- ABMs

-- Air spreads

minetest.register_abm({
	nodenames = {"moonrealm:air"},
	neighbors = {"moonrealm:vacuum", "air"},
	interval = 11,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local spread = minetest.get_meta(pos):get_int("spread")
		if spread <= 0 then
			return
		end
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:vacuum"
				or nodename == "air" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:air"})
					minetest.get_meta({x=x+i,y=y+j,z=z+k}):set_int("spread", (spread - 1))
					print ("[moonrealm] MR air spreads "..(spread - 1))
				end
			end
		end
		end
		end
	end
})

-- Hydroponic saturation

minetest.register_abm({
	nodenames = {"moonrealm:hlsource", "moonrealm:hlflowing"},
	neighbors = {"moonrealm:dust", "moonrealm:dustprint1", "moonrealm:dustprint2"},
	interval = 29,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -2,2 do
		for j = -4,0 do -- saturates out and downwards to pos.y - 4, a 5x5 cube.
		for k = -2,2 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:dust"
				or nodename == "moonrealm:dustprint1"
				or nodename == "moonrealm:dustprint2" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:soil"})
					print ("[moonrealm] Hydroponic liquid saturates")
				end
			end
		end
		end
		end
	end
})

-- Soil drying

minetest.register_abm({
	nodenames = {"moonrealm:soil"},
	interval = 31,
	chance = 27,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -2, 2 do
		for j = 0, 4 do -- search above for liquid
		for k = -2, 2 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:hlsource" or nodename == "moonrealm:hlflowing" then
					return
				end
			end
		end
		end
		end
		minetest.add_node(pos,{name="moonrealm:dust"})
		print ("[moonrealm] Moon soil dries")
	end,
})

-- Space appletree from sapling

minetest.register_abm({
	nodenames = {"moonrealm:sapling"},
	interval = 57,
	chance = 3,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_appletree(pos)
	end,
})

-- Singlenode option

local SINGLENODE = true

if SINGLENODE then
	minetest.register_on_mapgen_init(function(mgparams)
		minetest.set_mapgen_params({mgname="singlenode", water_level=-33000})
	end)

	-- Spawn player

	function spawnplayer(player)
		local GRADCEN = 1 --  -- Gradient centre / terrain centre average level
		local CENAMP = 64 --  -- Grad centre amplitude, terrain centre is varied by this
		local HIGRAD = 128 --  -- Surface generating noise gradient above gradcen, controls depth of upper terrain
		local LOGRAD = 128 --  -- Surface generating noise gradient below gradcen, controls depth of lower terrain
		local HEXP = 0.5 --  -- Noise offset exponent above gradcen, 1 = normal 3D perlin terrain
		local LEXP = 2 --  -- Noise offset exponent below gradcen
		local STOT = 0.04 --  -- Stone density threshold, depth of dust
		local PSCA = 4 -- Player scatter from world centre in chunks (80 nodes).
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
			local y0 = -32
			local x1 = x0 + 79
			local z1 = z0 + 79
			local y1 = 47
	
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
						elseif stable[si] and density < 0 then
							ysp = y + 8
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
		local vm = minetest.get_voxel_manip()
		local pos1 = {x=xsp-2, y=ysp-2, z=zsp-2}
		local pos2 = {x=xsp+2, y=ysp+2, z=zsp+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		local c_glass = minetest.get_content_id("default:glass")
		local c_lsair = minetest.get_content_id("moonrealm:air")
		for i = -2, 2 do
		for j = -2, 2 do
		for k = -2, 2 do
			local vi = area:index(xsp + i, ysp + j, zsp + k)
			if i ^ 2 + j ^ 2 + k ^ 2 >= 4 then
				data[vi] = c_glass
			else
				data[vi] = c_lsair
			end
		end
		end
		end
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end

	minetest.register_on_newplayer(function(player)
		spawnplayer(player)
	end)

	minetest.register_on_respawnplayer(function(player)
		spawnplayer(player)
		return true
	end)
end