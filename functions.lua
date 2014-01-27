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
	print ("[moonrealm] Appletree sapling grows ("..x.." "..y.." "..z..")")
end