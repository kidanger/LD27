require 'drystal'
local font = require 'truetype'
local physic = require 'physic'
local particle = require 'particle'
-- not gonna use 'net' extension
-- 'web', I don't know yet
local timer = require 'hump/timer'

local ct = require 'content'

width, height = 600, 480

local state = {}

--[[===================
----======= INIT ======]]
function init()
    resize(width, height)
end


--[[=====================
----======= UPDATE ======]]
function update(dt)
    state.update(dt)
    timer.update(dt)
end


--[[===================
----======= DRAW ======]]
function draw()
    state.draw()
end


--[[=====================
----======= EVENTS ======]]

function key_press(key)
    if state.key_press then
        state.key_press(key)
    end
end
function key_release(key)
    if state.key_release then
        state.key_release(key)
    end
end

function mouse_motion(x, y, dx, dy)
    if state.key_motion then
        state.key_motion(x, y, dx, dy)
    end
end
function mouse_press(x, y, b)
    if state.key_press then
        state.key_press(x, y, b)
    end
end
function mouse_release(x, y, b)
    if state.key_release then
        state.key_motion(x, y, b)
    end
end
