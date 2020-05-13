extends Node2D

class_name Level

onready var level_name_label: Label = $Labels/LevelName

func _ready() -> void:
	level_name_label.text = "Level " + str(SceneManager.current_level + 1)	
	for label in get_tree().get_nodes_in_group("Label"):
		label.add_color_override("font_color", ColorSchemes.current_theme['Player'])
