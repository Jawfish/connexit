extends Node

var color_schemes = {
	1:{
		1: Color('66545e'),
		2: Color('aa6f73'),
		3: Color('eea990'),
		4: Color('f6e0b5'),
		5: Color(0,0,0,0)
		},
	2:{
		1: Color('f9ed69'),
		2: Color('f08a5d'),
		3: Color('b83b5e'),
		4: Color('6a2c70'),
		5: Color(0,0,0,0)
		},
	3:{
		1: Color('f67280'),
		2: Color('c06c84'),
		3: Color('6c5b7b'),
		4: Color('355c7d'),
		5: Color(0,0,0,0)
		},
	4:{
		1: Color('4b3832'),
		2: Color('854442'),
		3: Color('fff4e6'),
		4: Color('be9b7b'),
		5: Color(0,0,0,0)
		},
	5:{
		1: Color('f57170'),
		2: Color('f5f5f5'),
		3: Color('10ddc2'),
		4: Color('15b7b9'),
		5: Color(0,0,0,0)
		},
	6:{
		1: Color('fecea8'),
		2: Color('ff847c'),
		3: Color('e84a5f'),
		4: Color('2a363b'),
		5: Color(0,0,0,0)
		},
	7:{
		1: Color('f85f73'),
		2: Color('fbe8d3'),
		3: Color('928a97'),
		4: Color('283c63'),
		5: Color(0,0,0,0)
		},
	8:{
		1: Color('f67280'),
		2: Color('c06c84'),
		3: Color('6c5b7b'),
		4: Color('355c7d'),
		5: Color(0,0,0,0)
		},
}
var current_theme: int = 0
var colorable_objects = { 'background': -1, 'player': -1, 'objects': -1, 'walls': -1 }

func _ready() -> void:
	randomize()
	change_theme()

func change_theme() -> void:
	randomize()
	var i = randi() % ColorSchemes.color_schemes.size()	+ 1
	if i == current_theme:
		if i < ColorSchemes.color_schemes.size():
			i += 1
		else:
			i -= 1
	current_theme = i
	set_indices()
	print('Color scheme set to ' + str(current_theme))
	print(colorable_objects)	
	SignalManager.emit_signal("color_scheme_changed")

# give each colorable object a random unique color from the current color scheme
func set_indices() -> void:
	var color_array: Array = range(len(colorable_objects))
	color_array.shuffle()
	var i: int = 0
	for object in colorable_objects:
		colorable_objects[object] = color_array[i] + 1
		i += 1
