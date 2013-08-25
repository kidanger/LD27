local physic = require 'physic'
local particle = require 'particle'
local timer = require 'hump/timer'
local ct = require 'content'

local ship = {
	w=4, -- in meters
	h=2.2,
	ow=4,
	oh=2.2,
	color={255, 255, 255},

	body=nil,

	health=10,
	max_health=10,

	health_handle=nil,
	size_handle=nil,

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
	playing_hurt=0,

	collide_part=particle.new_system(0, 0),
	explode_part=particle.new_system(0, 0),
	fuel_part=particle.new_system(0, 0),
}

ship.fuel_part:add_size(0, 5)
ship.fuel_part:add_size(.3, 10)
ship.fuel_part:add_size(1, 2)
ship.fuel_part:add_color(0, 255, 255, 255)
ship.fuel_part:add_color(0.15, 255, 255, 0)
ship.fuel_part:add_color(0.3, 255, 0, 0)
ship.fuel_part:add_color(0.7, 255, 100, 75)
ship.fuel_part:add_color(1, 0, 0, 0)
ship.fuel_part:set_lifetime(2.2)
ship.fuel_part:set_initial_velocity(20)
ship.fuel_part:set_initial_acceleration(50)

ship.explode_part:add_size(0, 3)
ship.explode_part:add_size(.4, 10)
ship.explode_part:add_size(1, 15)
ship.explode_part:add_color(0, 255, 0, 0)
ship.explode_part:add_color(0.2, 100, 150, 100, 150, 100, 150)
ship.explode_part:add_color(1, 0, 0, 0)
ship.explode_part:set_lifetime(5)
ship.explode_part:set_initial_velocity(60)
ship.explode_part:set_initial_acceleration(100)
ship.explode_part:set_emission_rate(20)
ship.explode_part:set_offset(30, 30)

ship.collide_part:add_size(0, 5)
ship.collide_part:add_size(1, 2)
ship.collide_part:add_color(0, 255, 0, 0)
ship.collide_part:add_color(0.2, 150, 150, 150)
ship.collide_part:add_color(1, 0, 50, 0, 50, 0, 50)
ship.collide_part:set_lifetime(1)
ship.collide_part:set_initial_velocity(50)
ship.collide_part:set_initial_acceleration(30)
ship.collide_part:set_emission_rate(30)
ship.collide_part:set_offset(10, 10)

function ship:init(level, x, y)
	assert(not self.body)
	self.w = self.ow
	self.h = self.oh

	local realw = self.w * 0.8
	local realh = self.h * 0.5
	local shape = physic.new_shape('box', realw, realh, realw*0.1, 0)
	self.body = physic.new_body(shape, true)
	self.body:set_position(x, y)
	self.body:set_angular_damping(5)
	self.body:set_linear_damping(0.2)
	self.body:set_mass_center(0.4, 0)
	self.body:set_angle(- math.pi/2)
	self.body:set_linear_velocity(0, -3)

	self.level = level
	self.fuel = self.max_fuel
	self.health = self.max_health
	self.dying = false
	self.die_ended = false
	self.collisions = 0
	self.health_handle = nil
	self.size_handle = nil

	self.left = false
	self.right = false
	self.activated = false

	self.fuel_part:pause()
	self.collide_part:pause()
	self.explode_part:pause()
end

function ship:destroy()
	assert(self.body)
	self.body:destroy()
	self.body = nil
	if self.health_handle then
		timer.cancel(self.health_handle)
		self.health_handle = nil
	end
	if self.size_handle then
		timer.cancel(self.size_handle)
		self.size_handle = nil
	end
	self.fuel_part:stop()
	self.collide_part:stop()
	self.explode_part:stop()
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
	local angle = self.body:get_angle() % (math.pi*2)
	if angle > math.pi/2 and angle < math.pi*3/2 then
		transform.hfactor = transform.hfactor * -1
	end
	draw_sprite(sprite, (x-self.w/2)*R, (y-self.h/2)*R, transform)

	local sx, sy = get_offset()
	set_alpha(150)
	self.fuel_part:draw(sx, sy)
	set_alpha(255)
	self.collide_part:draw(sx, sy)
	self.explode_part:draw(sx, sy)
end

function ship:update(dt)
	do -- update particle systems
		self.fuel_part:update(dt)
		self.collide_part:update(dt)
		self.explode_part:update(dt)
		local x, y = self.body:get_position()
		local angle = self.body:get_angle()
		local R = self.level.ratio
		x = x*R
		y = y*R
		self.fuel_part:set_position(x-math.cos(angle)*self.w/2*R, y-math.sin(angle)*self.h/2*R)
		self.fuel_part:set_direction(-angle-math.pi/6, -angle+math.pi/6)
		self.collide_part:set_position(x, y)
	end
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
		if self.playing_hurt == 0 then
			self.playing_hurt = 3
			timer.addPeriodic(math.random()/4, function()
				self.collide_part:emit()
				ct.play('littlehurt')
				self.playing_hurt = self.playing_hurt - 1
			end, 3)
		end
		local x, y = self.body:get_position()
		local R = self.level.ratio
	end
end

function ship:die(duration)
	self.fuel_part:stop()
	ct.play('explode')

	local function sign() return math.random(1, 2) == 1 and 1 or -1 end
	local dx, dy = 30*sign(), 30*sign()
	self.body:apply_angular_impulse(10)
	self.body:set_angular_damping(0)
	self.body:apply_linear_impulse(dx, dy)

	if self.size_handle then
		timer.cancel(self.size_handle)
	end
	self.size_handle = timer.tween(duration, self, {w=0.1, h=0.1}, 'in-out-quad')


	local x, y = self.body:get_position()
	local R = self.level.ratio
	self.explode_part:set_position(x*R, y*R)
	self.explode_part:set_direction(0, math.pi*2)
	self.explode_part:set_lifetime(duration)
	self.explode_part:start()

	self.dying = true
	timer.add(duration, function() self.die_ended = true end)
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
	self:to_health(health)
end

function ship:regen_health()
	ct.play('regen_health')

	if self.size_handle then
		timer.cancel(self.size_handle)
	end
	self.size_handle = timer.tween(0.5, self, {w=self.ow+1, h=self.oh+1}, 'in-bounce', function()
		if self.size_handle then
			timer.cancel(self.size_handle)
		end
		self.size_handle = timer.tween(0.5, self, {w=self.ow, h=self.oh}, 'quad')
	end)

	if self.health_handle then
		if self.health_handle.dst == self.max_health then
			return
		end
		timer.cancel(self.health_handle)
		self.health = self.health_handle.dst
	end
	local health = self.max_health
	self:to_health(health, 'bounce')
end

function ship:to_health(health, type)
	type = type or 'linear'
	local handle = timer.tween(0.7, self, {health=health}, type, function()
		if self.health_handle.dst == health then
			self.health = health
		end
	end)
	self.health_handle = handle
	self.health_handle.dst = health
end

function ship:regen_fuel()
	self.fuel = self.max_fuel
	ct.play('regen_fuel')
end

function ship:collide()
	local dmgx, dmgy = self.body:get_linear_velocity()
	local dmg = (math.abs(dmgx) + math.abs(dmgy)) / 30
	self:take_damage(dmg)
	ct.play('collide')

	local x, y = self.body:get_position()
	local R = self.level.ratio
	self.collide_part:set_position(x*R, y*R)
	self.collide_part:emit()
	self.collide_part:emit()
	self.collide_part:emit()
	self.collide_part:emit()

	if self.size_handle then
		timer.cancel(self.size_handle)
	end
	local w = math.min(self.ow*1.3, self.ow + math.abs(dmgy) / 20)
	local h = math.min(self.oh*1.3, self.oh + math.abs(dmgx) / 20)
	self.w = w
	self.h = h
	self.size_handle = timer.tween(0.5, self, {w=self.ow, h=self.oh}, 'in-bounce')
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

function ship:goforward()
	if self.fuel <= 0 and not self.dying then
		ct.play('out')
	elseif not self.dying then
		self.fuel_part:start()
	end
	self.activated = true
end
function ship:stop_goforward()
	self.fuel_part:pause()
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
