local physic = require 'physic'
local ct = require 'content'
local ship = require 'ship'

local gamestate = {
	level=0,
	ship=ship,
	scrollx=0,
	scrolly=0,
}

physic.create_world(0, 4)

function gamestate:change_level(lvlnumber)
	if self.level ~= 0 then
		local oldlvl = ct.levels[self.level]
		oldlvl:destroy()
		self.ship:destroy()
	end

	self.level = lvlnumber

	local lvl = ct.levels[self.level]
	lvl:init()
	self.ship:init(lvl, lvl.start.x, lvl.start.y)
end

function gamestate:draw()
	set_color(200, 200, 200)
	draw_background()

	local lvl = ct.levels[self.level]

	local sx = self.scrollx - self.ship:get_screen_x() + width/2
	local sy = self.scrolly - self.ship:get_screen_y() + height/2

	push_offset(sx, sy)

	lvl:draw(-sx*2, sy*2)
	self.ship:draw()

	pop_offset()
end

function gamestate:update(dt)
	ship:update(dt)
	physic.update(dt)
end

function gamestate:key_press(key)
	if key == 'up' then
		self.ship:gofoward()
	elseif key == 'right' then
		self.ship:rotateright()
	elseif key == 'left' then
		self.ship:rotateleft()
	end
end
function gamestate:key_release(key)
	if key == 'up' then
		self.ship:stop_gofoward()
	elseif key == 'right' then
		self.ship:stop_rotateright()
	elseif key == 'left' then
		self.ship:stop_rotateleft()
	end
end

local scrolling = false
function gamestate:mouse_press(x, y, b)
	if b == 3 then
		scrolling = true
	end
end
function gamestate:mouse_release(x, y, b)
	if b == 3 then
		scrolling = false
	end
end
function gamestate:mouse_motion(x, y, dx, dy)
	if scrolling then
		self.scrollx = self.scrollx + dx*2
		self.scrolly = self.scrolly + dy*2
	end
end

return gamestate
