extends Node

var undo_delayed: bool = false
var undo_hold_time: float = 0
var undo_hold_delay: float = 0.15

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("reload"):
		SceneManager.transition_to_scene(SceneManager.current_level)
	elif event.is_action_pressed("change_color_scheme"):
		ColorSchemes.change_theme()
		
func _process(delta: float) -> void:
	if Input.is_action_pressed("undo"):
		undo_hold_time += delta / 5
		if not undo_delayed:
			delay_undo()
			for player in PlayerManager.players:
				if not player.turn_locations.empty():
					if player.position != player.turn_locations.back():
						player.enable_control()
					PlayerManager.move_to(player, player.turn_locations.pop_back(), 0.15 - undo_hold_time)
	else:
		undo_hold_time = 0
				
func delay_undo() -> void:
	undo_delayed = true
	if undo_hold_delay -  undo_hold_time < 0:
		undo_hold_time = undo_hold_delay
	yield(get_tree().create_timer(undo_hold_delay - undo_hold_time), "timeout")
	undo_delayed = false
