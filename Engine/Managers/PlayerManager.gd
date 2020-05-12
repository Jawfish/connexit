extends Node

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
onready var walk_sound: AudioStream = preload("res://Assets/Sounds/rollover2.ogg")
onready var level_complete_sound: AudioStream = preload("res://Assets/Sounds/success.ogg")

var players: Array
var tween: Tween
var walk_sound_player: AudioStreamPlayer
var level_complete_sound_player: AudioStreamPlayer
var next_level: String
var intended_direction: int

enum directions { NORTH, SOUTH, EAST, WEST }

func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")
	tween = Tween.new()
	add_child(tween)
	walk_sound_player = AudioStreamPlayer.new()
	walk_sound_player.stream = walk_sound
	add_child(walk_sound_player)
	level_complete_sound_player = AudioStreamPlayer.new()
	level_complete_sound_player.stream = level_complete_sound
	add_child(level_complete_sound_player)
	level_complete_sound_player.volume_db = -10

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_down"):
		intended_direction = directions.SOUTH
	elif Input.is_action_just_pressed("ui_up"):
		intended_direction = directions.NORTH
	elif Input.is_action_just_pressed("ui_left"):
		intended_direction = directions.WEST
	elif Input.is_action_just_pressed("ui_right"):
		intended_direction = directions.EAST
		
func _process(delta: float) -> void:
	if not InputManager.block_input:
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
					
func _on_scene_changed() -> void:
	players.clear()

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
		if is_instance_valid(player) and player.tween.is_active():
			return true
	return false

func play_piece_move_sfx() -> void:
	if not walk_sound_player.playing:
		walk_sound_player.pitch_scale = rand_range(0.9, 1.05)
		walk_sound_player.volume_db = rand_range(-5,-3)
		walk_sound_player.play()

func player_moving() -> bool:
	if not (Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up")):
		return false
	if tween.is_active():
		return false
	if player_animation_playing():
		return false
	if all_players_stuck():
		return false
	return true
	
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
	InputManager.block_input = true
	for player in players:
		if player.tween.is_active():
			yield(player.tween, "tween_all_completed")
		player.queue_free()
	players.clear()
	yield(get_tree().create_timer(0.5), "timeout")
	level_complete_sound_player.play()
	SceneManager.transition_to_scene(next_level)
