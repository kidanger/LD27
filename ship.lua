local physic = require 'physic'

local ship = {
	w=3, -- in meters
	h=1.5,
	color={255, 255, 255},

	body=nil,

	colliding=true,
	health=0,
	max_health=10,

	activated=false,
	fuel=10,
	max_fuel=10,

	engine_power=50,

	right=false,
	left=false,

	level=nil,
}

function ship:init(level, x, y)
	assert(not self.body)
	local shape = physic.new_shape('box', self.w, self.h)
	shape:set_friction(0)
	shape:set_restitution(0.5)
	self.body = physic.new_body(shape, true)
	self.body:set_position(x + self.w / 2, y + self.h / 2)
	self.body:set_angular_damping(5)
	self.body:set_linear_damping(1)

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

	draw_rect_rotated((x-self.w/2)*R, (y-self.h/2)*R, self.w*R, self.h*R, angle)
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
