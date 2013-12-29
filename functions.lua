function moonrealm_pine(pos)
	local env = minetest.env
	local x = pos.x
	local y = pos.y
	local z = pos.z
	local t = math.random(6, 9)
	for j = -3, -1 do
		local nodename = env:get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moonrealm:moonsoil" then
			return
		end
	end
	for j = 1, t do
		local nodename = env:get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moonrealm:air" and nodename ~= "air" then
			return
		end
	end
	for j = -3, t - 2 do
		env:add_node({x=x,y=y+j,z=z},{name="default:tree"})
		if j >= 1 and j <= t - 4 then
			for i = -1, 1 do
			for k = -1, 1 do
				if i ~= 0 or k ~= 0 then
					env:add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:needles"})
				end
			end
			end
		elseif j >= t - 3 then
			for i = -1, 1 do
			for k = -1, 1 do
				if (i == 0 and k ~= 0) or (i ~= 0 and k == 0) then
					env:add_node({x=x+i,y=y+j,z=z+k},{name="moonrealm:needles"})
				end
			end
			end
		end
	end
	for j = t - 1, t do
		env:add_node({x=x,y=y+j,z=z},{name="moonrealm:needles"})
	end
	print ("[moonrealm] Pine sapling grows ("..x.." "..y.." "..z..")")
end