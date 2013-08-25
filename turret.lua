local physic = require 'physic'
local particle = require 'particle'

local Turret = {
	range = 40,
	last_fire = -9,
	reload = 2,
	tick = 0,
	rockets = {},
}
Turret.__index = Turret

function Turret:on_attach()
	self.offangle = math.random() * math.pi * 2
	self.rockets = {}
end

function Turret:draw()
	local ct = require 'content'

	local R = self.level.ratio

	local sprite = ct.sprites.turret_base
	local transform = {
		angle=0,
		wfactor=self.size*R / sprite.w,
		hfactor=self.size*R / sprite.h,
	}

	set_color(self.color)
	draw_sprite(sprite, self.x*R, self.y*R, transform)

	local sprite = ct.sprites.turret_canon
	set_color(self.color2)
	transform.angle = self.angle
	draw_sprite(sprite, self.x*R, self.y*R, transform)

	set_color(255,255,255)
	for _, r in ipairs(self.rockets) do
		local sprite = ct.sprites.missile
		local x, y = r.body:get_position()
		local angle = r.body:get_angle()
		draw_sprite_rotated(sprite, x*R-sprite.w/2, y*R-sprite.h/2, angle)
	end
end

function Turret:draw2()
	local dx, dy = get_offset()
	for _, r in ipairs(self.rockets) do
		r.part:draw(dx, dy)
	end
end

function Turret:update(dt)
	local ship = require 'ship'

	self.tick = self.tick + dt

	local sx, sy = ship.body:get_position()
	local dx, dy = ship.body:get_linear_velocity()
	sx, sy = sx + dx*0.5, sy + dy*0.5
	local can_see = math.sqrt((sx-self.x)^2 + (sy-self.y)^2) < self.range
	if can_see then
		local angle = math.atan2(sy - self.y, sx - self.x) + math.random()*math.pi/12-math.pi/24
		self.angle = angle
		if self.last_fire + self.reload < self.tick then
			self:fire(angle)
		end
	else
		self.angle = math.sin(self.tick + self.offangle) * math.pi
	end

	for i, r in ipairs(self.rockets) do
		local x, y = r.body:get_position()
		local R = self.level.ratio
		r.part:set_position(x*R, y*R)
		r.part:update(dt)
		if r.remove_me then
			r.body:destroy()
			table.remove(self.rockets, i)
		end
	end
end

function Turret:fire(angle)
	self.last_fire = self.tick

	local x, y = self.x + math.cos(angle)*2, self.y + math.sin(angle)*2
	local w, h = 0.8, 0.3
	local rocket = {
		x=x,
		y=y,
		w=w,
		h=h,
		part=particle.new_system(0, 0)
	}

	local shape = physic.new_shape('box', w, h)
	shape:set_density(0)

	rocket.body = physic.new_body(shape, true)
	rocket.body:set_position(x+w/2, y+h/2)
	rocket.body:set_angle(angle)
	local speed = 50
	rocket.body:set_linear_damping(0)
	rocket.body:set_linear_velocity(math.cos(angle)*speed, math.sin(angle)*speed)

	rocket.body.is_rocket = true
	rocket.body.parent = rocket

	rocket.remove_me = false
	rocket.body.begin_collide = function(_, o)
		if not o.is_turret and not o.is_capsule and not o.is_text then
			rocket.remove_me = true
		end
	end

	local R = self.level.ratio
	rocket.part:set_position(x*R, y*R)
	rocket.part:add_size(0, 3)
	rocket.part:add_size(.3, 5)
	rocket.part:add_size(1, 1)
	rocket.part:add_color(0, 50, 50, 50)
	rocket.part:add_color(0.3, 180, 200, 50, 100, 0, 0)
	rocket.part:add_color(0.5, 180, 200, 100, 200, 0, 0)
	rocket.part:add_color(0.7, 0, 0, 0)
	rocket.part:add_color(1, 0, 0, 0)
	rocket.part:set_lifetime(0.5)
	rocket.part:set_emission_rate(50)
	rocket.part:set_initial_velocity(20)
	rocket.part:set_initial_acceleration(50)
	rocket.part:start()

	table.insert(self.rockets, rocket)

	local ct = require 'content'
	ct.play('fire')
end

function Turret:destroy()
	self.body:destroy()
	for _, r in ipairs(self.rockets) do
		r.body:destroy()
	end
	self.rockets = {}
end

return Turret

