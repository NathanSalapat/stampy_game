minetest.register_node("hopper:hopper", {
	description = "Hopper",
	tiles = {"hopper_top.png", "hopper_outside.png", "hopper_outside.png", "hopper_outside.png", "hopper_outside.png", "hopper_outside.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
				{-16/32, 1/6, -0.5,             -12/32, .5, 0.5},
				{12/32, 1/6, -0.5,              16/32, .5, 0.5},
				{-0.5, 1/6, -16/32,             0.5, .5, -12/32},
				{-0.5, 1/6, 12/32,              0.5, .5, 16/32},
				{-.5, 1/6, -.5,                 .5, 1/6+2/32, .5}, 
				{-0.5+3/16, -1/6, -0.5+3/16,    0.5-3/16, 1/6, 0.5-3/16},
				{-0.5+6/16, -0.5, -0.5+6/16,    0.5-6/16, -1/6, 0.5-6/16},
			},
		},
	inventory_image = "hopper.png",
	groups = {cracky=2,level=1},
})

minetest.register_abm({
	nodenames = {"hopper:hopper"},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		local objs = minetest.env:get_objects_inside_radius({x=pos.x, y=pos.y+1, z=pos.z}, .8)
		for i, obj in ipairs(objs) do
			if not obj:is_player() then
				local o = obj:get_luaentity()
				if o.get_staticdata then
					local q = o:get_staticdata()
					local p = minetest.deserialize(q)
					local stack = ItemStack(p.itemstring)
					local cpos = minetest.find_node_near(pos, 1.5, {"default:chest"})
					if cpos and not stack:is_empty() then
						local meta = minetest.env:get_meta(cpos)
						local inv = meta:get_inventory()
						if inv:room_for_item("main", stack) then
							inv:add_item("main", stack)
							obj:remove()
						end
					end
				end
			end
		end
	end
})


minetest.register_craft({
	output = 'hopper:hopper',
	recipe = {
		{'default:steel_ingot', '',                    'default:steel_ingot'},
		{'default:steel_ingot', 'default:chest',       'default:steel_ingot'},
		{'',                    'default:steel_ingot', ''},
	}
})


