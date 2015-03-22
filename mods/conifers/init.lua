-- Structure definitions.

local TRUNK_MINHEIGHT = 7
local TRUNK_MAXHEIGHT = 25

local LEAVES_MINHEIGHT = 2
local LEAVES_MAXHEIGHT = 6
local LEAVES_MAXRADIUS = 5
local LEAVES_NARROWRADIUS = 3 -- For narrow typed conifers.

local CONIFERS_DISTANCE = 4
local CONIFERS_ALTITUDE = 22

local REMOVE_TREES = false -- Remove trees above CONIFERS_ALTITUDE? It kills default trees from the top.

local SAPLING_CHANCE = 100 -- 1/x chances to grow a sapling.

local INTERVAL = 3600

local conifers_seed = 1435

-- End of structure definitions.



conifers = {}



--------------------------------------------------------------------------------
--
-- Definitions
--
--------------------------------------------------------------------------------

--
-- Node definitions
--
minetest.register_node("conifers:trunk", {
	description = "Conifer trunk",
	tile_images = { 
		"conifers_trunktop.png", 
		"conifers_trunktop.png", 
		"conifers_trunk.png", 
	},
	--inventory_image = minetest.inventorycube(
		--"conifers_trunktop.png", 
		--"conifers_trunk.png", 
		--"conifers_trunk.png"
	--),
	paramtype = "facedir_simple",
	material = minetest.digprop_woodlike(1.0),
	groups = {
		tree = 1,
		snappy = 2,
		choppy = 2,
		oddly_breakable_by_hand = 1,
		flammable = 2
	},
	sounds = default.node_sound_wood_defaults()
})

local tex_reversed_trunk = "conifers_trunk.png^[transformR90"
minetest.register_node("conifers:trunk_reversed", {
	description = "Conifer reversed trunk",
	tile_images = { 
		tex_reversed_trunk, 
		tex_reversed_trunk,
		"conifers_trunktop.png", 
		"conifers_trunktop.png", 
		tex_reversed_trunk, 
	},
	--inventory_image = minetest.inventorycube(
		--"conifers_trunk.png",
		--"conifers_trunktop.png",
		--"conifers_trunk.png"
	--),
	paramtype = "facedir_simple",
	material = minetest.digprop_woodlike(1.0),
	legacy_facedir_simple = true,
	groups = {
		tree = 1,
		snappy = 2,
		choppy = 2,
		oddly_breakable_by_hand = 1,
		flammable = 2
	},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("conifers:leaves", {
	description = "Conifer leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tile_images = { "conifers_leaves.png" },
	--inventory_image = "conifers_leaves.png",
	paramtype = "light",
	groups = {
		snappy = 3,
		--leafdecay = 3,
		flammable = 2
	},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'conifers:sapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'conifers:leaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_node("conifers:leaves_special", {
	description = "Bright conifer leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tile_images = { "conifers_leaves_special.png" },
	--inventory_image = "conifers_leaves_special.png",
	paramtype = "light",
	groups = {
		snappy = 3,
		--leafdecay = 3,
		flammable = 2
	},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'conifers:sapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'conifers:leaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_node("conifers:sapling", {
	description = "Conifer sapling",
	drawtype = "plantlike",
	tile_images = {"conifers_sapling.png"},
	inventory_image = "conifers_sapling.png",
	wield_image = "conifers_sapling.png",
	paramtype = "light",
	walkable = false,
	groups = {
		snappy = 2,
		dig_immediate = 3,
		flammable = 2
	},
	sounds = default.node_sound_defaults(),
})


conifers_c_air = minetest.get_content_id("air")
conifers_c_tree = minetest.get_content_id("default:tree")
conifers_c_leaves = minetest.get_content_id("default:leaves")
conifers_c_dirt_with_grass = minetest.get_content_id("default:dirt_with_grass")

conifers_c_con_trunk = minetest.get_content_id("conifers:trunk")
conifers_c_con_leaves = minetest.get_content_id("conifers:leaves")
conifers_c_con_leaves_special = minetest.get_content_id("conifers:leaves_special")


--
-- Craft definitions
--
minetest.register_craft({
	output = "conifers:trunk_reversed 2",
	recipe = {
		{"conifers:trunk", "conifers:trunk"},
	}
})

minetest.register_craft({
	output = "conifers:trunk 2",
	recipe = {
		{"conifers:trunk_reversed"},
		{"conifers:trunk_reversed"}
	}
})

minetest.register_craft({
	output = 'default:wood 4',
	recipe = {
		{'conifers:trunk'}
	}
})

minetest.register_craft({
	output = 'default:wood 4',
	recipe = {
		{'conifers:trunk_reversed'}
	}
})


--
-- ABM definitions
--
-- Spawn random conifers.
local function get_conifers_random(pos)
	return PseudoRandom(math.abs(pos.x+pos.y*3+pos.z*5)+conifers_seed)
end
minetest.register_abm({
	nodenames = "default:dirt_with_grass",
	interval = INTERVAL,
	chance = 9.1,
	
	action = function(pos)
		local pr = get_conifers_random(pos)
		local p = {x=pos.x, y=pos.y+1, z=pos.z}
		if pr:next(1,23) == 1
   		and minetest.get_node(p).name == "air"
   		and pos.y >= CONIFERS_ALTITUDE
   		and (not conifers:is_node_in_cube({"conifers:trunk"}, pos, CONIFERS_DISTANCE)) then
   			conifers:make_conifer(p, math.random(0, 1))
		end
	end
})

-- Saplings.
minetest.register_abm({
	nodenames = "conifers:sapling",
	interval = INTERVAL,
	chance = SAPLING_CHANCE,
	
	action = function(pos, node)
   		if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "air" then
   			conifers:make_conifer(pos, math.random(0, 1))
   		end
	end
})

-- Should we remove all the trees above the conifers altitude?
if REMOVE_TREES == true then
	minetest.register_abm({
		nodenames = {
			"default:tree", 
			"default:leaves"
		},
		interval = INTERVAL/100,
		chance = 1,
		
		action = function(pos, node)
			if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "air"
			and pos.y >= CONIFERS_ALTITUDE then
				minetest.add_node(pos , {name = "air"})
			end
		end
	})
end



--------------------------------------------------------------------------------
--
-- Functions
--
--------------------------------------------------------------------------------

--
-- table_contains(t, v)
--
-- Taken from the Flowers mod by erlehmann.
--
function conifers:table_contains(t, v)
	for _,i in ipairs(t) do
		if i == v then
			return true
		end
	end
	return false
end

--
-- is_node_in_cube(nodenames, node_pos, radius)
--
-- Taken from the Flowers mod by erlehmann.
--
function conifers:is_node_in_cube(nodenames, pos, size)
	local hs = math.floor(size / 2)
	for x = pos.x-size, pos.x+size do
		for y = pos.y-hs, pos.y+hs do
			for z = pos.z-size, pos.z+size do
				n = minetest.get_node_or_nil({x=x, y=y, z=z})
				if n == nil
				or n.name == 'ignore'
				or conifers:table_contains(nodenames, n.name) then
					return true
				end
			end
		end
	end
	return false
end

--
-- are_leaves_surrounded(position)
--
-- Return a boolean value set to 'true' if a leaves block is surrounded
-- by something else than
--  - air
--  - leaves
--  - special leaves
--
-- If a leaves block is surrounded by the blocks above, 
-- it can be placed.
-- Otherwise, it will replace blocks we want to keep.
--
function conifers:are_leaves_surrounded(pos)
	--
	-- Check if a leaves block does not interfer with something else than the air or another leaves block.
	--
	local replacable_nodes = {conifers_c_air, conifers_c_con_leaves, conifers_c_con_leaves_special}

	-- Let's check if the neighboring node is a replacable node.
	for i = -1,1,2 do
		if (not conifers:table_contains(replacable_nodes, nodes[area:index(pos.x+i, pos.y, pos.z)]))
		or (not conifers:table_contains(replacable_nodes, nodes[area:index(pos.x, pos.y, pos.z+i)])) then
			return true
		end
	end
	return false
end

--
-- add_leaves_block(position, type of leaves, near trunk?)
--
-- Put a simple leaves block.
-- Leaves must be positioned near a trunk or surrounded by air.
-- Types of leaves are:
-- 	0: dark leaves
--	1: bright leaves (special)
--
function conifers:add_leaves_block(pos, special, near_trunk)
	if (not conifers:are_leaves_surrounded(pos))
	or near_trunk then
		local p_pos = area:index(pos.x, pos.y, pos.z)
		if special == 0 then
			nodes[p_pos] = conifers_c_con_leaves
		else
			nodes[p_pos] = conifers_c_con_leaves_special
		end
	end
end

-- Put a small circle of leaves around the trunk.
--    [ ]
-- [ ][#][ ]
--    [ ]
function conifers:add_small_leaves_circle(c, special)
	for i = -1,1,2 do
		conifers:add_leaves_block({x=c.x+i, y=c.y, z=c.z}, special, true)
		conifers:add_leaves_block({x=c.x, y=c.y, z=c.z+i}, special, true)
	end
end

--
-- make_leaves(middle point, min radius, max radius, type of leaves)
--
-- Make a circle of leaves with a center given by 'middle point'.
-- Types of leaves are:
-- 	0: dark leaves
--	1: bright leaves (special)
--
function conifers:make_leaves(c, radius_min, radius_max, special)
	if radius_max <= 1 then
		conifers:add_small_leaves_circle(c, special)
		return
	end
	--
	-- Using the midpoint circle algorithm from Bresenham we can trace a circle of leaves.
	--
	for r = radius_min, radius_max do
		local m_x = 0
		local m_z = r
		local m_m = 5 - 4 * r		
		while m_x <= m_z do
			if r == 1 then
				-- Add a square of leaves (fixing holes near the trunk).
				-- [ ]   [ ]
				--    [#]
				-- [ ]   [ ]
				for i = 1,-1,-2 do
					for j = -1,1,2 do
						conifers:add_leaves_block({x=c.x+j, y=c.y, z=c.z+i}, special)
					end
				end

				conifers:add_small_leaves_circle(c, special)
			else
				for i = -1,1,2 do
					for j = -1,1,2 do
						for _,a in ipairs({{m_x, m_z}, {m_z, m_x}}) do
							conifers:add_leaves_block({x=j*a[1]+c.x, y=c.y, z=i*a[2]+c.z}, special)
						end
					end
				end
			end
			-- Stuff...
			if m_m > 0 then
				m_z = m_z - 1
				m_m = m_m - 8 * m_z
			end
			m_x = m_x + 1
			m_m = m_m + 8 * m_x + 4
		end
	end
end

--
-- make_conifer(position, type)
--
-- Make a conifer at a given position.
-- Types are:
-- 	0: regular pine
--	1: narrow pine
--
function conifers:make_conifer(pos, conifer_type)
	local height = math.random(TRUNK_MINHEIGHT, TRUNK_MAXHEIGHT) -- Random height of the conifer.

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local vwidth = LEAVES_MAXRADIUS+1
	local emerged_pos1, emerged_pos2 = manip:read_from_map({x=pos.x-vwidth, y=pos.y, z=pos.z-vwidth},
		{x=pos.x+vwidth, y=pos.y+height+1, z=pos.z+vwidth})

	area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	nodes = manip:get_data()

	-- Check if we can gros a conifer at this place.
	local p_pos = area:index(pos.x, pos.y, pos.z)
	local d_p_pos = nodes[p_pos]

	if nodes[area:index(pos.x, pos.y-1, pos.z)] ~= conifers_c_dirt_with_grass
	and (d_p_pos ~= conifers_c_air
		or d_p_pos ~= conifers_c_con_sapling
	) then
		return false
	--else
		--if minetest.get_node({x = pos.x, y = pos.y, z = pos.z}).name == "conifers:sapling" then
			--minetest.add_node(pos , {name = "air"})
		--end
	end

	-- Let's check if we can grow a tree here.
	-- That means, we must have a column of 'height' high which contains
	-- only air.
	for j = 1, height - 1 do -- Start from 1 so we can grow a sapling.
		if nodes[area:index(pos.x, pos.y+j, pos.z)] ~= conifers_c_air then
			-- Abort
			return false
		end
	end

	local leaves_height = math.random(LEAVES_MINHEIGHT, LEAVES_MAXHEIGHT) -- Level from where the leaves grow.
	local current_block = {} -- Duh...
	local leaves_radius = 1
	local leaves_max_radius = 2
	local special = math.random(0, 1)

	-- Create the trunk and add the leaves.
	for i = 0, height - 1 do
		current_block = {x=pos.x, y=pos.y+i, z=pos.z}
		-- Put a trunk block.
		nodes[area:index(pos.x, pos.y+i, pos.z)] = conifers_c_con_trunk
		-- Put some leaves.
		if i >= leaves_height then
			-- Put some leaves.
			conifers:make_leaves({x=pos.x, y=pos.y+leaves_height+height-1-i, z=pos.z}, 1, leaves_radius, special)
			--
			-- TYPE OF CONIFER
			--
			if conifer_type == 1 then -- Regular type
				-- Prepare the next circle of leaves.
				leaves_radius = leaves_radius+1
				-- Check if the current radius is the maximum radius at this level.
				if leaves_radius > leaves_max_radius then
					leaves_radius = 1
					-- Does it exceeds the maximum radius?
					if leaves_max_radius < LEAVES_MAXRADIUS then
						leaves_max_radius = leaves_max_radius+1
					end
				end
			else -- Narrow type
				if i % 2 == 0 then
					leaves_radius = LEAVES_NARROWRADIUS-math.random(0,1)
				else
					leaves_radius = math.floor(LEAVES_NARROWRADIUS/2)
				end
			end
		end
	end

	-- Put a top leaves block.
	current_block.y = current_block.y+1
	conifers:add_leaves_block(current_block, special)

	manip:set_data(nodes)
	manip:write_to_map()
	print (string.format('[conifers] A conifer has grown at '..
		'('..pos.x..','..pos.y..','..pos.z..')'..
		' with a height of '..height..
		' after ca. %.2fs', os.clock() - t1)
	)	-- Blahblahblah
	local t1 = os.clock()
	manip:update_map()
	print (string.format('[conifers] map updated after ca. %.2fs', os.clock() - t1))
	return true
end
