local physic = require 'physic'
local hsl = require 'hsl'

local Level = {
	buffer=nil,
}
Level.__index = Level

function Level:init()
	for i, b in pairs(self.boxes) do
		local shape = physic.new_shape('box', b.w, b.h)
		shape:set_friction(0)
		shape:set_restitution(0.35)
		b.body = physic.new_body(shape, false)
		b.body:set_position(b.x + b.w/2, b.y + b.h/2) -- cause the box is centered
		b.body.is_wall = true
	end
	do
		local ar = self.arrival
		local shape = physic.new_shape('circle', ar.w)
		shape:set_sensor(true)
		ar.body = physic.new_body(shape, false)
		ar.body:set_position(ar.x + ar.w/2, ar.y + ar.h/2)
	end
	for _, c in pairs(self.capsules) do
		local shape = physic.new_shape('circle', c.size)
		shape:set_sensor(true)
		c.body = physic.new_body(shape, false)
		c.body:set_position(c.x, c.y)
		c.body.is_capsule = true
		c.body.parent = c
		c.is_visible = true
	end
end

function Level:destroy()
	for i, b in pairs(self.boxes) do
		b.body:destroy()
	end
	self.arrival.body:destroy()
	for _, c in pairs(self.capsules) do
		c.body:destroy()
	end
end

function Level:draw(offsetx, offsety)
	local ct = require 'content'
	if not self.buffer then

		self.buffer = new_buffer()
		use_buffer(self.buffer)

		push_offset(0, 0)
		local R = self.ratio

		for i, b in pairs(self.boxes) do
			local w, h = b.w*R, b.h*R
			local x = b.x * R
			local y = b.y * R
			local outline = 4

			set_color(b.outoutcolor)
			draw_rect(x, y, w, h)

			set_color(b.outcolor)
			draw_rect(x+outline, y+outline, w-outline*2, h-outline*2)

			outline = outline * 2
			set_color(b.color)
			draw_rect(x+outline, y+outline, w-outline*2, h-outline*2)
		end

		pop_offset()

		use_buffer()
	end

	local R = self.ratio
	draw_buffer(self.buffer, offsetx, offsety)

	local st = self.start
	local sprite = ct.sprites.start
	set_color(st.color)
	draw_sprite_resized(sprite, st.x*R - st.w*R/2, st.y*R - st.h*R/2, st.w*R, st.h*R)

	local st = self.arrival
	local sprite = ct.sprites.arrival
	set_color(st.color)
	draw_sprite_resized(sprite, st.x*R - st.w*R/2, st.y*R - st.h*R/2, st.w*R, st.h*R)

	for i, c in pairs(self.capsules) do
		if c.is_visible then
			local sprite
			if c.type == 'fuel' then
				sprite = ct.sprites.fuel_capsule
			else
				sprite = ct.sprites.health_capsule
			end
			set_color(c.color)
			draw_sprite_resized(sprite, c.x*R-sprite.w/2, c.y*R-sprite.h/2)
		end
	end
end

local function load_level(name, hue)
	local level = require(name)

	local function gencolors()
		local h = (hue+math.random(-5,5)) % 360
		local s = math.random(50, 70)/100
		local l = math.random(30, 50)/100
		return hsl(h, s, l),
				hsl(h, s, l-0.2),
				hsl(h, s, l-0.4)
	end

	level.start.w = 3
	level.start.h = 3
	level.start.color = {0, 255, 0}

	level.arrival.w = 3
	level.arrival.h = 3
	level.arrival.color = {0, 0, 255}

	local color = hsl(hue, 0.5, 0.8)
	level.background = color

	for _, b in pairs(level.boxes) do
		b.color, b.outcolor, b.outoutcolor = gencolors()
	end
	for _, c in pairs(level.capsules) do
		c.color = {255, 0, 0}
		c.size = 0.5
		c.visible = true
	end

	level.ratio = 16
	return setmetatable(level, Level)
end

local levels = {
	load_level('level1', 130),
	load_level('level2', 0),
}

return levels
