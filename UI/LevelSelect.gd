extends Control

onready var grid: GridContainer = $GridContainer
onready var level_button: PackedScene = preload("res://UI/LevelButton.tscn")

var i: int = 1

func _ready() -> void:
	for level in SceneManager.levels.values():
		create_button(level)
		i += 1

func create_button(level: PackedScene) -> void:
	var button: Button = level_button.instance()
	button.level = level
	button.add_color_override("font_color", ColorSchemes.current_theme['Player'])
	button.set("custom_colors/font_color_hover", ColorSchemes.current_theme['Objects'])
	button.set("custom_colors/font_color_pressed", ColorSchemes.current_theme['Walls'])		
	button.text = "Level " + str(i)
	$ScrollContainer/VBoxContainer.add_child(button)
