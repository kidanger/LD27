local font = require 'truetype'

local ct = {
	sounds = {
	},
	fonts = {
	},
	images = {
	},
	sprites = {
		title = {y=64, y=0, w=256, h=256},
		background = {y=64+256, y=0, w=256, h=256},
		ship = {x=0, y=0, w=64, h=64},
		fuel_capsule = {x=64, y=0, w=32, h=32},
		health_capsule = {x=64+32, y=0, w=32, h=32},
	},
	levels = {
		unpack(require 'levels'),
	},
}

function ct.load()
	ct.images.spritesheet = load_surface('spritesheet.png')

	ct.fonts.small = font.load('space_age.ttf', 20)
	ct.fonts.normal = font.load('space_age.ttf', 32)
	ct.fonts.big = font.load('space_age.ttf', 46)

	ct.sounds.consume_fuel = load_sound('consume_fuel.wav')
	ct.sounds.collide = load_sound('collide.wav')
	ct.sounds.explode = load_sound('explode.wav')
end

return ct
