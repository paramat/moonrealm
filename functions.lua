-- Space apple tree

function moonrealm_appletree(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	for j = -3, -1 do
		local nodename = minetest.get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moonrealm:moonsoil" then
			return
		end
	end
	for j = 1, 5 do
		local nodename = minetest.get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moonrealm:air" and nodename ~= "air" then
			return
		end
	end
	for j = -3, 4 do
		if j >= 1 then
			for i = -2, 2 do
			for k = -2, 2 do
				local nodename = minetest.get_node({x=x+i,y=y+j+1,z=z+k}).name
				if math.random() > (math.abs(i) + math.abs(k)) / 24
				and (nodename == "moonrealm:air" or nodename == "air") then
					if math.random(13) == 2 then
						minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="default:apple"})
					else
						minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="moonrealm:leaves"})
					end
				end
			end
			end
		end
		minetest.add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
	end
	print ("[moonrealm] Appletree sapling grows")
end

-- Vacuum or air flows into a dug hole from face-connected neighbours only

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

-- ABMs

-- Air spreads into face-connected neighbours

local AIR = false
if AIR then
minetest.register_abm({
	nodenames = {"moonrealm:air"},
	neighbors = {"moonrealm:vacuum"},
	interval = 29,
	chance = 1,
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
					print ("[moonrealm] Hydroponic liquid saturates")
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
		print ("[moonrealm] Moon soil dries")
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