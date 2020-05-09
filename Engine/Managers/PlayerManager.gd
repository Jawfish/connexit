extends Node

onready var player_scene: PackedScene = preload("res://Entities/Player.tscn")
var can_move: bool = false
var players: Array

func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")

func _physics_process(delta: float) -> void:
	if can_move:
		for player in players:
			if not player.control_disabled:
				if Input.is_action_pressed("ui_up") and not player.ray_n.is_colliding():
					move_to(player, Vector2(player.position.x, player.position.y - GameManager.TILE_SIZE))
				elif Input.is_action_pressed("ui_down") and not player.ray_s.is_colliding():
					move_to(player, Vector2(player.position.x, player.position.y + GameManager.TILE_SIZE))
				elif Input.is_action_pressed("ui_left") and not player.ray_w.is_colliding():
					move_to(player, Vector2(player.position.x - GameManager.TILE_SIZE, player.position.y))
				elif Input.is_action_pressed("ui_right") and not player.ray_e.is_colliding():
					move_to(player, Vector2(player.position.x + GameManager.TILE_SIZE, player.position.y))

func move_to(player: Player, pos: Vector2) -> void:
	if player.last_position == null || pos != player.last_position.back():
		player.last_position.append(player.position)
	var tween: Tween = Tween.new()
	add_child(tween)
	can_move = false
	tween.interpolate_property(player, "position", player.position, pos, 0.15, Tween.TRANS_QUINT)
	tween.start()
	yield(tween, "tween_completed")
	can_move = true
	
func _on_scene_changed() -> void:
	players.clear()
