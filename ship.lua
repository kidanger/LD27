local physic = require 'physic'
local timer = require 'hump/timer'
local ct = require 'content'

local ship = {
	w=4, -- in meters
	h=2.2,
	color={255, 255, 255},

	body=nil,

	colliding=true,
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
}

function ship:init(level, x, y)
	assert(not self.body)
	local realw = self.w * 0.8
	local realh = self.h * 0.5
	local shape = physic.new_shape('box', realw, realh, realw*0.1, 0)
	self.body = physic.new_body(shape, true)
	self.body:set_position(x + realw / 2, y + realh / 2)
	self.body:set_angular_damping(5)
	self.body:set_linear_damping(0.4)
	self.body:set_mass_center(realw*0.1, 0)

	self.level = level
end
function ship:destroy()
	assert(self.body)
	self.body:destroy()
	self.body = nil
end

function ship:draw()
	set_alpha(255)
	set_color(self.color)

	local x, y = self.body:get_position()
	local angle = self.body:get_angle()
	local R = self.level.ratio

	local sprite = ct.sprites.ship
	if self.activated then
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
	if self.activated then
		local angle = self.body:get_angle()
		local dx = math.cos(angle) * dt * self.engine_power
		local dy = math.sin(angle) * dt * self.engine_power
		self.body:apply_linear_impulse(dx, dy)
		self.fuel = self.fuel - dt
	end
	if self.right then
		self.body:set_angular_velocity(20*dt + self.body:get_angular_velocity())
	end
	if self.left then
		self.body:set_angular_velocity(-20*dt + self.body:get_angular_velocity())
	end

	if self.collisions > 0 then
		self:take_damage(dt)
	end
end

function ship:take_damage(dmg)
	local health = self.health - dmg
	if health < 0 then
		health = 0
	end
	timer.tween(1, self, {health=health})
end

function ship:regen_health()
	--self.health = self.max_health
	timer.tween(1, self, {health=self.max_health})
end

function ship:regen_fuel()
	self.fuel = self.max_fuel
end

function ship:collide()
	local dmgx, dmgy = self.body:get_linear_velocity()
	local dmg = (math.abs(dmgx) + math.abs(dmgy)) / 20
	self:take_damage(dmg)
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
