local tmp = {}

minetest.register_entity("itemframes:item",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x=.33,y=.33},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	on_activate = function(self, staticdata)
		if tmp.nodename ~= nil and tmp.texture ~= nil then
			self.nodename = tmp.nodename
			tmp.nodename = nil
			self.texture = tmp.texture
			tmp.texture = nil
		else
			if staticdata ~= nil and staticdata ~= "" then
				local data = staticdata:split(';')
				if data and data[1] and data[2] then
					self.nodename = data[1]
					self.texture = data[2]
				end
			end
		end
		if self.texture ~= nil then
			self.object:set_properties({textures={self.texture}})
		end
		if self.nodename == "itemframes:pedestal" then
			self.object:set_properties({automatic_rotate=1})
		end
	end,
	get_staticdata = function(self)
		if self.nodename ~= nil and self.texture ~= nil then
			return self.nodename .. ';' .. self.texture
		end
		return ""
	end,
})


local facedir = {}
facedir[0] = {x=0,y=0,z=1}
facedir[1] = {x=1,y=0,z=0}
facedir[2] = {x=0,y=0,z=-1}
facedir[3] = {x=-1,y=0,z=0}

local remove_item = function(pos, node)
	local objs = nil
	if node.name == "itemframes:frame" then
		objs = minetest.get_objects_inside_radius(pos, .5)
	elseif node.name == "itemframes:pedestal" then
		objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y+1,z=pos.z}, .5)
	end
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "itemframes:item" then
				obj:remove()
			end
		end
	end
end

local update_item = function(pos, node)
	remove_item(pos, node)
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") ~= "" then
		if node.name == "itemframes:frame" then
			local posad = facedir[node.param2]
			if not posad then return end
			pos.x = pos.x + posad.x*6.5/16
			pos.y = pos.y + posad.y*6.5/16
			pos.z = pos.z + posad.z*6.5/16
		elseif node.name == "itemframes:pedestal" then
			pos.y = pos.y + 12/16+.33
		end
		tmp.nodename = node.name
		tmp.texture = ItemStack(meta:get_string("item")):get_name()
		local e = minetest.add_entity(pos,"itemframes:item")
		if node.name == "itemframes:frame" then
			local yaw = math.pi*2 - node.param2 * math.pi/2
			e:setyaw(yaw)
		end
	end
end

local drop_item = function(pos, node)
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") ~= "" then
		if node.name == "itemframes:frame" then
			minetest.add_item(pos, meta:get_string("item"))
		elseif node.name == "itemframes:pedestal" then
			minetest.add_item({x=pos.x,y=pos.y+1,z=pos.z}, meta:get_string("item"))
		end
		meta:set_string("item","")
	end
	remove_item(pos, node)
end

minetest.register_node("itemframes:frame",{
	description = "Item Frame",
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5} },
	selection_box = { type = "fixed", fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5} },
	tiles = {"itemframes_frame.png"},
	inventory_image = "item_frame.png",
	wield_image = "item_frame.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	groups = { choppy=2,dig_immediate=2 },
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then return end
		local meta = minetest.get_meta(pos)
		drop_item(pos,node)
		local s = itemstack:peek_item()
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		meta:set_string("item",s:to_string())
		update_item(pos,node)
		return itemstack
	end,
	on_punch = function(pos,node,puncher)
		local meta = minetest.get_meta(pos)
		if meta:get_string("item") ~= "" then
			drop_item(pos, node)
			return
		end
		minetest.remove_node(pos)
		minetest.add_item(pos, "itemframes:frame")
	end,
})


minetest.register_node("itemframes:pedestal",{
	description = "Pedestal",
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = {
		{-7/16, -8/16, -7/16, 7/16, -7/16, 7/16}, -- bottom plate
		{-6/16, -7/16, -6/16, 6/16, -6/16, 6/16}, -- bottom plate (upper)
		{-0.25, -6/16, -0.25, 0.25, 11/16, 0.25}, -- pillar
		{-7/16, 11/16, -7/16, 7/16, 12/16, 7/16}, -- top plate
	} },
	--selection_box = { type = "fixed", fixed = {-7/16, -0.5, -7/16, 7/16, 12/16, 7/16} },
	tiles = {"itemframes_pedestal.png"},
	paramtype = "light",
	groups = { cracky=3 },
	sounds = default.node_sound_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		if not itemstack then return end
		local meta = minetest.get_meta(pos)
		drop_item(pos,node)
		local s = itemstack:take_item()
		meta:set_string("item",s:to_string())
		update_item(pos,node)
		return itemstack
	end,
	on_punch = function(pos,node,puncher)
		local meta = minetest.get_meta(pos)
		drop_item(pos,node)
	end,
})

-- automatically restore entities lost from frames/pedestals
-- due to /clearobjects or similar

minetest.register_abm({
	nodenames = { "itemframes:frame", "itemframes:pedestal" },
	interval = 15,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "")
		local item = meta:get_string("item")
		if minetest.get_item_group(item, "clock") ~= 0 and minetest.get_item_group(item, "clock") ~= time then
			local time = math.floor((64 * (minetest.get_timeofday() + .5)) % 64 + 1)
			meta:set_string("item", "clock:"..time)
			update_item(pos, node)
		end
		if #minetest.get_objects_inside_radius(pos, 0.5) > 0 then return end
		update_item(pos, node)
	end
})

-- crafts

minetest.register_craft({
	output = 'itemframes:frame',
	recipe = {
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', 'mobs:leather',  'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'},
	}
})
minetest.register_craft({
	output = 'itemframes:frame',
	recipe = {
		{'moreblocks:jungle_stick', 'moreblocks:jungle_stick', 'moreblocks:jungle_stick'},
		{'moreblocks:jungle_stick', 'mobs:leather',            'moreblocks:jungle_stick'},
		{'moreblocks:jungle_stick', 'moreblocks:jungle_stick', 'moreblocks:jungle_stick'},
	}
})
minetest.register_craft({
	output = 'itemframes:pedestal',
	recipe = {
		{'default:stone', 'default:stone', 'default:stone'},
		{'', 'default:stone', ''},
		{'default:stone', 'default:stone', 'default:stone'},
	}
})
