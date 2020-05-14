extends Node

var color_schemes: Dictionary = {
	0:{
		'Player': Color('66545e'),
		'Objects': Color('aa6f73'),
		'Walls': Color('eea990'),
		'Background': Color('f6e0b5'),
		},
	1:{
		'Player': Color('05668d'),
		'Objects': Color('028090'),
		'Walls': Color('02c39a'),
		'Background': Color('f0f3bd'),
		},
	2:{
		'Player': Color('f67280'),
		'Objects': Color('c06c84'),
		'Walls': Color('6c5b7b'),
		'Background': Color('355c7d'),
		},
	3:{
		'Player': Color('b2967d'),
		'Objects': Color('e6beae'),
		'Walls': Color('e7d8c9'),
		'Background': Color('eee4e1'),
		},
	4:{
		'Player': Color('8e9aaf'),
		'Objects': Color('cbc0d3'),
		'Walls': Color('efd3d7'),
		'Background': Color('feeafa'),
		},
	5:{
		'Player': Color('9d8189'),
		'Objects': Color('f4acb7'),
		'Walls': Color('ffcad4'),
		'Background': Color('ffe5d9'),
		},
	6:{
		'Player': Color('6d6875'),
		'Objects': Color('b5838d'),
		'Walls': Color('e5989b'),
		'Background': Color('ffb4a2'),
		},
	7:{
		'Player': Color('293241'),
		'Objects': Color('ee6c4d'),
		'Walls': Color('98c1d9'),
		'Background': Color('3d5a80'),
		},
	8:{
		'Player': Color('355070'),
		'Objects': Color('6d597a'),
		'Walls': Color('b56576'),
		'Background': Color('e56b6f'),
		},
	9:{
		'Player': Color('513b56'),
		'Objects': Color('525174'),
		'Walls': Color('348aa7'),
		'Background': Color('5dd39e'),
		},
	10:{
		'Player': Color('f27059'),
		'Objects': Color('f4845f'),
		'Walls': Color('f79d65'),
		'Background': Color('f7b267'),
		},
	11:{
		'Player': Color('714674'),
		'Objects': Color('9f6976'),
		'Walls': Color('cc8b79'),
		'Background': Color('faae7b'),
		},
	12:{
		'Player': Color('372549'),
		'Objects': Color('774c60'),
		'Walls': Color('b75d69'),
		'Background': Color('eacdc2'),
		},
	13:{
		'Player': Color('555b6e'),
		'Objects': Color('89b0ae'),
		'Walls': Color('bee3db'),
		'Background': Color('faf9f9'),
		},
	14:{
		'Player': Color('5bc0be'),
		'Objects': Color('3a506b'),
		'Walls': Color('1c2541'),
		'Background': Color('0b132b'),
		},
	15:{
		'Player': Color('b76935'),
		'Objects': Color('935e38'),
		'Walls': Color('38413f'),
		'Background': Color('143642'),
		},
}
var current_theme: Dictionary

func _ready() -> void:
# warning-ignore:return_value_discarded
	SignalManager.connect("slide_down_finish", self, "change_theme")
	randomize()
	change_theme()

func change_theme() -> void:
	randomize()
	var current_theme_key: int = randi() % ColorSchemes.color_schemes.size()
	if color_schemes[current_theme_key] == current_theme:
		if current_theme_key == 0:
			current_theme_key += 1
		else:
			current_theme_key -= 1
	current_theme = color_schemes[current_theme_key]
	SignalManager.emit_signal("color_scheme_changed")
