extends Node

class_name PlayerManager

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
onready var tween: Tween = $Tween
onready var walk_sound_player: AudioStreamPlayer = $WalkSound
onready var level: TileMap = $"/root/Level/TileMap"

var players: Array
var intended_direction: int
var input_delayed: bool = false
var input_delay_time: float = GameManager.TURN_TIME
var input_blocked: bool = false
var level_complete: bool = false

enum directions { NORTH, SOUTH, EAST, WEST }
	
func _ready() -> void:
	SignalManager.connect("players_finished_spawning", self, "_on_players_finished_spawning")
	SignalManager.connect("level_complete", self, "_on_level_complete")
	SignalManager.connect("slide_up_finish", self, "_on_slide_up_finish")
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
	elif event.is_action_pressed("reload") and not direction_key_pressed() and not SceneManager.tween.is_active():
			SceneManager.reload_level()
	elif event.is_action_pressed("quit_to_menu") and not SceneManager.tween.is_active():
		SceneManager.transition_to_scene(SceneManager.main_menu)
	# DEBUG
	elif event.is_action_pressed("debug_spawn_players"):
		spawn_players()

func _process(delta: float) -> void:
	if input_blocked or input_delayed or player_animation_playing():
		return
	if player_moving():
		delay_input()
		for player in players:
			if not player.control_disabled and not player.goal_reached:
				if intended_direction == directions.NORTH and check_player_direction(player, directions.NORTH):
					play_piece_move_sfx()					
					player.move(Vector2(0, -1))
				elif intended_direction == directions.SOUTH and check_player_direction(player, directions.SOUTH):
					play_piece_move_sfx()					
					player.move(Vector2(0, 1))
				elif intended_direction == directions.WEST and check_player_direction(player, directions.WEST):
					play_piece_move_sfx()					
					player.move(Vector2(-1, 0))
				elif intended_direction == directions.EAST and check_player_direction(player, directions.EAST):
					play_piece_move_sfx()
					player.move(Vector2(1, 0))
		if not players.empty():
			yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")
			resolve_turn()
	
func _on_slide_up_finish() -> void:
	spawn_players()	

func spawn_players() -> void:
	for spawn in get_tree().get_nodes_in_group("Spawn"):
		var player: Player = player_scene.instance()
		player.position = spawn.position
		add_child(player)
	for spawn in get_tree().get_nodes_in_group("ImmuneSpawn"):
		var player: Player = player_scene.instance()
		player.set_immune()
		player.position = spawn.position
		add_child(player)
	SignalManager.emit_signal("players_finished_spawning")

func _on_players_finished_spawning() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		players.append(player)
	unblock_input()

func check_level_complete() -> void:
	if level_complete:
		return
	for player in players:
		if player.goal_reached == false:
			return
	level_complete = true
	SignalManager.emit_signal("level_complete")
	# wait until the player is no longer visible
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")
	SceneManager.transition_to_scene(level.get_parent().next_level)

func _on_level_complete() -> void:
	block_input()

func delay_input() -> void:
	input_delayed = true
	yield(get_tree().create_timer(input_delay_time), "timeout")
	input_delayed = false

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
	return true
	
func direction_key_pressed() -> bool:
	return (Input.is_action_pressed("ui_down") or 
			Input.is_action_pressed("ui_left") or 
			Input.is_action_pressed("ui_right") or 
			Input.is_action_pressed("ui_up"))

func resolve_turn() -> void:	
	for player in players:
		if (not (player.goal_reached or player.control_disabled)) and (not level.world_to_map(player.last_position) == level.world_to_map(player.global_position)):
			if level.world_to_map(player.global_position) in level.goal_locations:
				player.score_goal()
			if level.world_to_map(player.global_position) in level.disconnector_locations:
				for p in players:
					if not p == player and not p.control_disabled:
						p.disable_control()
			elif level.world_to_map(player.global_position) in level.connector_locations and not player.control_disabled:
				var player_on_disconnect: bool = false
				for p in players:
					if level.world_to_map(p.global_position) in level.disconnector_locations:
						player_on_disconnect = true
				if player.immune or not player_on_disconnect:
					for p in players:
						if p.control_disabled:
							p.enable_control()	
	check_level_complete()

func check_player_direction(player: Player, direction: int) -> bool:
	var player_location = level.world_to_map(player.global_position)
	var tile_to_check: Vector2 = Vector2.ZERO
	var other_player_locations: Array
	
	for p in get_tree().get_nodes_in_group("Player"):
		if p != player and not p.goal_reached:
			other_player_locations.append(level.world_to_map(p.global_position))

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
