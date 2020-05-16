extends Control

onready var grid: GridContainer = $GridContainer
onready var level_button: PackedScene = load("res://UI/LevelButton.tscn")

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





func _on_level_select_mouse_entered(level_name: String) -> void:
	if is_instance_valid($Container.get_child(0)):
		$Container.get_child(0).queue_free()
	var level = SceneManager.levels[level_name].instance()
	level.scale = Vector2(0.57, 0.57)
	level.preview()
	$Container.add_child(level)
