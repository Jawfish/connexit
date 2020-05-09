extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("reload"):
		SceneManager.transition_to_scene(SceneManager.current_level)
	elif event.is_action_pressed("change_color_scheme"):
		ColorSchemes.change_theme()


func _process(delta: float) -> void:
	if Input.is_action_pressed("undo") and PlayerManager.can_move:
		for player in PlayerManager.players:
			if player.last_position.size() > 0:
				PlayerManager.move_to(player, player.last_position[player.last_position.size() - 1])
				player.last_position.pop_back()
