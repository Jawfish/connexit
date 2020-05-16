extends Node

const TILE_SIZE: int = 64
const TURN_TIME: float = 0.2

func _ready() -> void:
	SignalManager.connect("color_scheme_changed", self, "_on_color_scheme_changed")
	VisualServer.set_default_clear_color(ColorSchemes.current_theme['Background'])
	
func _on_color_scheme_changed() -> void:
	VisualServer.set_default_clear_color(ColorSchemes.current_theme['Background'])	
