extends Node2D

class_name ColorSchemeObject

var color_object: String

func _ready() -> void:
	SignalManager.connect("color_scheme_changed", self, "update_color")
	update_color()

func update_color() -> void:
	modulate = ColorSchemes.current_theme[color_object]
