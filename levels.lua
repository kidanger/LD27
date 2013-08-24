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

		set_color(50, 50, 50)
		for i, b in pairs(self.boxes) do
			set_color(b.color)
			local w, h = b.w*R, b.h*R
			local x = b.x * R
			local y = b.y * R
			draw_rect(x, y, w, h)
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

local function load_level(name, hue)
	local level = require(name)

	local function gencolor()
		local s = math.random(20, 40)/100
		local l = math.random(30, 50)/100
		return hsl(hue+math.random(-5,5), s, l)
	end

	level.start.w = 3
	level.start.h = 3
	level.start.color = {0, 255, 0}

	level.arrival.w = 3
	level.arrival.h = 3
	level.arrival.color = {0, 0, 255}

	local color = hsl(hue, 0.5, 0.7)
	level.background = {
		math.min(255, color[1]+90),
		math.min(255, color[2]+90),
		math.min(255, color[3]+90),
	}

	for _, b in pairs(level.boxes) do
		b.color = gencolor()
	end
	for _, c in pairs(level.capsules) do
		c.color = {255, 0, 0}
		c.size = 0.5
	end

	level.ratio = 16
	return setmetatable(level, Level)
end

local levels = {
	load_level('level1', 130),
	load_level('level2', 10),
}

return levels
