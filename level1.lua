local level = {
start={y=58, x=80},
arrival={y=32, x=80},
capsules={
	{y=35, x=16, type="fuel"},
	{y=46, x=16, type="fuel"},
	{y=57, x=16, type="fuel"},
	{y=41, x=18, type="fuel"},
	{y=53, x=18, type="fuel"},
	{y=31, x=19, type="fuel"},
	{y=31, x=37, type="health"},
	{y=37, x=38, type="health"},
	{y=31, x=47, type="health"},
	{y=39, x=52, type="health"},
	{y=32, x=58, type="health"},
	{y=37, x=60, type="health"},
},
boxes={
	{y=19, x=5, w=7, h=57},
	{y=19, x=12, w=85, h=7},
	{y=69, x=12, w=85, h=7},
	{y=43, x=24, w=73, h=7},
	{y=26, x=90, w=7, h=17},
	{y=50, x=90, w=7, h=19},
},
texts={
	{y=26, x=12, text=3, w=4, h=43},
	{y=26, x=16, text=3, w=3, h=9},
	{y=36, x=16, text=3, w=2, h=10},
	{y=47, x=16, text=3, w=2, h=10},
	{y=58, x=16, text=3, w=16, h=11},
	{y=35, x=17, text=3, w=7, h=1},
	{y=46, x=17, text=3, w=7, h=1},
	{y=57, x=17, text=3, w=15, h=1},
	{y=36, x=18, text=3, w=6, h=5},
	{y=42, x=18, text=3, w=6, h=4},
	{y=47, x=18, text=3, w=6, h=6},
	{y=54, x=18, text=3, w=14, h=3},
	{y=26, x=19, text=3, w=5, h=5},
	{y=32, x=19, text=3, w=5, h=3},
	{y=41, x=19, text=3, w=5, h=1},
	{y=53, x=19, text=3, w=13, h=1},
	{y=31, x=20, text=3, w=4, h=1},
	{y=50, x=24, text=3, w=8, h=3},
	{y=26, x=31, text=4, w=6, h=17},
	{y=26, x=37, text=4, w=42, h=5},
	{y=32, x=37, text=4, w=1, h=11},
	{y=31, x=38, text=4, w=9, h=6},
	{y=38, x=38, text=4, w=14, h=5},
	{y=50, x=38, text=1, w=42, h=19},
	{y=37, x=39, text=4, w=21, h=1},
	{y=32, x=47, text=4, w=11, h=5},
	{y=31, x=48, text=4, w=31, h=1},
	{y=38, x=52, text=4, w=27, h=1},
	{y=40, x=52, text=4, w=27, h=3},
	{y=39, x=53, text=4, w=26, h=1},
	{y=33, x=58, text=4, w=21, h=4},
	{y=32, x=59, text=4, w=20, h=1},
	{y=37, x=61, text=4, w=18, h=1},
	{y=50, x=80, text=1, w=10, h=8},
	{y=59, x=80, text=1, w=10, h=10},
	{y=58, x=81, text=1, w=9, h=1},
},
textdata={
	"Hey, press {b100|up} to activate the engine,\nand {b100|right/left} to rotate the ship.",
	"",
	"Those little things are {big|Fuel Capsules},\nthey help to last more than {r0|g100|b0|10 seconds}.",
	"And there are some {big|Health Capsules},\nif your health is at zero, your ship {r255|g0|b0|explodes}.",
},
}
return level