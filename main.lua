require 'drystal'

local font = require 'truetype'
local physic = require 'physic'
local particle = require 'particle'
local timer = require 'hump/timer'

local ct = require 'content'

width, height = 800, 600

local state = {}

local gamestate = require 'game'

--[[===================
----======= INIT ======]]
function init()
	resize(width, height)
	ct.load()
	state = gamestate
	gamestate:change_level(1)
end


--[[=====================
----======= UPDATE ======]]
function update(dt)
	dt = dt / 1000
	if dt > .6 then dt =.6 end
	state:update(dt)
	timer.update(dt)
end


--[[===================
----======= DRAW ======]]
function draw()
	state:draw()
	flip()
end


--[[=====================
----======= EVENTS ======]]

function key_press(key)
	if key == 'a' then
		engine_stop()
	end
	if state.key_press then
		state:key_press(key)
	end
end
function key_release(key)
	if state.key_release then
		state:key_release(key)
	end
end

function mouse_motion(x, y, dx, dy)
	if state.mouse_motion then
		state:mouse_motion(x, y, dx, dy)
	end
end
function mouse_press(x, y, b)
	if state.mouse_press then
		state:mouse_press(x, y, b)
	end
end
function mouse_release(x, y, b)
	if state.mouse_release then
		state:mouse_release(x, y, b)
	end
end
