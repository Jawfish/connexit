extends CanvasLayer

onready var restart: Label = $Restart
onready var undo: Label = $Undo

func _ready() -> void:
	SignalManager.connect("color_scheme_changed", self, "_on_color_scheme_changed")
	restart.add_color_override("font_color", ColorSchemes.current_theme['Player'])
	undo.add_color_override("font_color", ColorSchemes.current_theme['Player'])	
	
func _on_color_scheme_changed() -> void:
	restart.add_color_override("font_color", ColorSchemes.current_theme['Player'])
	undo.add_color_override("font_color", ColorSchemes.current_theme['Player'])	
