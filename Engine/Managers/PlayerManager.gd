extends Node

class_name PlayerManager

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
onready var tween: Tween = $Tween
onready var walk_sound_player: AudioStreamPlayer = $WalkSound

var players: Array
var goal_locations: Array
var disconnector_locations: Array
var connector_locations: Array
var intended_direction: int
var input_delayed: bool = false
var input_delay_time: float = 0.2
var input_blocked: bool = false
var level_complete: bool = false
var players_that_moved_this_turn: Array

enum directions { NORTH, SOUTH, EAST, WEST }
	
func _ready() -> void:
# warning-ignore:return_value_discarded
	SignalManager.connect("players_finished_spawning", self, "_on_players_finished_spawning")
# warning-ignore:return_value_discarded
	SignalManager.connect("level_complete", self, "_on_level_complete")
# warning-ignore:return_value_discarded
	SignalManager.connect("slide_up_finish", self, "_on_slide_up_finish")
# warning-ignore:return_value_discarded
	SignalManager.connect("slide_down_start", self, "_on_slide_down_start")	

func _input(event: InputEvent) -> void:
	if input_blocked:
		return
	elif event.is_action_pressed("ui_down"):
		intended_direction = directions.SOUTH
	elif event.is_action_pressed("ui_up"):
		intended_direction = directions.NORTH
	elif event.is_action_pressed("ui_left"):
		intended_direction = directions.WEST
	elif event.is_action_pressed("ui_right"):
		intended_direction = directions.EAST
	elif event.is_action_pressed("reload") and not direction_key_pressed():
		if SceneManager.current_level == -1:
			pass
		else:
			SignalManager.emit_signal("transition_to_level", SceneManager.current_level)
	# DEBUG
	elif event.is_action_pressed("debug_spawn_players"):
		spawn_players()

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	if input_blocked or input_delayed:
		return
	if player_moving():
		players_that_moved_this_turn.clear()	
		delay_input()
		for player in players:
			if player_animation_playing():
				return
			# add turn states to players that have scored or are currently frozen
			# even though they haven't moved
			if (player.goal_reached or player.control_disabled) and not players_that_moved_this_turn.empty():
				player.add_turn_state()
			# only replace the player's previous position with their current position
			# if they have not scored a goal, so that when goals are unscored
			# the player goes to the spot they were on prior to scoring
			elif not player.goal_reached:
				player.last_position = player.position	
			# handle movement for players that are still able to move
			if not player.control_disabled and not player.goal_reached:
				if intended_direction == directions.NORTH and check_player_direction(player, directions.NORTH):
					move_to(player, Vector2(player.position.x, player.position.y - GameManager.TILE_SIZE))
				elif intended_direction == directions.SOUTH and check_player_direction(player, directions.SOUTH):
					move_to(player, Vector2(player.position.x, player.position.y + GameManager.TILE_SIZE))
				elif intended_direction == directions.WEST and check_player_direction(player, directions.WEST):
					move_to(player, Vector2(player.position.x - GameManager.TILE_SIZE, player.position.y))
				elif intended_direction == directions.EAST and check_player_direction(player, directions.EAST):
					move_to(player, Vector2(player.position.x + GameManager.TILE_SIZE, player.position.y))
					
		# only add a turn state if the player is able to move,
		# to keep track of whether or not any players were actually moved this turn
		if not players_that_moved_this_turn.empty():
			for player in players:
				if not player.control_disabled and not player.goal_reached:
					player.add_turn_state()

	elif Input.is_action_pressed("undo") and not direction_key_pressed():
			delay_input()
			for player in players:
				if is_instance_valid(player) and not player.turn_states.empty() and not player_animation_playing():
					# make sure the player is controllable if it does not contain the CONTROL_DISABLED state
					if not player.get_state(player.states.CONTROL_DISABLED):
						player.enable_control()
					# if the player's previous control state does not match their current state, they were disabled
					# on the prior turn, so return them to the disabled state when undoing
					if (not player.match_state(player.states.CONTROL_DISABLED)) and player.turn_states.size() > 0:
						player.disable_control()
					# if the player's previous goal state does not match their current state,
					# then it means it was a non-scoring state, so return the player to that state
					if not player.match_state(player.states.GOAL_REACHED):
						player.unscore_goal(GameManager.TURN_TIME)
						yield(player.tween, "tween_all_completed")
						move_to(player, player.last_position, GameManager.TURN_TIME)
					# move the player to their previous location
					elif not player.goal_reached:
						move_to(player, player.turn_states.back()[player.states.POSITION], GameManager.TURN_TIME)
					# remove the turn that we just undid
					player.rewind()

func _on_slide_up_finish() -> void:
	spawn_players()	

func spawn_players() -> void:
	for spawn in get_tree().get_nodes_in_group("Spawn"):
		var player: Player = player_scene.instance()
		player.position = spawn.position
		add_child(player)
	SignalManager.emit_signal("players_finished_spawning")

func _on_players_finished_spawning() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		players.append(player)
	unblock_input()

func check_level_complete() -> void:
	if not level_complete:
		for player in players:
			if player.goal_reached == false:
				return
		level_complete = true
		SignalManager.emit_signal("level_complete")
		# wait until the player is no longer visible
		yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")
		SignalManager.emit_signal("transition_to_next_level")

func _on_level_complete() -> void:
	block_input()

func delay_input() -> void:
	input_delayed = true
	yield(get_tree().create_timer(input_delay_time), "timeout")
	input_delayed = false
					
# warning-ignore:unused_argument
func move_to(player: Player, new_position: Vector2, time: float = 0.15, undoing = false) -> void:
	players_that_moved_this_turn.append(player)
	player.last_position = player.position			
	play_piece_move_sfx()
# warning-ignore:return_value_discarded
	tween.interpolate_property(player, "position", player.position, new_position, time, Tween.TRANS_QUINT)
	if new_position.x != player.position.x:
# warning-ignore:return_value_discarded
		tween.interpolate_property(player, "scale", player.scale, Vector2(1, 0.66), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
# warning-ignore:return_value_discarded
		tween.interpolate_property(player, "scale", player.scale, Vector2(1, 1), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, time / 2)
	elif new_position.y != player.position.y:
# warning-ignore:return_value_discarded
		tween.interpolate_property(player, "scale", player.scale, Vector2(0.66, 1), time / 2, Tween.TRANS_LINEAR)
# warning-ignore:return_value_discarded
		tween.interpolate_property(player, "scale", player.scale, Vector2(1, 1), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, time / 2)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween, "tween_all_completed")
	check_tile_object(player)
	check_level_complete()
	
func all_players_stuck() -> bool:
	for player in players:
		if (player.control_disabled == false):
			return false
	return true

func play_piece_move_sfx() -> void:
	if not walk_sound_player.playing:
		walk_sound_player.pitch_scale = rand_range(0.9, 1.05)
		walk_sound_player.volume_db = rand_range(-5,-3)
		walk_sound_player.play()

func player_animation_playing() -> bool:
	for player in players:
		if player.tween.is_active():
				return true
	return false

func check_tile_object(player: Player) -> void:
	if player.get_location_on_grid() in disconnector_locations:
		for p in players:
			if p != player:
				p.disable_control()
	elif player.get_location_on_grid() in connector_locations:
		for p in players:
			if p != player:
				p.enable_control()
	elif player.get_location_on_grid() in goal_locations:
		player.score_goal()

func player_moving() -> bool:
	if not direction_key_pressed():
		return false
	if tween.is_active():
		return false
	if player_animation_playing():
		return false
	if all_players_stuck():
		return false
	return true
	
func direction_key_pressed() -> bool:
	return (Input.is_action_pressed("ui_down") or 
			Input.is_action_pressed("ui_left") or 
			Input.is_action_pressed("ui_right") or 
			Input.is_action_pressed("ui_up"))
	
func check_player_direction(player: Player, direction: int) -> bool:
	var level: TileMap = $"/root/Level/TileMap"
	var player_location = player.get_location_on_grid()	
	var tile_to_check: Vector2 = Vector2.ZERO
# warning-ignore:unassigned_variable
	var other_player_locations: Array
	
	for p in get_tree().get_nodes_in_group("Player"):
		if p != player and not p.goal_reached:
			other_player_locations.append(p.get_location_on_grid())
		
	match direction:
		directions.NORTH: 
			tile_to_check = Vector2(0, -1) + player_location
		directions.SOUTH:
			tile_to_check = Vector2(0, 1) + player_location
		directions.EAST:
			tile_to_check = Vector2(1, 0) + player_location
		directions.WEST:
			tile_to_check = Vector2(-1, 0) + player_location
			
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	if (level.get_cell(tile_to_check.x, tile_to_check .y) == -1 and not tile_to_check in other_player_locations):
		return true
	return false

func _on_slide_down_start() -> void:
	block_input()

func block_input() -> void:
	input_blocked = true

func unblock_input() -> void:
	input_blocked = false
	

