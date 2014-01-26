-- moonrealm 0.6.0 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- Licenses: code WTFPL, textures CC BY-SA

-- TODO
-- Footprints
-- Smooth terrain with blend?
-- Craters, old eroded massive plus fresh small plus random strikes
-- Vacuum nodes with damage unless spacesuit

-- Parameters

local XMIN = -33000 --  -- Approx horizontal limits
local XMAX = 33000
local ZMIN = -33000
local ZMAX = 33000

local YMIN = 14000 --  -- Approx lower limit
local GRADCEN = 15024 --  -- Grad centre / terrain centre average level
local YMAX = 16000 --  -- Approx top of atmosphere

local CENAMP = 128 --  -- Grad centre amplitude, terrain centre is varied by this
local HIGRAD = 128 --  -- Surface generating noise gradient above gradcen, controls depth of upper terrain
local LOGRAD = 128 --  -- Surface generating noise gradient below gradcen, controls depth of lower terrain
local HEXP = 0.5 --  -- Noise offset exponent above gradcen, 1 = normal 3D perlin terrain
local LEXP = 2 --  -- Noise offset exponent below gradcen

local FISTS = 0 --  -- Fissure threshold at surface. Controls size of fissure entrances at surface
local FISEXP = 0.05 --  -- Fissure expansion rate under surface

local STOT = 0.04 --  -- Stone density threshold, depth of dust at lake level
local THIDIS = 192 --  -- Vertical thinning distance for dust
local ICECHA = 13*13*13 --  -- Ice 1/x chance per dust node

local ORECHA = 7*7*7 --  -- Ore 1/x chance per moonstone node
local MESCHA = 32 --  -- Mese block 1/x chance, else ironore

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = 58588900033,
	octaves = 6,
	persist = 0.67
}

-- 3D noise for alt terrain, 414 / 256 = golden ratio

local np_terralt = {
	offset = 0,
	scale = 1,
	spread = {x=414, y=414, z=414},
	seed = 13331930910,
	octaves = 6,
	persist = 0.67
}

-- 3D noise for fissures

local np_fissure = {
	offset = 0,
	scale = 1,
	spread = {x=207, y=207, z=207},
	seed = 8181112,
	octaves = 5,
	persist = 0.5
}

-- 3D noise for gradient centre

local np_gradcen = {
	offset = 0,
	scale = 1,
	spread = {x=1024, y=1024, z=1024},
	seed = 9344,
	octaves = 3,
	persist = 0.6
}

-- 3D noise for faults

local np_fault = {
	offset = 0,
	scale = 1,
	spread = {x=414, y=828, z=414},
	seed = 14440002,
	octaves = 4,
	persist = 0.5
}

-- Stuff

moonrealm = {}

dofile(minetest.get_modpath("moonrealm").."/nodes.lua")
dofile(minetest.get_modpath("moonrealm").."/functions.lua")

-- On dignode function, vacuum or air flows into a dug hole from face-connected neighbours only

if ATMOS then
	minetest.register_on_dignode(function(pos, oldnode, digger)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if math.abs(i) + math.abs(j) + math.abs(k) == 1 then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:vacuum" then -- vacuum has priority to avoid air lweaks
					minetest.add_node({x=x,y=y,z=z},{name="moonrealm:vacuum"})
					print ("[moonrealm] Vacuum flows into hole")
					return
				elseif nodename == "moonrealm:air" then	
					minetest.add_node({x=x,y=y,z=z},{name="moonrealm:air"})
					print ("[moonrealm] Air flows into hole")
					return
				end
			end
		end
		end
		end
	end)
end

-- ABMs

-- Air spreads into face-connected neighbours

if ATMOS and AIRGEN then
	minetest.register_abm({
		nodenames = {"moonrealm:air"},
		neighbors = {"moonrealm:vacuum"},
		interval = 29,
		chance = 9,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local x = pos.x
			local y = pos.y
			local z = pos.z
			local nodair = 0
			local nodvac = 0
			for i = -1,1 do
			for j = -1,1 do
			for k = -1,1 do
				if not (i == 0 and j == 0 and k == 0) then
					local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
					if nodename == "moonrealm:air" then
						nodair = nodair + 1
					elseif nodename == "moonrealm:vacuum" then
						nodair = nodvac + 1
					end
				end
			end
			end
			end
			if nodair == 0 or nodvac >= 17 then
				return
			end
			for i = -1,1 do
			for j = -1,1 do
			for k = -1,1 do
				if math.abs(i) + math.abs(j) + math.abs(k) == 1 then -- face connected neighbours
					local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
					if nodename == "moonrealm:vacuum" then
						minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:air"})
						print ("[moonrealm] Air spreads")
					end
				end
			end
			end
			end
		end
	})
end

-- Hydroponics, saturation and drying

minetest.register_abm({
	nodenames = {"moonrealm:hlsource", "moonrealm:hlflowing"},
	neighbors = {"moonrealm:dust"},
	interval = 31,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -2,0 do -- saturates out and downwards to pos.y - 2, a 3x3 cube.
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:dust" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:soil"})
					print ("[moonrealm] Hydroponic liquid saturates ("..i.." "..j.." "..k..")")
				end
			end
		end
		end
		end
	end
})

minetest.register_abm({
	nodenames = {"moonrealm:soil"},
	interval = 31,
	chance = 27,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1, 1 do
		for j = 0, 2 do -- search above for liquid
		for k = -1, 1 do
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
		print ("[moonrealm] Moonsoil dries ("..x.." "..y.." "..z..")")
	end,
})

-- Space appletree from sapling

minetest.register_abm({
	nodenames = {"moonrealm:sapling"},
	interval = 57,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_appletree(pos)
	end,
})

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.x < XMIN or maxp.x > XMAX
	or minp.y < YMIN or maxp.y > YMAX
	or minp.z < ZMIN or maxp.z > ZMAX then
		return
	end
	
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[moonrealm] chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_mese = minetest.get_content_id("default:mese")
	local c_ironore = minetest.get_content_id("moonrealm:ironore")
	local c_mstone = minetest.get_content_id("moonrealm:stone")
	local c_watice = minetest.get_content_id("moonrealm:waterice")
	local c_mdust = minetest.get_content_id("moonrealm:dust")
	local c_vacuum = minetest.get_content_id("moonrealm:vacuum")
	
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local minpos = {x=x0, y=y0, z=z0}
	
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minpos)
	local nvals_terralt = minetest.get_perlin_map(np_terralt, chulens):get3dMap_flat(minpos)
	local nvals_fissure = minetest.get_perlin_map(np_fissure, chulens):get3dMap_flat(minpos)
	local nvals_gradcen = minetest.get_perlin_map(np_gradcen, chulens):get3dMap_flat(minpos)
	local nvals_fault = minetest.get_perlin_map(np_fault, chulens):get3dMap_flat(minpos)
	
	local ni = 1
	local stable = {}
	for z = z0, z1 do
		for x = x0, x1 do
			local si = x - x0 + 1
			local nodename = minetest.get_node({x=x,y=y0-1,z=z}).name
			if nodename == "moonrealm:vacuum" then
				stable[si] = false
			else -- solid nodes and ignore in ungenerated chunks
				stable[si] = true
			end
		end
		for y = y0, y1 do
			local vi = area:index(x0, y, z) -- LVM index for first node in x row
			for x = x0, x1 do -- for each node
				local grad
				local density
				local si = x - x0 + 1 -- indexes start from 1
				local gradcen = GRADCEN + nvals_gradcen[ni] * CENAMP
				if y > gradcen then
					grad = -((y - gradcen) / HIGRAD) ^ HEXP
				else
					grad = ((gradcen - y) / LOGRAD) ^ LEXP
				end
				if nvals_fault[ni] >= 0 then
					density = (nvals_terrain[ni] + nvals_terralt[ni]) / 2 + grad
				else	
					density = (nvals_terrain[ni] - nvals_terralt[ni]) / 2 + grad
				end
				
				if density > 0 then -- if terrain
					local nofis = false
					if math.abs(nvals_fissure[ni]) > FISTS + math.sqrt(density) * FISEXP then
						nofis = true
					end
					local stot = math.max((1 - (y - GRADCEN) / THIDIS) * STOT, 0)
					
					if density >= stot and nofis then -- stone, ores 
						if math.random(ORECHA) == 2 then
							if math.random(MESCHA) == 2 then
								data[vi] = c_mese
							else
								data[vi] = c_ironore
							end
						else
							data[vi] = c_mstone
						end
						stable[si] = true
					elseif density < stot then -- fine materials
						if nofis and stable[si] then
							if math.random(ICECHA) == 2 then
								data[vi] = c_watice
							else
								data[vi] = c_mdust
							end
						else -- fissure
							data[vi] = c_vacuum
							stable[si] = false
						end
					else -- fissure or unstable missing node
						data[vi] = c_vacuum
						stable[si] = false
					end
				else -- vacuum
					data[vi] = c_vacuum
					stable[si] = false
				end
				ni = ni + 1
				vi = vi + 1
			end
		end
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[moonrealm] "..chugent.." ms")
end)