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
		ship_engine = {x=64, y=0, w=64, h=64},
		fuel_capsule = {x=128+16, y=0, w=16, h=16},
		health_capsule = {x=128+32, y=0, w=16, h=16},
		start = {x=192, y=0, w=32, h=32},
		arrival = {x=224, y=0, w=32, h=32},
	},
	levels = require 'levels',
}

function ct.load()
	ct.max_level = #ct.levels

	ct.images.spritesheet = load_surface('spritesheet.png')
	draw_from(ct.images.spritesheet)

	ct.fonts.small = font.load('styllo.ttf', 20)
	ct.fonts.normal = font.load('styllo.ttf', 32)
	ct.fonts.big = font.load('styllo.ttf', 48)

--	ct.sounds.consume_fuel = load_sound('consume_fuel.wav')
--	ct.sounds.collide = load_sound('collide.wav')
--	ct.sounds.explode = load_sound('explode.wav')
end

return ct
