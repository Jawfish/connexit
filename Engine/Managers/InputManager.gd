extends Node

var undo_delayed: bool = false
var undo_hold_time: float = 0
var undo_hold_delay: float = 0.15
var block_input: bool = false

func _ready() -> void:
	SignalManager.connect("scene_change_start", self, "_on_scene_change_start")
	SignalManager.connect("scene_change_end", self, "_on_scene_change_end")

func _input(event: InputEvent) -> void:
	if not block_input:
		if event.is_action_pressed("quit"):
			get_tree().quit()
		elif event.is_action_pressed("reload") and not Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_up"):
			SceneManager.reload_current_scene()
		elif event.is_action_pressed("change_color_scheme"):
			ColorSchemes.change_theme()
		
func _process(delta: float) -> void:
	if not block_input:
		if Input.is_action_pressed("undo"):
			undo_hold_time += delta / 5
			if undo_hold_time >= undo_hold_delay:
				undo_hold_time = undo_hold_delay - 0.033
			if not undo_delayed and not PlayerManager.player_moving():
				delay_undo()
				for player in PlayerManager.players:
					if is_instance_valid(player) and not player.turn_states.empty() and not PlayerManager.player_animation_playing():
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

func _on_scene_change_start() -> void:
	block_input = true
	
func _on_scene_change_end() -> void:
	block_input = false
