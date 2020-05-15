extends Node

class_name PlayerManager

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
onready var tween: Tween = $Tween
onready var walk_sound_player: AudioStreamPlayer = $WalkSound
onready var level: TileMap = $"/root/Level/TileMap"

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
	elif event.is_action_pressed("reload") and not direction_key_pressed():
		if SceneManager.current_level == -1:
			pass
		else:
			SignalManager.emit_signal("transition_to_level", SceneManager.current_level)
	# DEBUG
	elif event.is_action_pressed("debug_spawn_players"):
		spawn_players()
	elif event.is_action_pressed("debug_rewind"):
		for player in players:
			player.get_node("CommandQueue").unexecute_all_backward()

func _process(delta: float) -> void:
	if input_blocked or input_delayed or player_animation_playing():
		return
	if player_moving():
		delay_input()
		players_that_moved_this_turn.clear()	
		for player in players:
			if not player.control_disabled and not player.goal_reached and not Input.is_action_pressed("undo"):
				if intended_direction == directions.NORTH and check_player_direction(player, directions.NORTH):
					move_to(player, CommandManager.walk_north)
				elif intended_direction == directions.SOUTH and check_player_direction(player, directions.SOUTH):
					move_to(player, CommandManager.walk_south)
				elif intended_direction == directions.WEST and check_player_direction(player, directions.WEST):
					move_to(player, CommandManager.walk_west)
				elif intended_direction == directions.EAST and check_player_direction(player, directions.EAST):
					move_to(player, CommandManager.walk_east)
			elif player.control_disabled or player.goal_reached:
				player.add_command(CommandManager.do_nothing)			
		if not players_that_moved_this_turn.empty():
			for player in players:
				# add a filler command if other players moved this turn but this player didn't
				if not player in players_that_moved_this_turn and not player.control_disabled and not player.goal_reached:
					player.add_command(CommandManager.do_nothing)
		resolve_turn()
		
		# not able to fix undo mechanic before gamejam deadline
#	elif Input.is_action_pressed("undo") and not direction_key_pressed():
#		delay_input()
#		for player in get_tree().get_nodes_in_group("Player"):
#			player.get_node("CommandQueue").unexecute_last()
#		return
		

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
	if level_complete:
		return
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

func move_to(player: Player, command: PackedScene) -> void:
	players_that_moved_this_turn.append(player)		
	play_piece_move_sfx()
	player.add_command(command)
	
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
			
#func check_tile_object(player: Player) -> String:
#	if level.world_to_map(player.global_position) in disconnector_locations:
#		player.add_command(CommandManager.step_on_disconnector)
#		for p in get_tree().get_nodes_in_group("Player"):
#			if p != player and not p.goal_reached:
#				p.add_command(CommandManager.disable_control)
#	elif level.world_to_map(player.global_position) in connector_locations:
#		player.add_command(CommandManager.step_on_connector)
#		for p in get_tree().get_nodes_in_group("Player"):
#			if p != player and not p.goal_reached:
#				p.add_command(CommandManager.enable_control)			
#	elif level.world_to_map(player.global_position) in goal_locations:
#		player.add_command(CommandManager.score_goal)

func check_tile_object(player: Player) -> String:
	if level.world_to_map(player.global_position) in disconnector_locations:
		return "disconnector"
	elif level.world_to_map(player.global_position) in connector_locations:
		return "connector"			
	elif level.world_to_map(player.global_position) in goal_locations:
		return "goal"
	return ""

func resolve_turn () -> void:
	for player in players:
		var tile_object = check_tile_object(player)
		match tile_object:
			"disconnector":
				player.add_command(CommandManager.disable_control)
			"connector":
				player.add_command(CommandManager.step_on_connector)
			"goal":
				player.add_command(CommandManager.score_goal)

		player.execute_newest_commands()
		
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
	

