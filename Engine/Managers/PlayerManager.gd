extends Node

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
onready var tween: Tween = $Tween
onready var walk_sound_player: AudioStreamPlayer = $WalkSound

var players: Array
var next_level: String
var intended_direction: int
var undo_delayed: bool = false
var block_input: bool = false

enum directions { NORTH, SOUTH, EAST, WEST }

func _ready() -> void:
	# SignalManager.connect("scene_changed", self, "_on_scene_changed")
	SignalManager.connect("level_loaded", self, "_on_level_loaded")	
	SignalManager.connect("players_finished_spawning", self, "_on_players_finished_spawning")
	SignalManager.connect("level_complete", self, "_on_level_complete")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		intended_direction = directions.SOUTH
	elif event.is_action_pressed("ui_up"):
		intended_direction = directions.NORTH
	elif event.is_action_pressed("ui_left"):
		intended_direction = directions.WEST
	elif event.is_action_pressed("ui_right"):
		intended_direction = directions.EAST
	elif event.is_action_pressed("reload") and not direction_key_pressed() and not SceneManager.current_level == "":
		SignalManager.emit_signal("transition_to_level", SceneManager.current_level)

func _process(delta: float) -> void:
	if not block_input:
		if player_moving():
			if no_players_moved():
				for player in players:
					player.rewind()
			for player in players:
				player.add_turn_state()
				if not player.goal_reached:
					player.last_position = player.position				
				if not player.control_disabled and not player_animation_playing():
					if check_player_direction(player, directions.NORTH) and intended_direction == directions.NORTH:
						move_to(player, Vector2(player.position.x, player.position.y - GameManager.TILE_SIZE))
					elif check_player_direction(player, directions.SOUTH) and intended_direction == directions.SOUTH:
						move_to(player, Vector2(player.position.x, player.position.y + GameManager.TILE_SIZE))
					elif check_player_direction(player, directions.WEST) and intended_direction == directions.WEST:
						move_to(player, Vector2(player.position.x - GameManager.TILE_SIZE, player.position.y))
					elif check_player_direction(player, directions.EAST) and intended_direction == directions.EAST:
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
				
func delay_undo() -> void:
	undo_delayed = true
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")
	undo_delayed = false
					
# func _on_scene_changed() -> void:
# 	unload_players()

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

func player_animation_playing() -> bool:
	for player in players:
		if player.tween.is_active():
				return true
	return false

func play_piece_move_sfx() -> void:
	if not walk_sound_player.playing:
		walk_sound_player.pitch_scale = rand_range(0.9, 1.05)
		walk_sound_player.volume_db = rand_range(-5,-3)
		walk_sound_player.play()

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
	return Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up")
	
func check_player_direction(player: Player, direction: int) -> bool:
	var ray: RayCast2D
	var input: String
	match direction:
		directions.NORTH: 
			ray = player.ray_n
			input = "ui_up"
		directions.SOUTH:
			ray = player.ray_s
			input = "ui_down"			
		directions.EAST:
			ray = player.ray_e
			input = "ui_right"			
		directions.WEST:
			ray = player.ray_w
			input = "ui_left"			
	if Input.is_action_pressed(input) and not ray.is_colliding():
		return true
	return false

func check_level_complete() -> void:
	for player in players:
		if player.goal_reached == false:
			return
	SignalManager.emit_signal("level_complete")
	# wait until the player is no longer visible
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")
	SignalManager.emit_signal("transition_to_level", next_level)

# func unload_players() -> void:
# 	players.clear()
# 	for player in get_tree().get_nodes_in_group("Player"):
# 		player.queue_free()

func _on_players_finished_spawning() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		players.append(player)
	unblock_input()

func _on_level_loaded(new_level: String, next_level: String) -> void:
	self.next_level = next_level
	spawn_players()

func _on_level_completed() -> void:
	block_input()

func block_input() -> void:
	block_input = true

func unblock_input() -> void:
	block_input = false
	
func spawn_players() -> void:
	for spawn in get_tree().get_nodes_in_group("Spawn"):
		var player: Player = player_scene.instance()
		player.position = spawn.position
		add_child(player)
	SignalManager.emit_signal("players_finished_spawning")
