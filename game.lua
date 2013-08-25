local physic = require 'physic'
local font = require 'truetype'
local timer = require 'hump/timer'
local ct = require 'content'
local ship = require 'ship'

local gamestate = {
	level=0,
	ship=ship,
	scrollx=0,
	scrolly=0,
	arrived=false,

	pause = false,

	display_text='',
	text_width=0,
	text_width_dst=width*.8,
	text_handle=nil,
	text_collides=0,

	hard=false,
}

physic.create_world(0, 6)

physic.on_collision(
	function (b1, b2)
		if b1.begin_collide then b1:begin_collide(b2) end
		if b2.begin_collide then b2:begin_collide(b1) end
	end,
	function (b1, b2)
		if b1.end_collide then b1:end_collide(b2) end
		if b2.end_collide then b2:end_collide(b1) end
	end
)

function gamestate:change_level(lvlnumber)
	if self.level ~= 0 then
		local oldlvl = ct.levels[self.level]
		oldlvl:destroy()
		self.ship:destroy()
	end

	self.level = lvlnumber
	self.display_text = ''
	if self.text_handle then
		timer.cancel(self.text_handle)
	end
	self.text_handle = nil
	self.text_width = 0
	self.text_collides = 0

	local lvl = ct.levels[self.level]
	lvl:init()
	self.ship:init(lvl, lvl.start.x, lvl.start.y)
	self.ship.body.begin_collide = function(_, other)
		if self.ship.dying then return end
		if other == lvl.arrival.body then
			self.arrived = true
		elseif other.is_capsule and other.parent.is_visible then
			local c = other.parent
			if c.type == 'health' then
				self.ship:regen_health()
			else
				self.ship:regen_fuel()
			end
			c.is_visible = false
		elseif other.is_wall then
			if self.ship.collisions == 0 then
				self.ship:collide()
			end
			self.ship.collisions = self.ship.collisions + 1
		elseif other.is_text then
			if self.text_collides == 0 then
				self.display_text = other.parent.string
				if self.text_handle then
					timer.cancel(self.text_handle)
				end
				self.text_handle = timer.tween(1, self, {text_width=self.text_width_dst}, 'bounce')
			end
			self.text_collides = self.text_collides + 1
		elseif other.is_rocket then
			self.ship:boom_rocket_inyourface()
		end
	end
	self.ship.body.end_collide = function(ship, other)
		if self.ship.dying then return end
		if other.is_wall then
			self.ship.collisions = self.ship.collisions - 1
		elseif other.is_text then
			self.text_collides = self.text_collides - 1
			if self.text_collides == 0 then
				if self.text_handle then
					timer.cancel(self.text_handle)
				end
				self.text_handle = timer.tween(1, self, {text_width=0}, 'bounce')
			end
		end
	end
end

local function coolround(num)
	local n = math.floor(num*10)/10
	if n == 0 and num ~= 0 then n = '0.1' end
	if n == math.floor(n) then
		return n .. '.0'
	end
	return n
end
local function lines(str)
	local t = {}
	local function helper(line) table.insert(t, line) return "" end
	helper((str:gsub("(.-)\r?\n", helper)))
	return t
end
function gamestate:draw()
	local lvl = ct.levels[self.level]

	set_alpha(255)
	set_color(lvl.background)
	draw_background()

	local sx = self.scrollx - self.ship:get_screen_x() + width/2
	local sy = self.scrolly - self.ship:get_screen_y() + height/2

	push_offset(sx, sy)

	lvl:draw(-sx*2, sy*2)
	self.ship:draw()

	pop_offset()

	set_alpha(255)
	set_color(0, 0, 0)
	font.use(ct.fonts.small)
	font.draw('Level: ' .. self.level .. '/' .. ct.max_level, 20, 3)
	do -- draw health
		set_alpha(200)
		set_color(0, 0, 0)
		local x, y = 20, 20
		local w = 140
		local h = 20
		draw_rect(x, y, w, h)

		set_color(120, 120, 120)
		x, y = x + 2, y + 2
		w = w - 4
		h = h - 4
		draw_rect(x, y, w, h)

		set_color(210, 0, 0)
		draw_rect(x, y, math.ceil(w*(self.ship.health / self.ship.max_health)), h)
		font.use(ct.fonts.small)
		set_color(0, 0, 0)
		font.draw_align('health: ' .. coolround(self.ship.health), x + w/2, y-1, 'center')
	end

	do -- draw fuel
		font.use(ct.fonts.big)
		--set_color(math.min(255, (1 - self.ship.fuel/self.ship.max_fuel)*255), 0, 0)
		set_color(0,0,0)
		set_alpha(math.min(255, math.max(100, (1 - self.ship.fuel/2/self.ship.max_fuel)*255)))
		local text = 'Fuel: ' .. coolround(self.ship.fuel) .. ' seconds'
		font.draw_align(text, width/2, 100, 'center')
	end

	if self.text_width >= 1 then
		font.use(ct.fonts.normal)
		font.use_color(true)
		local _, h = font.sizeof(self.display_text)
		local llines = lines(self.display_text)
		set_color(255,255,255)
		set_alpha(200)
		draw_rect((width-self.text_width)/2, height - 130 + h+4, self.text_width, (h+4)*#llines+h/4)
		if self.text_width >= self.text_width_dst*.85 then
			set_color(0,0,0)
			set_alpha(200)
			for i, l in ipairs(llines) do
				font.draw_align(l, width/2, height - 130 + (h+4)*i, 'center')
			end
		end
		font.use_color(false)
	end

	if self.pause then
		set_alpha(150)
		set_color(0, 0, 0)
		draw_rect(0, 0, width, height)

		set_alpha(255)
		font.use(ct.fonts.big)
		font.use_color(true)
		font.draw_align('Pause', width/2, height*.4, 'center')
		font.draw_align('Press {b50|P} to unpause', width/2, height*.6, 'center')
		font.use_color(false)
	end
end

function gamestate:update(dt)
	if self.pause then
		return
	end
	if self.arrived then
		if self.level < ct.max_level then
			ct.play('next_level')
			self:change_level(self.level + 1)
		else
			set_state(require 'ending')
		end
		self.arrived = false
	end
	if self.ship.health <= 0 and not self.ship.dying then
		self.ship:die(2)
	end
	if self.ship.die_ended then
		self:change_level(self.level)
	end
	local lvl = ct.levels[self.level]
	for _, t in ipairs(lvl.turrets) do
		t:update(dt)
	end
	ship:update(dt)
	physic.update(dt)
end

function gamestate:key_press(key)
	if key == 'up' then
		self.ship:goforward()
	elseif key == 'right' then
		self.ship:rotateright()
	elseif key == 'left' then
		self.ship:rotateleft()
	elseif key == 'return' then
		self.ship.health = 0
	elseif key == 'p' then
		self.pause = not self.pause
	end
	if key == 'f6' then
		self.arrived = true
	end
	if key == 'f7' then
		self.ship.health = 0
	end
end
function gamestate:key_release(key)
	if key == 'up' then
		self.ship:stop_goforward()
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
