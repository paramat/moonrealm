-- moonrealm 0.5.0 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- Licenses: code WTFPL, textures CC BY-SA

-- Parameters

local XMIN = -33000 --  -- Approx horizontal limits
local XMAX = 33000
local ZMIN = -33000
local ZMAX = 33000

local YMIN = 14000 --  -- Approx lower limit
local LHCLEV = 14968 --  -- Liquid hydrocarbon lake level
local GRADCEN = 15000 --  -- Grad centre / terrain centre average level
local ICELEV = 15128 --  -- Ice spawns above this altitude
local YMAX = 16000 --  -- Approx top of atmosphere

local CENAMP = 96 --  -- Offset centre amplitude, terrain centre is varied by this
local HIGRAD = 96 --  -- Surface generating noise gradient above offcen, controls depth of upper terrain
local LOGRAD = 96 --  -- Surface generating noise gradient below offcen, controls depth of lower terrain
local HEXP = 0.5 --  -- Noise offset exponent above offcen, 1 = normal 3D perlin terrain
local LEXP = 2 --  -- Noise offset exponent below offcen

local FISTS = 0 --  -- Fissure threshold at surface. Controls size of fissure entrances at surface
local FISEXP = 0.05 --  -- Fissure expansion rate under surface

local STOT = 0.1 --  -- Stone density threshold, depth of dust
local DUSRAN = 0.05 --  -- Dust blend randonmness

local LUXCHA = 7*7*7 -- 7*7*7 -- Luxore 1/x chance underground
local IROCHA = 5*5*5 -- 5*5*5 -- Iron ore 1/x chance
local MESCHA = 23*23*23 -- 23*23*23 -- Mese block 1/x chance

local AIRINT = 29 --  -- Air spread abm interval
local AIRCHA = 9 --  -- 1/x chance per air node
local SOILINT = 31 --  -- Hydroponics saturation / drying abm intervals
local PININT = 57 --  -- Spawn pine abm interval
local PINCHA = 2 --  -- 1/x chance per sapling

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	seed = 58588900033,
	octaves = 5,
	persist = 0.6
}

-- 3D noise for alt terrain, 414 / 256 = golden ratio

local np_terralt = {
	offset = 0,
	scale = 1,
	spread = {x=414, y=414, z=414},
	seed = 13331930910,
	octaves = 6,
	persist = 0.6
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
	spread = {x=512, y=512, z=512},
	seed = 9344,
	octaves = 4,
	persist = 0.6
}

-- 3D noise for dust type

local np_dust = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	seed = 44,
	octaves = 3,
	persist = 0.5
}

-- Stuff

moonrealm = {}

dofile(minetest.get_modpath("moonrealm").."/nodes.lua")
dofile(minetest.get_modpath("moonrealm").."/functions.lua")

-- On dignode function, atmosphere or air flows into a dug hole from  face-connected neighbours only

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
				if nodename == "moonrealm:atmos" then -- atmos has priority to avoid air lweaks
					minetest.add_node({x=x,y=y,z=z},{name="moonrealm:atmos"})
					print ("[moonrealm] Atmosphere flows into hole")
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

--  -- ABMs

-- Air spreads into face-connected neighbours

if ATMOS and AIRGEN then
	minetest.register_abm({
		nodenames = {"moonrealm:air"},
		neighbors = {"moonrealm:atmos"},
		interval = AIRINT,
		chance = AIRCHA,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local x = pos.x
			local y = pos.y
			local z = pos.z
			local nodair = 0
			for i = -1,1 do
			for j = -1,1 do
			for k = -1,1 do
				if not (i == 0 and j == 0 and k == 0) then
					local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
					if nodename == "moonrealm:air" then
						nodair = nodair + 1
					end
				end
			end
			end
			end
			if nodair < 2 then
				return
			end
			for i = -1,1 do
			for j = -1,1 do
			for k = -1,1 do
				if math.abs(i) + math.abs(j) + math.abs(k) == 1 then
					local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
					if nodename == "moonrealm:atmos" then
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
	neighbors = {"moonrealm:moondust5"},
	interval = SOILINT,
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
				if nodename == "moonrealm:moondust5" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:moonsoil"})
					print ("[moonrealm] Hydroponic liquid saturates ("..i.." "..j.." "..k..")")
				end
			end
		end
		end
		end
	end
})

minetest.register_abm({
	nodenames = {"moonrealm:moonsoil"},
	interval = SOILINT,
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
		minetest.add_node(pos,{name="moonrealm:moondust5"})
		print ("[moonrealm] Moonsoil dries ("..x.." "..y.." "..z..")")
	end,
})

-- Space pine from sapling

minetest.register_abm({
	nodenames = {"moonrealm:psapling"},
	interval = PININT,
	chance = PINCHA,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moonrealm_pine(pos)
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
	local c_luxore = minetest.get_content_id("moonrealm:luxore")
	local c_mstone = minetest.get_content_id("moonrealm:moonstone")
	local c_msand = minetest.get_content_id("default:sandstone")
	local c_watice = minetest.get_content_id("moonrealm:waterice")
	local c_mdust1 = minetest.get_content_id("moonrealm:moondust1")
	local c_mdust2 = minetest.get_content_id("moonrealm:moondust2")
	local c_mdust3 = minetest.get_content_id("moonrealm:moondust3")
	local c_mdust4 = minetest.get_content_id("moonrealm:moondust4")
	local c_mdust5 = minetest.get_content_id("moonrealm:moondust5")
	local c_atmos = minetest.get_content_id("moonrealm:atmos")
	local c_lhcsour = minetest.get_content_id("moonrealm:lhcsource")
	
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local minpos = {x=x0, y=y0, z=z0}
	
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minpos)
	local nvals_terralt = minetest.get_perlin_map(np_terralt, chulens):get3dMap_flat(minpos)
	local nvals_fissure = minetest.get_perlin_map(np_fissure, chulens):get3dMap_flat(minpos)
	local nvals_gradcen = minetest.get_perlin_map(np_gradcen, chulens):get3dMap_flat(minpos)
	local nvals_dust = minetest.get_perlin_map(np_dust, chulens):get3dMap_flat(minpos)
	
	local ni = 1
	for z = z0, z1 do
	for y = y0, y1 do
	local vi = area:index(x0, y, z) -- LVM index for first node in x row
	for x = x0, x1 do
		local grad
		local cenoff = GRADCEN + nvals_gradcen[ni] * CENAMP
		if y > cenoff then
			grad = -((y - cenoff) / HIGRAD) ^ HEXP
		else
			grad = ((cenoff - y) / LOGRAD) ^ LEXP
		end
		local density = (nvals_terrain[ni] + nvals_terralt[ni]) / 2 + grad
		if density > 0 then -- if solid terrain
			local nofis = false
			if math.abs(nvals_fissure[ni]) > FISTS + math.sqrt(density) * FISEXP then
				nofis = true
			end
			if density >= STOT and nofis then -- stone, ores
				if math.random(MESCHA) == 2 then
					data[vi] = c_mese
				elseif math.random(IROCHA) == 2 then
					data[vi] = c_ironore
				elseif math.random(LUXCHA) == 2 then
					data[vi] = c_luxore
				else
					data[vi] = c_mstone
				end
			elseif density < STOT then
				if y <= LHCLEV + math.random(3) then -- moonsand below liquid level
					data[vi] = c_msand
				elseif nofis then
					if y > ICELEV and math.random(8) == 2 then -- dusts and water ice
						data[vi] = c_watice
					elseif nvals_dust[ni] < -0.9 + (math.random() - 0.5) * DUSRAN then
						data[vi] = c_mdust1
					elseif nvals_dust[ni] < -0.3 + (math.random() - 0.5) * DUSRAN then
						data[vi] = c_mdust2
					elseif nvals_dust[ni] < 0.3 + (math.random() - 0.5) * DUSRAN then
						data[vi] = c_mdust3
					elseif nvals_dust[ni] < 0.9 + (math.random() - 0.5) * DUSRAN then
						data[vi] = c_mdust4
					else
						data[vi] = c_mdust5
					end
				end
			elseif not nofis then -- fissure, add atmos
				data[vi] = c_atmos
			end
		elseif y <= LHCLEV then -- if lake then
			data[vi] = c_lhcsour
		else -- atmosphere
			data[vi] = c_atmos
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