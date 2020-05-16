extends Control

onready var level_select_button: Button = $LevelSelectButton
onready var start_game_button: Button = $StartGameButton

func _ready() -> void:
	for label in get_tree().get_nodes_in_group("Label"):
		label.add_color_override("font_color", ColorSchemes.current_theme['Player'])
		label.set("custom_colors/font_color_hover", ColorSchemes.current_theme['Objects'])
		label.set("custom_colors/font_color_pressed", ColorSchemes.current_theme['Walls'])		
		
func _on_LevelSelectButton_pressed() -> void:
	AudioManager.click.play()
	yield(AudioManager.click, "finished")	
	SceneManager.transition_to_scene(SceneManager.level_select)

func _on_StartGameButton_pressed() -> void:
	AudioManager.click.play()
	yield(AudioManager.click, "finished")		
	SceneManager.start_game()


func _on_LevelSelectButton_mouse_entered() -> void:
	AudioManager.hover.play()

func _on_StartGameButton_mouse_entered() -> void:
	AudioManager.hover.play()	
