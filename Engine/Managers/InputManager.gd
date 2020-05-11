extends Node

var undo_delayed: bool = false
var undo_hold_time: float = 0
var undo_hold_delay: float = 0.15

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("reload"):
		SceneManager.reload_current_scene()
	elif event.is_action_pressed("change_color_scheme"):
		ColorSchemes.change_theme()
		
func _process(delta: float) -> void:
	if Input.is_action_pressed("undo"):
		undo_hold_time += delta / 5
		if undo_hold_time >= undo_hold_delay:
			undo_hold_time = undo_hold_delay - 0.033
		if not undo_delayed and not PlayerManager.player_moving():
			delay_undo()
			for player in PlayerManager.players:
				if not player.turn_states.empty() and not PlayerManager.player_animation_playing():
					if not player.get_state(player.states.CONTROL_DISABLED):
						player.enable_control()
					if (not player.match_state(player.states.CONTROL_DISABLED)) and player.turn_states.size() > 0:
						player.disable_control()
					if not player.match_state(player.states.GOAL_REACHED):
						player.unscore_goal(undo_hold_delay - undo_hold_time)
						yield(player.tween, "tween_all_completed")
						PlayerManager.move_to(player, player.last_position, undo_hold_delay - undo_hold_time)
					elif not player.goal_reached:
						PlayerManager.move_to(player, player.turn_states.back()[player.states.POSITION], undo_hold_delay - undo_hold_time)
					player.rewind()
	else:
		undo_hold_time = 0
		
				
func delay_undo() -> void:
	undo_delayed = true
	if undo_hold_delay -  undo_hold_time < 0:
		undo_hold_time = undo_hold_delay
	yield(get_tree().create_timer(undo_hold_delay - undo_hold_time), "timeout")
	undo_delayed = false
