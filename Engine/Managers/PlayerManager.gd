extends Node

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")

var players: Array
var tween: Tween
var walk_sound_player: AudioStreamPlayer
onready var walk_sound: AudioStream = preload("res://Assets/Sounds/rollover2.ogg")

func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")
	tween = Tween.new()
	add_child(tween)
	walk_sound_player = AudioStreamPlayer.new()
	walk_sound_player.stream = walk_sound
	add_child(walk_sound_player)
		
func _process(delta: float) -> void:
		if (Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_right")) and not tween.is_active() and not all_players_stuck():
			for player in players:
				player.last_position.append(player.position)
				if not player.control_disabled:
					if Input.is_action_pressed("ui_up") and not player.ray_n.is_colliding():
						move_to(player, Vector2(player.position.x, player.position.y - GameManager.TILE_SIZE))
					elif Input.is_action_pressed("ui_down") and not player.ray_s.is_colliding():
						move_to(player, Vector2(player.position.x, player.position.y + GameManager.TILE_SIZE))
					elif Input.is_action_pressed("ui_left") and not player.ray_w.is_colliding():
						move_to(player, Vector2(player.position.x - GameManager.TILE_SIZE, player.position.y))
					elif Input.is_action_pressed("ui_right") and not player.ray_e.is_colliding():
						move_to(player, Vector2(player.position.x + GameManager.TILE_SIZE, player.position.y))

func _on_scene_changed() -> void:
	players.clear()

func move_to(player: Player, new_position: Vector2, time = 0.15) -> void:
	play_piece_move_sfx()
	tween.interpolate_property(player, "position", player.position, new_position, time, Tween.TRANS_QUINT)
	tween.start()

func all_players_stuck() -> bool:
	for player in players:
		if (player.control_disabled == false):
			return false
	return true
	
func play_piece_move_sfx() -> void:
	if not walk_sound_player.playing:
		walk_sound_player.pitch_scale = rand_range(0.9, 1.05)
		walk_sound_player.volume_db = rand_range(-40,-38)
		walk_sound_player.play()
