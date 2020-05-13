extends Node

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
onready var tween: Tween = $Tween
onready var walk_sound_player: AudioStreamPlayer = $WalkSound

var players: Array
var intended_direction: int
var undo_delayed: bool = false
var input_blocked: bool = false
var level_complete: bool = false

enum directions { NORTH, SOUTH, EAST, WEST }
	
func _ready() -> void:
	SignalManager.connect("level_loaded", self, "_on_level_loaded")	
	SignalManager.connect("players_finished_spawning", self, "_on_players_finished_spawning")
	SignalManager.connect("level_complete", self, "_on_level_complete")
	SignalManager.connect("slide_up_finish", self, "_on_slide_up_finish")
	SignalManager.connect("slide_down_start", self, "_on_slide_down_start")	

func _input(event: InputEvent) -> void:
	if not input_blocked:
		if event.is_action_pressed("ui_down"):
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
	if event.is_action_pressed("debug_spawn_players"):
		spawn_players()

func _process(delta: float) -> void:
	if not input_blocked:
		if player_moving():
			if no_players_moved():
				for player in players:
					player.rewind()
			for player in players:
				player.add_turn_state()
				if not player.goal_reached:
					player.last_position = player.position				
				if not player.control_disabled and not player_animation_playing():
					if intended_direction == directions.NORTH and check_player_direction(player, directions.NORTH):
						move_to(player, Vector2(player.position.x, player.position.y - GameManager.TILE_SIZE))
					elif intended_direction == directions.SOUTH and check_player_direction(player, directions.SOUTH):
						move_to(player, Vector2(player.position.x, player.position.y + GameManager.TILE_SIZE))
					elif intended_direction == directions.WEST and check_player_direction(player, directions.WEST):
						move_to(player, Vector2(player.position.x - GameManager.TILE_SIZE, player.position.y))
					elif intended_direction == directions.EAST and check_player_direction(player, directions.EAST):
						move_to(player, Vector2(player.position.x + GameManager.TILE_SIZE, player.position.y))
		elif Input.is_action_pressed("undo") and not direction_key_pressed() and not undo_delayed:
				delay_undo()
				for player in players:
					if is_instance_valid(player) and not player.turn_states.empty() and not player_animation_playing():
						if not player.get_state(player.states.CONTROL_DISABLED):
							player.enable_control()
						if (not player.match_state(player.states.CONTROL_DISABLED)) and player.turn_states.size() > 0:
							player.disable_control()
						if not player.match_state(player.states.GOAL_REACHED):
							player.unscore_goal(GameManager.TURN_TIME)
							yield(player.tween, "tween_all_completed")
							move_to(player, player.last_position, GameManager.TURN_TIME)
						elif not player.goal_reached:
							move_to(player, player.turn_states.back()[player.states.POSITION], GameManager.TURN_TIME)
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

func delay_undo() -> void:
	undo_delayed = true
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")
	undo_delayed = false
					
func move_to(player: Player, new_position: Vector2, time = 0.15, undoing = false) -> void:
	player.last_position = player.position			
	play_piece_move_sfx()
	tween.interpolate_property(player, "position", player.position, new_position, time, Tween.TRANS_QUINT)
	tween.start()
	yield(tween, "tween_completed")
	check_level_complete()

func all_players_stuck() -> bool:
	for player in players:
		if (player.control_disabled == false):
			return false
	return true

func no_players_moved() -> bool:
	for player in players:
		if (player.last_position != player.position) and not player.goal_reached:
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
			
	if (level.get_cell(tile_to_check.x, tile_to_check .y) == -1 and not tile_to_check in other_player_locations):
		return true
	return false

func _on_slide_down_start() -> void:
	block_input()

func block_input() -> void:
	input_blocked = true

func unblock_input() -> void:
	input_blocked = false
	

