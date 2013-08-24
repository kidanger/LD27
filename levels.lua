local physic = require 'physic'

local Level = {
	buffer=nil,
}
Level.__index = Level

function Level:init()
	for i, b in pairs(self.boxes) do
		local shape = physic.new_shape('box', b.w, b.h)
		b.body = physic.new_body(shape, false)
		b.body:set_position(b.x + b.w/2, b.y + b.h/2) -- cause the box is centered
	end
end

function Level:destroy()
	for i, b in pairs(self.boxes) do
		b.body:destroy()
	end
end

function Level:draw(offsetx, offsety)
	if not self.buffer then
		self.buffer = new_buffer()
		use_buffer(self.buffer)

		local R = self.ratio

		set_color(50, 50, 50)
		for i, b in pairs(self.boxes) do
			local w, h = b.w*R, b.h*R
			local x = b.x * R
			local y = b.y * R
			draw_rect(x, y, w, h)
		end

		local st = self.start
		set_color(st.color)
		draw_rect(st.x*R, st.y*R, st.w*R, st.h*R)
		local st = self.arrival
		set_color(st.color)
		draw_rect(st.x*R, st.y*R, st.w*R, st.h*R)


		use_buffer()
	end

	local R = self.ratio
	draw_buffer(self.buffer, offsetx, offsety)
end

local function load_level(name)
	local level = require(name)

	level.start.w = 1
	level.start.h = 1
	level.start.color = {0, 255, 0}

	level.arrival.w = 1
	level.arrival.h = 1
	level.arrival.color = {0, 0, 255}

	level.ratio = 16
	return setmetatable(level, Level)
end

local levels = {
	load_level('level1'),
}


return levels
