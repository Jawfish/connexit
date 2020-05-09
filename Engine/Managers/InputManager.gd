extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
		print('Scene reloaded')
	elif event.is_action_pressed("change_color_scheme"):
		ColorSchemes.change_theme()
