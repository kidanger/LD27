local physic = require 'physic'
local timer = require 'hump/timer'
local ct = require 'content'

local ship = {
	w=4, -- in meters
	h=2.2,
	color={255, 255, 255},

	body=nil,

	health=10,
	max_health=10,

	activated=false,
	fuel=10,
	max_fuel=10,

	engine_power=70,

	right=false,
	left=false,

	collisions=0,

	level=nil,

	dying=false,
	die_ended=false,
}

function ship:init(level, x, y)
	assert(not self.body)
	local realw = self.w * 0.8
	local realh = self.h * 0.5
	local shape = physic.new_shape('box', realw, realh, realw*0.1, 0)
	self.body = physic.new_body(shape, true)
	self.body:set_position(x + realw / 2, y + realh / 2)
	self.body:set_angular_damping(5)
	self.body:set_linear_damping(0.2)
	self.body:set_mass_center(realw*0.1, 0)

	self.level = level
	self.fuel = self.max_fuel
	self.health = self.max_health
	self.dying = false
	self.die_ended = false
	self.collisions = 0
	self.health_handle = nil
end

function ship:destroy()
	assert(self.body)
	self.body:destroy()
	self.body = nil
	if self.health_handle then
		timer.cancel(self.health_handle)
	end
end

function ship:draw()
	set_alpha(255)
	if self.dying then
		set_alpha(120)
	end
	set_color(self.color)

	local x, y = self.body:get_position()
	local angle = self.body:get_angle()
	local R = self.level.ratio

	local sprite = ct.sprites.ship
	if self.activated and self.fuel > 0 and self.health > 0 then
		sprite = ct.sprites.ship_engine
	end
	local transform = {
		angle=angle,
		wfactor=self.w*R / sprite.w,
		hfactor=self.h*R / sprite.h,
	}
	draw_sprite(sprite, (x-self.w/2)*R, (y-self.h/2)*R, transform)
	set_alpha(100)
end

function ship:update(dt)
	if self.activated and self.health > 0 then
		if self.fuel > 0 then
			local df = math.min(self.fuel, dt)
			local angle = self.body:get_angle()
			local dx = math.cos(angle) * df * self.engine_power
			local dy = math.sin(angle) * df * self.engine_power
			self.body:apply_linear_impulse(dx, dy)
			self.fuel = self.fuel - df
			-- sound
		else
			-- sound
		end
	end
	if self.right then
		self.body:set_angular_velocity(20*dt + self.body:get_angular_velocity())
	end
	if self.left then
		self.body:set_angular_velocity(-20*dt + self.body:get_angular_velocity())
	end

	if self.collisions > 0 then
		local factor = self.fuel > 0 and 1 or 5
		self:take_damage(dt * factor)
		-- sound
	end
end

function ship:die(duration)
	self.dying = true
	local function sign() return math.random(1, 2) == 1 and 1 or -1 end
	local dx, dy = math.random(40, 40)*sign(), math.random(40, 40)*sign()
	timer.add(duration, function() self.die_ended = true end)

	local cumul = 5
	local function randomstuff()
		self.body:set_linear_velocity(dx, dy)
		cumul = cumul * 1.7
		self.body:set_angular_velocity(cumul)
	end
	randomstuff()
	timer.addPeriodic(0.3, function()
		randomstuff()
		return not self.die_ended and self.dying
	end, math.max(0, duration/0.3 - 2))
end

function ship:take_damage(dmg)
	if self.health_handle then
		timer.cancel(self.health_handle)
		self.health = self.health_handle.dst
	end
	local health = self.health - dmg
	if health < 0 then
		health = 0
	end
	self.health_handle = timer.tween(0.7, self, {health=health})
	self.health_handle.dst = health
end

function ship:regen_health()
	if self.health_handle then
		if self.health_handle.dst == self.max_health then
			return
		end
		timer.cancel(self.health_handle)
		self.health = self.health_handle.dst
	end
	local health = self.max_health
	self.health_handle = timer.tween(0.7, self, {health=health}, 'bounce')
	self.health_handle.dst = health
	-- sound
end

function ship:regen_fuel()
	self.fuel = self.max_fuel
end

function ship:collide()
	local dmgx, dmgy = self.body:get_linear_velocity()
	local dmg = (math.abs(dmgx) + math.abs(dmgy)) / 20
	self:take_damage(dmg)
	-- sound
end

function ship:get_screen_x()
	local x = self.body:get_position()
	local R = self.level.ratio
	return x * R
end
function ship:get_screen_y()
	local _, y = self.body:get_position()
	local R = self.level.ratio
	return y * R
end

function ship:gofoward()
	self.activated = true
end
function ship:stop_gofoward()
	self.activated = false
end

function ship:rotateright()
	self.right = true
end
function ship:rotateleft()
	self.left = true
end

function ship:stop_rotateright()
	self.right = false
end
function ship:stop_rotateleft()
	self.left = false
end

return ship
