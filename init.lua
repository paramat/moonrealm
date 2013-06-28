-- moonrealm 0.3.0 by paramat.
-- Licenses: Code WTFPL. Textures CC BY-SA.
-- Moonstone and moondust textures are recoloured default textures: sand by VanessaE and stone by Perttu Ahola.

-- Variables.

local ONGEN = true -- (true / false) -- Enable / disable moonrealm generation.

local YMIN = 14000 -- Approx bottom. Rounded down to chunk boundary.
local YMAX = 15000 -- Approx surface. Rounded up to chunk boundary
local OFFCEN = 80 -- 80 -- Average offset centre, relative to base of surface chunks.
local CENAMP = 24 -- 24 -- Offset centre amplitude.
local HIGRAD = 48 -- 48 -- Surface generating noise gradient above offcen. Controls height of hills.
local LOGRAD = 48 -- 48 -- Surface generating noise gradient below offcen. Controls depth of depressions.
local HEXP = 1.5 -- 1.5 -- Noise offset exponent above offcen.
local LEXP = 3 -- 3 -- Noise offset exponent below offcen.

local DUSAMP = 0.1 -- 0.1 -- Dust depth amplitude.
local DUSRAN = 0.01 -- 0.01 -- Dust depth randomness.
local DUSGRAD = 128 -- 128 -- Dust noise gradient.

local CAVOFF = 0.02 -- 0.02 -- Cave offset. Size of underground caves.
local CAVLEV = 0 -- 0 -- Caves thin above this level, relative to base of surface chunks.
local CAVDIS = 80 -- 80 -- Cave thinning distance in nodes.

local LUX = true -- Enable / disable luxore.
local LUXCHUN = 7*7*7 -- 7*7*7 -- Luxore 1/x chance underground.

local ATMOS = true -- Enable / disable tinted atmosphere.
local ATMTOP = 16000 -- Exact top of atmosphere.
local ATMALP = 16 -- 16 -- Atmosphere alpha.
local ATMRED = 255 -- 255 -- Atmosphere RGB.
local ATMGRE = 148 -- 148
local ATMBLU = 0 -- 0

local DEBUG = true

-- Perlin noise for terrain.
local SEEDDIFF1 = 46894686546
local OCTAVES1 = 6 -- 6
local PERSISTENCE1 = 0.6 -- 0.6
local SCALE1 = 256 -- 256

-- perlin noise for terrain. 207 / 128 = golden ratio.
local SEEDDIFF4 = 1390930295123
local OCTAVES4 = 6 -- 6
local PERSISTENCE4 = 0.6 -- 0.6
local SCALE4 = 207 -- 207

-- Perlin noise for caves.
local SEEDDIFF2 = 9294207
local OCTAVES2 = 6 -- 6
local PERSISTENCE2 = 0.5 -- 0.5
local SCALE2 = 207 -- 207

-- Perlin noise for dust depth, average terrain level, dust colour
local SEEDDIFF3 = 93561
local OCTAVES3 = 4 -- 4
local PERSISTENCE3 = 0.5 -- 0.5
local SCALE3 = 256 -- 256

-- Stuff.

moonrealm = {}

local yminq = (80 * math.floor((YMIN + 32) / 80)) - 32
local ymaxq = (80 * math.floor((YMAX + 32) / 80)) + 47
local levcav = ymaxq - 159 + CAVLEV

-- Nodes.

minetest.register_node("moonrealm:moonstone", {
	description = "Moon Stone",
	tiles = {"moonrealm_moonstone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moondust1", {
	description = "Moon Dust 1",
	tiles = {"moonrealm_moondust1.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:moondust2", {
	description = "Moon Dust 2",
	tiles = {"moonrealm_moondust2.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:moondust3", {
	description = "Moon Dust 3",
	tiles = {"moonrealm_moondust3.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:moondust4", {
	description = "Moon Dust 4",
	tiles = {"moonrealm_moondust4.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:moondust5", {
	description = "Moon Dust 5",
	tiles = {"moonrealm_moondust5.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:luxore", {
	description = "MR Lux Ore",
	tiles = {"moonrealm_luxore.png"},
	light_source = 13,
	groups = {cracky=3},
	drop = "moonrealm:luxcrystal 6",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:luxnode", {
	description = "MR Lux Node",
	tiles = {"moonrealm_luxnode.png"},
	light_source = 14,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:atmos", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	post_effect_color = {a=ATMALP, r=ATMRED, g=ATMGRE, b=ATMBLU},
})

-- Item.

minetest.register_craftitem("moonrealm:luxcrystal", {
	description = "MR Lux Crystal",
	inventory_image = "moonrealm_luxcrystal.png",
})

-- Crafting.

minetest.register_craft({
    output = "moonrealm:luxnode",
    recipe = {
        {"moonrealm:luxcrystal", "moonrealm:luxcrystal", "moonrealm:luxcrystal"},
        {"moonrealm:luxcrystal", "moonrealm:luxcrystal", "moonrealm:luxcrystal"},
        {"moonrealm:luxcrystal", "moonrealm:luxcrystal", "moonrealm:luxcrystal"},
    },
})

-- On dignode. Atmosphere flows into a dug hole.

if ATMOS then
	minetest.register_on_dignode(function(pos, oldnode, digger)
		local env = minetest.env
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = env:get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:atmos" then	
					env:add_node({x=x,y=y,z=z},{name="moonrealm:atmos"})
					return
				end
			end
		end
		end
		end
	end)
end

-- Ores.

if ONGEN then
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:luxore",
		wherein        = "air",
		clust_scarcity = LUXCHUN,
		clust_num_ores = 1,
		clust_size     = 1,
		height_min     = yminq,
		height_max     = ymaxq - 160,
	})
	for i=1,8 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "moonrealm:moonstone",
			wherein        = "air",
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			height_min     = yminq,
			height_max     = ymaxq - 160,
		})
	end
	if ATMOS then
		for i=1,16 do
			minetest.register_ore({
				ore_type       = "scatter",
				ore            = "moonrealm:atmos",
				wherein        = "air",
				clust_scarcity = 1,
				clust_num_ores = 1,
				clust_size     = 1,
				height_min     = ymaxq - 159,
				height_max     = ATMTOP,
			})
		end
	end
end

-- On generated.

if ONGEN then
	minetest.register_on_generated(function(minp, maxp, seed)
		if maxp.y == ymaxq or maxp.y == ymaxq - 80 then -- if surface chunks then
			local env = minetest.env
			local perlin1 = env:get_perlin(SEEDDIFF1, OCTAVES1, PERSISTENCE1, SCALE1)
			local perlin2 = env:get_perlin(SEEDDIFF2, OCTAVES2, PERSISTENCE2, SCALE2)
			local perlin3 = env:get_perlin(SEEDDIFF3, OCTAVES3, PERSISTENCE3, SCALE3)
			local perlin4 = env:get_perlin(SEEDDIFF4, OCTAVES4, PERSISTENCE4, SCALE4)
			local x1 = maxp.x
			local y1 = maxp.y
			local z1 = maxp.z
			local x0 = minp.x
			local y0 = minp.y
			local z0 = minp.z
			for x = x0, x1 do -- for each plane do
				if DEBUG then
					print ("[moonrealm] Surface "..x - x0.." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for z = z0, z1 do -- for each column do
					local noise5 = perlin3:get2d({x=x+828,y=z+828})
					local cenoff = ymaxq - 159 + OFFCEN + noise5 * CENAMP
					for y = y0, y1 do -- for each node do
						if y > cenoff then
							offset = ((y - cenoff) / HIGRAD) ^ HEXP
						else
							offset = -((cenoff - y) / LOGRAD) ^ LEXP
						end
						local noise1 = perlin1:get3d({x=x,y=y,z=z})
						local noise4 = perlin4:get3d({x=x,y=y,z=z})
						local noise6 = perlin3:get3d({x=x-828,y=y-828,z=z-828}) + math.random() * 0.1
						local noise1off = (noise1 + noise4) / 2 - offset
						if noise1off >= 0 then -- if terrain then
							local cavprop = (1 - (y - levcav) / CAVDIS)
							local offcav = CAVOFF * cavprop
							local noise2 = perlin2:get3d({x=x,y=y,z=z})
							if math.abs(noise2) - offcav > 0 then -- if no cave then
								local noise3 = perlin3:get3d({x=x,y=y,z=z})
								local noise3off = noise3 - (y - cenoff) / DUSGRAD
								local thrsto = noise3off * DUSAMP + math.random() * DUSRAN
								if noise1off >= thrsto then
									if noise1off > DUSAMP and LUX and cavprop > 0
									and math.random(math.floor(LUXCHUN / cavprop)) == 2 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:luxore"})
									else
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moonstone"})
									end
								else
									if noise6 < -0.9 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moondust1"})
									elseif noise6 < -0.3 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moondust2"})
									elseif noise6 < 0.3 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moondust3"})
									elseif noise6 < 0.9 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moondust4"})
									else
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moondust5"})
									end
								end
							elseif ATMOS then -- if cave add atmos
								env:add_node({x=x,y=y,z=z},{name="moonrealm:atmos"})
							end
						end
					end
				end
			end
		elseif minp.y >= yminq and maxp.y <= ymaxq - 160 then -- if underground chunks then fissure cave system
			local env = minetest.env
			local perlin2 = env:get_perlin(SEEDDIFF2, OCTAVES2, PERSISTENCE2, SCALE2)
			local x1 = maxp.x
			local y1 = maxp.y
			local z1 = maxp.z
			local x0 = minp.x
			local y0 = minp.y
			local z0 = minp.z
			local offcav = CAVOFF
			for x = x0, x1 do -- for each plane do
				if DEBUG then
					print ("[moonrealm] Fissures "..x - x0.." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for z = z0, z1 do -- for each column do
					for y = y0, y1 do -- for each node do
						local noise2 = perlin2:get3d({x=x,y=y,z=z})
						if math.abs(noise2) - offcav < 0 then -- if cave then
							if ATMOS then
								env:add_node({x=x,y=y,z=z},{name="moonrealm:atmos"})
							else
								env:remove_node({x=x,y=y,z=z})
							end
						end
					end
				end
			end
		end
	end)
end
