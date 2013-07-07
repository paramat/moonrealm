-- moonrealm 0.4.2 by paramat.
-- Licenses: Code WTFPL. Textures CC BY-SA.
-- Moonstone and some moondust textures are recoloured default textures: sands by VanessaE and stone by Perttu Ahola.
-- Pine sapling, needles and ice textures by Splizard.

-- Parameters.

local ONGEN = true -- (true / false) -- Enable / disable moonrealm generation.

local YMIN = 14000 -- Approx bottom. Rounded down to chunk boundary.
local YMAX = 15000 -- Approx surface. Rounded up to chunk boundary.
local ATMTOP = 16000 -- Exact top of atmosphere nodes (if ATMOS = true).

local OFFCEN = 80 -- 80 -- Offset centre average. Terrain centre average level, relative to base of surface chunks.
local CENAMP = 24 -- 24 -- Offset centre amplitude. Terrain centre is varied by this.
local HIGRAD = 48 -- 48 -- Surface generating noise gradient above offcen. Controls depth of upper terrain.
local LOGRAD = 48 -- 48 -- Surface generating noise gradient below offcen. Controls depth of lower terrain.
local HEXP = 2 -- 2 -- Noise offset exponent above offcen. -- Crazyness parameters upper/lower terrain, 1 = normal 3D perlin terrain.
local LEXP = 2 -- 2 -- Noise offset exponent below offcen.

local DUSAMP = 0.1 -- 0.1 -- Dust depth amplitude.
local DUSRAN = 0.01 -- 0.01 -- Dust depth randomness.
local DUSGRAD = 128 -- 128 -- Dust noise gradient.

local LHCLEV = 48 -- 48 -- Liquid hydrocarbon lake level, relative to base of surface chunks.
local LHCALP = 192 -- 192 -- LHC alpha.
local LHCRED = 140 -- 140 -- LHC RGB.
local LHCGRE = 19 -- 19
local LHCBLU = 0 -- 0

local ICELEV = 128 -- 128 -- Ice spawns above this altitude, relative to base of surface chunks.
local ICECHA = 1 -- 1 -- Maximum 1/x chance water ice in dust.

local CAVOFF = 0.02 -- 0.02 -- Cave offset. Size of underground caves.
local CAVLEV = 0 -- 0 -- Caves thin above this level, relative to base of surface chunks.
local CAVDIS = 96 -- 96 -- Cave thinning distance in nodes.

local LUXCHA = 7*7*7 -- 7*7*7 -- Luxore 1/x chance underground.
local IROCHA = 5*5*5 -- 5*5*5 -- Iron ore 1/x chance.
local MESCHA = 23*23*23 -- 23*23*23 -- Mese block 1/x chance.

local ATMOS = true -- Enable / disable tinted atmosphere nodes. 
local ATMALP = 16 -- 16 -- Atmosphere alpha.
local ATMRED = 255 -- 255 -- Atmosphere RGB.
local ATMGRE = 148 -- 148
local ATMBLU = 0 -- 0

local AIRGEN = true -- Enable/disable air spread abm (in case of air leak).
local AIRINT = 29 -- 29 -- Air spread abm interval.

local SOILINT = 31 -- 31 -- Hydroponics abm interval.
local PININT = 57 -- 57 -- Spawn pine abm interval.
local PINCHA = 2 -- 2 -- 1/x chance per sapling.
local PINMIN = 5 -- 5 -- Needles height minimum.
local PINMAX = 7 -- 7 -- Needles height maximum.

local PROG = true -- Enable/disable chunk generation progress printed to terminal.

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
local levlhc = ymaxq - 159 + LHCLEV
local levcav = ymaxq - 159 + CAVLEV
local levice = ymaxq - 159 + ICELEV

-- Nodes.

minetest.register_node("moonrealm:moonstone", {
	description = "Moon Stone",
	tiles = {"moonrealm_moonstone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:ironore", {
	description = "Iron Ore",
	tiles = {"moonrealm_moonstone.png^default_mineral_iron.png"},
	groups = {cracky=3},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moondust1", {
	description = "Moon Dust 1",
	tiles = {"moonrealm_moondust1.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.09},
	}),
})

minetest.register_node("moonrealm:moondust2", {
	description = "Moon Dust 2",
	tiles = {"moonrealm_moondust2.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.08},
	}),
})

minetest.register_node("moonrealm:moondust3", {
	description = "Moon Dust 3",
	tiles = {"moonrealm_moondust3.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.07},
	}),
})

minetest.register_node("moonrealm:moondust4", {
	description = "Moon Dust 4",
	tiles = {"moonrealm_moondust4.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.06},
	}),
})

minetest.register_node("moonrealm:moondust5", {
	description = "Moon Dust 5",
	tiles = {"moonrealm_moondust5.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.05},
	}),
})

minetest.register_node("moonrealm:luxore", {
	description = "MR Lux Ore",
	tiles = {"moonrealm_luxore.png"},
	light_source = 14,
	groups = {cracky=3},
	drop = "moonrealm:luxcrystal 6",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:luxnode", {
	description = "MR Lux Node",
	tiles = {"moonrealm_luxnode.png"},
	light_source = 14,
	groups = {cracky=2},
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

minetest.register_node("moonrealm:air", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
})

minetest.register_node("moonrealm:airgen", {
	description = "Air Generator",
	tiles = {"moonrealm_airgen.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local env = minetest.env
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = env:get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:atmos" or nodename == "air" then
					env:add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:air"})
					print ("[moonrealm] Added air node")
				end
			end
		end
		end
		end
		
	end
})

minetest.register_node("moonrealm:waterice", {
	description = "Water Ice",
	tiles = {"moonrealm_waterice.png"},
	light_source = 1,
	paramtype = "light",
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:hlflowing", {
	description = "Flowing HL",
	inventory_image = minetest.inventorycube("moonrealm_hl.png"),
	drawtype = "flowingliquid",
	tiles = {"moonrealm_hl.png"},
	special_tiles = {
		{
			image="moonrealm_hlflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="moonrealm_hlflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = 224,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "moonrealm:hlflowing",
	liquid_alternative_source = "moonrealm:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("moonrealm:hlsource", {
	description = "HL Source",
	inventory_image = minetest.inventorycube("moonrealm_hl.png"),
	drawtype = "liquid",
	tiles = {"moonrealm_hl.png"},
	alpha = 224,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "moonrealm:hlflowing",
	liquid_alternative_source = "moonrealm:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("moonrealm:moonsoil", {
	description = "Moon Soil",
	tiles = {"moonrealm_moonsoil.png"},
	groups = {crumbly=3},
	drop = "moonrealm:moondust5",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("moonrealm:airlock", {
	description = "Airlock",
	tiles = {"moonrealm_airlock.png"},
	light_source = 14,
	walkable = false,
	post_effect_color = {a=255, r=0, g=0, b=0},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moonstonebrick", {
	description = "Moonstone Brick",
	tiles = {"moonrealm_moonstonebricktop.png", "moonrealm_moonstonebrickbot.png", "moonrealm_moonstonebrick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:moonglass", {
	description = "Moon Glass",
	drawtype = "glasslike",
	tiles = {"moonrealm_moonglass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moonrealm:needles", {
	description = "MR Pine Needles",
	visual_scale = 1.3,
	tiles = {"moonrealm_needles.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"moonrealm:psapling"}, rarity = 20},
			{items = {"moonrealm:needles"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("moonrealm:psapling", {
	description = "MR Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"moonrealm_psapling.png"},
	inventory_image = "moonrealm_psapling.png",
	wield_image = "moonrealm_psapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})


minetest.register_node("moonrealm:moonstoneslab", {
	description = "Moonstone Slab",
	tiles = {"moonrealm_moonstonebricktop.png", "moonrealm_moonstonebrickbot.png", "moonrealm_moonstonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moonrealm:lhcflowing", {
	description = "Flowing Liquid Hydrocarbons",
	inventory_image = minetest.inventorycube("moonrealm_lhc.png"),
	drawtype = "flowingliquid",
	tiles = {"moonrealm_lhc.png"},
	special_tiles = {
		{
			image="moonrealm_lhcflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="moonrealm_lhcflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = LHCALP,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "moonrealm:lhcflowing",
	liquid_alternative_source = "moonrealm:lhcsource",
	liquid_viscosity = 0,
	post_effect_color = {a=LHCALP, r=LHCRED, g=LHCGRE, b=LHCBLU},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("moonrealm:lhcsource", {
	description = "Liquid Hydrocarbon Source",
	inventory_image = minetest.inventorycube("moonrealm_lhc.png"),
	drawtype = "liquid",
	tiles = {"moonrealm_lhc.png"},
	alpha = LHCALP,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "moonrealm:lhcflowing",
	liquid_alternative_source = "moonrealm:lhcsource",
	liquid_viscosity = 0,
	post_effect_color = {a=LHCALP, r=LHCRED, g=LHCGRE, b=LHCBLU},
	groups = {water=3, liquid=3, puts_out_fire=1},
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

minetest.register_craft({
    output = "moonrealm:airgen",
    recipe = {
        {"default:steel_ingot", "moonrealm:waterice", "default:steel_ingot"},
        {"moonrealm:waterice", "moonrealm:luxnode", "moonrealm:waterice"},
        {"default:steel_ingot", "moonrealm:waterice", "default:steel_ingot"},
    },
})

minetest.register_craft({
	output = "default:water_source",
	recipe = {
		{"moonrealm:waterice"},
	},
})

minetest.register_craft({
    output = "moonrealm:hlsource",
    recipe = {
        {"moonrealm:needles", "moonrealm:needles", "moonrealm:needles"},
        {"moonrealm:needles", "moonrealm:waterice", "moonrealm:needles"},
        {"moonrealm:needles", "moonrealm:needles", "moonrealm:needles"},
    },
})

minetest.register_craft({
	output = "moonrealm:moonstonebrick 4",
	recipe = {
		{"moonrealm:moonstone", "moonrealm:moonstone"},
		{"moonrealm:moonstone", "moonrealm:moonstone"},
	}
})

minetest.register_craft({
    output = "moonrealm:airlock",
    recipe = {
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"default:steel_ingot", "moonrealm:luxnode", "default:steel_ingot"},
        {"default:steel_ingot", "", "default:steel_ingot"},
    },
})

minetest.register_craft({
    output = "default:furnace",
    recipe = {
        {"moonrealm:moonstone", "moonrealm:moonstone", "moonrealm:moonstone"},
        {"moonrealm:moonstone", "", "moonrealm:moonstone"},
        {"moonrealm:moonstone", "moonrealm:moonstone", "moonrealm:moonstone"},
    },
})

minetest.register_craft({
	output = "moonrealm:moonstoneslab 4",
	recipe = {
		{"moonrealm:moonstone", "moonrealm:moonstone"},
	}
})

-- Cooking.

minetest.register_craft({
	type = "cooking",
	output = "moonrealm:moonglass",
	recipe = "moonrealm:moondust1",
})

-- Fuel.

minetest.register_craft({
	type = "fuel",
	recipe = "moonrealm:luxcrystal",
	burntime = 50,
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
					print ("[moonrealm] Atmosphere flows into hole")
					return
				end
			end
		end
		end
		end
	end)
end

-- Abm.

-- Air spread abm, life support air and pine needles.

if ATMOS and AIRGEN then
	minetest.register_abm({
		nodenames = {"moonrealm:air"},
		neighbors = {"moonrealm:atmos", "air"},
		interval = AIRINT,
		chance = 9,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local env = minetest.env
			local x = pos.x
			local y = pos.y
			local z = pos.z
			for i = -1,1 do
			for j = -1,1 do
			for k = -1,1 do
				if not (i == 0 and j == 0 and k == 0) then
					local nodename = env:get_node({x=x+i,y=y+j,z=z+k}).name
					if nodename == "moonrealm:atmos" or nodename == "air" then
						env:add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:air"})
						print ("[moonrealm] Air spreads ("..i.." "..j.." "..k..")")
					end
				end
			end
			end
			end
		end
	})
end

-- Hydroponics. Saturation and drying.

minetest.register_abm({
	nodenames = {"moonrealm:hlsource", "moonrealm:hlflowing"},
	interval = SOILINT,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local env = minetest.env
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = env:get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moonrealm:moondust5" then
					env:add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:moonsoil"})
					print ("[moonrealm] Hydroponic liquid saturates")
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
	chance = 9,
	action = function(pos, node)
		if not minetest.find_node_near(pos, 1, {"moonrealm:hlsource", "moonrealm:hlflowing"}) then
			minetest.add_node(pos, {name="moonrealm:moondust5"})
			print ("[moonrealm] Moonsoil dries")
		end
	end,
})

-- Space pine from sapling.

minetest.register_abm({
	nodenames = {"moonrealm:psapling"},
	interval = PININT,
	chance = PINCHA,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local env = minetest.env
		local anodename = env:get_node({x=pos.x,y=pos.y+1,z=pos.z}).name
		local unodename = env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name
		if unodename == "moonrealm:moonsoil" and (anodename == "moonrealm:air" or anodename == "air") then
			moonrealm_pine(pos)
			print ("[moonrealm] Pine sapling grows")
		end
	end,
})

-- Ores.

if ONGEN then
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "default:mese",
		wherein        = "air",
		clust_scarcity = MESCHA,
		clust_num_ores = 1,
		clust_size     = 1,
		height_min     = yminq,
		height_max     = ymaxq - 160,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:ironore",
		wherein        = "air",
		clust_scarcity = IROCHA,
		clust_num_ores = 1,
		clust_size     = 1,
		height_min     = yminq,
		height_max     = ymaxq - 160,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "moonrealm:luxore",
		wherein        = "air",
		clust_scarcity = LUXCHA,
		clust_num_ores = 1,
		clust_size     = 1,
		height_min     = yminq,
		height_max     = ymaxq - 160,
	})
	for i=1,7 do
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
		for i=1,11 do
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
				if PROG then
					print ("[moonrealm] Surface "..x - x0.." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for z = z0, z1 do -- for each column do
					local surfy = false
					local lakebed = false
					local noise5 = perlin3:get2d({x=x+828,y=z+828})
					local cenoff = ymaxq - 159 + OFFCEN + noise5 * CENAMP
					for y = y1, y0, -1 do -- for each node do
						if y > cenoff then
							offset = ((y - cenoff) / HIGRAD) ^ HEXP
						else
							offset = -((cenoff - y) / LOGRAD) ^ LEXP
						end
						local noise1 = perlin1:get3d({x=x,y=y,z=z})
						local noise4 = perlin4:get3d({x=x,y=y,z=z})
						local noise1off = (noise1 + noise4) / 2 - offset
						if noise1off >= 0 then -- if terrain then
							if not surfy then
								surfy = y
								if surfy <= levlhc + 1 then
									lakebed = true
								end
							end
							local cavprop = (1 - (y - levcav) / CAVDIS)
							local offcav = CAVOFF * cavprop
							local noise2 = perlin2:get3d({x=x,y=y,z=z})
							if math.abs(noise2) - offcav > 0 or (lakebed and noise1off < DUSAMP) then -- if no cave or lakebed then
								local noise3 = perlin3:get3d({x=x,y=y,z=z})
								local noise3off = noise3 - (y - cenoff) / DUSGRAD
								local thrsto = noise3off * DUSAMP + math.random() * DUSRAN
								if noise1off >= thrsto then -- if stone then
									if noise1off > DUSAMP and math.random(MESCHA) == 2 then
										env:add_node({x=x,y=y,z=z},{name="default:mese"})
									elseif noise1off > DUSAMP and math.random(IROCHA) == 2 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:ironore"})
									elseif noise1off > DUSAMP and cavprop > 0
									and math.random(math.floor(LUXCHA / cavprop)) == 2 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:luxore"})
									else
										env:add_node({x=x,y=y,z=z},{name="moonrealm:moonstone"})
									end
								else -- dust
									local noise6 = perlin3:get3d({x=x-828,y=y-828,z=z-828}) + math.random() * 0.1
									if y > levice and math.random(math.floor(ICECHA * (ymaxq - levice) / (y - levice))) == 1 then
										env:add_node({x=x,y=y,z=z},{name="moonrealm:waterice"})
									elseif noise6 < -0.9 then
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
						elseif y <= levlhc then -- if lake then
							env:add_node({x=x,y=y,z=z},{name="moonrealm:lhcsource"})
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
				if PROG then
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

-- Functions.

function moonrealm_pine(pos)
	local env = minetest.env
	local t = math.random(PINMIN, PINMAX)
	for j= -2, t - 2 do
		env:add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
		if j >= 1 and j <= t - 4 then
			for i = -1, 1 do
			for k = -1, 1 do
				if i ~= 0 or k ~= 0 then
					env:add_node({x=pos.x+i,y=pos.y+j,z=pos.z+k},{name="moonrealm:needles"})
				end
			end
			end
		elseif j >= t - 3 then
			for i = -1, 1 do
			for k = -1, 1 do
				if (i == 0 and k ~= 0) or (i ~= 0 and k == 0) then
					env:add_node({x=pos.x+i,y=pos.y+j,z=pos.z+k},{name="moonrealm:needles"})
				end
			end
			end
		end
	end
	for j = t - 1, t do
		env:add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="moonrealm:needles"})
	end
end
