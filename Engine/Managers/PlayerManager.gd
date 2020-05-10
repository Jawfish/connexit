extends Node

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")

var players: Array
var tween: Tween

func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")
	tween = Tween.new()
	add_child(tween)
		
func _process(delta: float) -> void:
	if not all_players_stuck():
		if (Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_right")) and not tween.is_active():
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
	tween.interpolate_property(player, "position", player.position, new_position, time, Tween.TRANS_QUINT)
	tween.start()

func all_players_stuck() -> bool:
	for player in players:
		if (player.control_disabled == false):
			return false
	return true
