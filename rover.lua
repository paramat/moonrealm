-- Parameters


local ACDC = 0.15 -- Acceleration / decelleration
local TURNSP = 0.02 -- Maximum yaw speed


-- Functions

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end


local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end


local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end


-- Rover entity

local rover = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.7, 0.4, -0.7, 0.7, 1.0, 0.7},
	visual = "cube",
	visual_size = {x = 2.0, y = 2.0},
	textures = {
		-- Top, base, right, left, front, back
		"moonrealm_rover_top.png",
		"moonrealm_rover_base.png",
		"moonrealm_rover_right.png",
		"moonrealm_rover_left.png",
		"moonrealm_rover_front.png",
		"moonrealm_rover_back.png",
	},
	stepheight = 0,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
}


-- Rover item

minetest.register_craftitem("moonrealm:rover", {
	description = "Rover",
	inventory_image = "moonrealm_rover_front.png",
	wield_scale = {x = 2, y = 2, z = 2},

	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type == "node" and
				minetest.registered_nodes[node.name].walkable then
			under.y = under.y + 1.5
			local rover = minetest.add_entity(under, "moonrealm:rover")
			if rover then
				rover:setyaw(placer:get_look_horizontal())
				if not minetest.settings:get_bool("creative_mode") then
					itemstack:take_item()
				end
			end
		end

		return itemstack
	end,
})


-- Register entity

minetest.register_entity("moonrealm:rover", rover)


-- Rover entity functions

function rover:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end

	local name = clicker:get_player_name()
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		default.player_attached[name] = false
		default.player_set_animation(clicker, "stand" , 30)
	elseif not self.driver then
		local attach = clicker:get_attach()
		if attach and attach:get_luaentity() then
			local luaentity = attach:get_luaentity()
			if luaentity.driver then
				luaentity.driver = nil
			end
			clicker:set_detach()
		end
		self.driver = clicker
		clicker:set_attach(self.object, "",
			{x = 0, y = 3, z = -2}, {x = 0, y = 0, z = 0})
		default.player_attached[name] = true
		minetest.after(0.2, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		clicker:set_look_horizontal(self.object:getyaw())
	end
end


function rover.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function rover.get_staticdata(self)
	return tostring(self.v)
end


function rover.on_punch(self, puncher, time_from_last_punch,
		tool_capabilities, direction)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end
	if self.driver and puncher == self.driver then
		self.driver = nil
		puncher:set_detach()
		default.player_attached[puncher:get_player_name()] = false
	end
	if not self.driver then
		self.removed = true
		local inv = puncher:get_inventory()
		if not minetest.setting_getbool("creative_mode")
				or not inv:contains_item("main", "moonrealm:rover") then
			local leftover = inv:add_item("main", "moonrealm:rover")
			-- If no room in inventory add a replacement rover to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:getpos(), leftover)
			end
		end
		-- Delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
	end
end


function rover:on_step(dtime)
	local ctrl
	if self.driver then
		ctrl = self.driver:get_player_control()
	end
	if (not ctrl or not (ctrl.up or ctrl.down)) and
			vector.equals(self.object:getvelocity(), {x = 0, y = 0, z = 0}) then
		-- Either no driver or driver but no accelerator, and stationary
		return
	end

	-- Touching ground?
	local obj_pos = self.object:getpos()
	obj_pos.y = obj_pos.y - 1.1
	local under_pos = obj_pos
	local node_under = minetest.get_node(under_pos)
	local nodedef_under = minetest.registered_nodes[node_under.name]
	local touch_ground = nodedef_under.walkable

	local absv = get_v(self.object:getvelocity())
	self.v = absv * get_sign(self.v)

	if touch_ground then
		-- Acceleration and steering
		if self.driver then
			if ctrl.up then
				self.v = self.v + ACDC
			elseif ctrl.down then
				self.v = self.v - ACDC
			end

			local turn
			local maxturn = (1 + dtime * 2) * TURNSP
			if absv < 4 then
				turn = maxturn * absv / 4
			else
				turn = maxturn * (1 - (absv - 4) / 8)
			end
			if ctrl.left then
				self.object:setyaw(self.object:getyaw() + turn)
			elseif ctrl.right then
				self.object:setyaw(self.object:getyaw() - turn)
			end
		end

		-- Slowing from resistence
		local s = get_sign(self.v)
		self.v = self.v - 0.04 * s
		if s ~= get_sign(self.v) then
			self.object:setvelocity({x = 0, y = 0, z = 0})
			self.v = 0
			return
		end

		-- Limit to max speed
		if absv > 8 then
			self.v = 8 * get_sign(self.v)
		end
	end

	-- Vertical behaviour
	local obj_pos = self.object:getpos()
	obj_pos.y = obj_pos.y - 0.5
	local nodedef_in = minetest.registered_nodes[minetest.get_node(obj_pos).name]
	if nodedef_in.walkable then
		-- In node, jump up
		self.object:setacceleration({x = 0, y = 0, z = 0})
		self.object:setvelocity(get_velocity(self.v,
			self.object:getyaw(), math.max(absv / 2, 1)))
		self.object:setpos(self.object:getpos())
	else
		if not touch_ground then
			-- No node under, freefall
			self.object:setacceleration({x = 0, y = -1.962, z = 0})
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(),
				self.object:getvelocity().y))
			self.object:setpos(self.object:getpos())
		else
			-- Node under, on surface, check y velocity
			if self.object:getvelocity().y < 0 then
				-- Landing on surface
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y) + 0.5
				self.object:setacceleration({x = 0, y = 0, z = 0})
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
				self.object:setpos(pos)
			else
				-- On surface or jumping up through surface
				self.object:setacceleration({x = 0, y = 0, z = 0})
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(),
					self.object:getvelocity().y))
				self.object:setpos(self.object:getpos())
			end
			if node_under.name == "moonrealm:dust" or
					node_under.name == "moonrealm:dustprint1" or
					node_under.name == "moonrealm:dustprint2" then
				minetest.set_node(under_pos, {name = "moonrealm:dusttrack"})
			end
		end
	end
end
