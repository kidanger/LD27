local font = require 'truetype'

local ct = {
	sounds = {
	},
	fonts = {
	},
	images = {
	},
	sprites = {
		title = {x=0, y=64, w=852, h=303},
		ship = {x=0, y=0, w=64, h=64},
		ship_engine = {x=64, y=0, w=64, h=64},
		fuel_capsule = {x=128+16, y=0, w=16, h=16},
		health_capsule = {x=128+32, y=0, w=16, h=16},
		start = {x=192, y=0, w=32, h=32},
		arrival = {x=368, y=0, w=64, h=64},
		turret_base = {x=256, y=0, w=32, h=32},
		turret_canon = {x=288, y=0, w=32, h=32},
		missile = {x=320, y=0, w=32, h=32},
	},
	levels = require 'levels',
}

function ct.play(str)
	local table = ct.sounds[str]
	play_sound(table[math.random(1, #table)])
end

function ct.load()
	ct.max_level = #ct.levels

	ct.images.spritesheet = load_surface('spritesheet.png')
	draw_from(ct.images.spritesheet)

	ct.fonts.small = font.load('styllo.ttf', 20)
	ct.fonts.normal = font.load('styllo.ttf', 32)
	ct.fonts.big = font.load('styllo.ttf', 48)

	--ct.sounds.consume_fuel = load_sound('consume_fuel.wav')
	ct.sounds.collide = {
		load_sound('collide1.wav'),
		load_sound('collide2.wav'),
		load_sound('collide3.wav'),
		load_sound('collide4.wav'),
	}
	ct.sounds.fire = {
		load_sound('fire1.wav'),
	}
	ct.sounds.littlehurt = {
		load_sound('littlehurt1.wav'),
	}
	ct.sounds.out = {
		load_sound('out1.wav'),
	}
	ct.sounds.explode = {
		load_sound('explode1.wav'),
		load_sound('explode2.wav'),
	}
	ct.sounds.next_level = {
		load_sound('next_level.wav'),
	}
	ct.sounds.ending = {
		load_sound('ending.wav'),
	}
	ct.sounds.regen_health = {
		load_sound('regen_health.wav'),
	}
	ct.sounds.regen_fuel = {
		load_sound('regen_fuel.wav'),
	}
end

return ct
