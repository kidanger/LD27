local physic = require 'physic'

local Turret = {
	range = 100,
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

function Turret:update(dt)
	local ship = require 'ship'

	self.tick = self.tick + dt

	local sx, sy = ship.body:get_position()
	local can_see = math.sqrt((sx-self.x)^2 + (sy-self.y)^2) < self.range
	if can_see then
		local angle = math.atan2(sy - self.y, sx - self.x)
		self.angle = angle
		if self.last_fire + self.reload < self.tick then
			self:fire(angle)
		end
	else
		self.angle = math.sin(self.tick + self.offangle) * math.pi
	end

	for i, r in ipairs(self.rockets) do
		if r.remove_me then
			table.remove(self.rockets, i)
		end
	end
end

function Turret:fire(angle)
	self.last_fire = self.tick

	local w, h = 0.8, 0.3
	local rocket = {
		x=self.x,
		y=self.y,
		w=w,
		h=h,
	}

	local shape = physic.new_shape('box', w, h)
	shape:set_friction(0)
	shape:set_density(0)

	rocket.body = physic.new_body(shape, true)
	rocket.body:set_position(self.x+w/2, self.y+h/2)
	rocket.body:set_angle(angle)
	local speed = 50
	rocket.body:set_linear_damping(0)
	rocket.body:set_linear_velocity(math.cos(angle)*speed, math.sin(angle)*speed)
	rocket.body:set_fixed_rotation(true)

	rocket.body.is_rocket = true
	rocket.body.parent = rocket

	rocket.remove_me = false
	rocket.body.begin_collide = function(_, o)
		if o.is_wall then
			rocket.remove_me = true
		end
	end

	table.insert(self.rockets, rocket)
end

function Turret:destroy()
	self.body:destroy()
	for _, r in ipairs(self.rockets) do
		r.body:destroy()
	end
	self.rockets = {}
end

return Turret

