local font = require 'truetype'
local timer = require 'hump/timer'
local ct = require 'content'
local gamestate = require 'game'

local endingstate = {
}

function endingstate:on_enter()
	self.thanksx=-width*0.5
	self.thanksy=-30
	self.madebyx=width*1.5
	self.madebyy=-30

	self.alphasecs=0
	self.seconds=10
	self.prefix='Theme: '
	self.alpha = 0
	self.fading = true

	timer.tween(1, self, {alpha=200}, 'quad', function()
		self.fading = false
		timer.tween(1.7, self, {thanksx=width/2, thanksy=height/2-50}, 'out-elastic', function()
			timer.tween(1.5, self, {alphasecs=100,madebyx=width/2, madebyy=height/2+150}, 'out-elastic', function()
				self.prefix = ''
				timer.tween(1.5, self, {alphasecs=255, seconds=0}, 'quad', function()
					self.seconds = 0
					timer.add(0.1, function() -- because the 0 won't be displayed otherwise
						self.alpha = 0
						self.fading = true
						timer.tween(1, self, {alpha=200}, 'quad', function()
							gamestate:change_level(1)
							set_state(gamestate)
						end)
					end)
				end)
			end)
		end)
	end)
end

function endingstate:update(dt)
	if self.fading then
		return
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
function endingstate:draw()
	if self.fading then
		set_color(0, 0, 0)
		set_alpha(self.alpha)
		draw_rect(0, 0, width, height)
		return
	end

	set_color(0, 0, 0)
	set_alpha(255)
	draw_background()

	set_color(255, 255, 255)
	font.use(ct.fonts.big)
	font.draw_align('Thanks for playing', self.thanksx, self.thanksy, 'center')

	font.use(ct.fonts.normal)
	font.draw_align('Made by kidanger, for LudumDare #27', self.madebyx, self.madebyy, 'center')

	set_alpha(self.alphasecs)
	font.use(ct.fonts.normal)
	font.draw_align(self.prefix .. coolround(self.seconds) .. ' seconds', self.madebyx, self.madebyy + 50, 'center')
end

function endingstate:key_press(key)
end
function endingstate:key_release(key)
end

function endingstate:mouse_press(x, y, b)
end
function endingstate:mouse_release(x, y, b)
end
function endingstate:mouse_motion(x, y, dx, dy)
end

return endingstate
