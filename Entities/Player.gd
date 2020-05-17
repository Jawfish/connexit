extends Node2D

class_name Player

onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var disconnected_sprite: Sprite = $DisconnectedSprite
onready var goal_score_sound: AudioStreamPlayer2D = $Goal
onready var goal_score_sound_reverse: AudioStreamPlayer2D = $Ungoal
onready var level: TileMap = $"/root/Level/TileMap"

var control_disabled: bool = false
var goal_reached: bool = false
var connectable: bool = true
var immune: bool = false
var phaser: bool = false
var last_position: Vector2
var checked_tile

func _ready() -> void:
	if immune:
		sprite.texture = load("res://Assets/Triangle.svg")	
	elif phaser:
		sprite.texture = load("res://Assets/Phaser.svg")	

func move(direction: Vector2) -> void:
	var cell = level.world_to_map(global_position)
	var new_position = level.map_to_world(cell + direction) + Vector2(32, 32)
	tween.interpolate_property(self, "position", position, new_position, GameManager.TURN_TIME, Tween.TRANS_QUINT)
	tween.start()
	if new_position.x != position.x:
		tween.interpolate_property(self, "scale", scale, Vector2(1, 0.66), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(self, "scale", scale, Vector2(1, 1), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, GameManager.TURN_TIME / 2)
	elif new_position.y != position.y:
		tween.interpolate_property(self, "scale", scale, Vector2(0.66, 1), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR)
		tween.interpolate_property(self, "scale", scale, Vector2(1, 1), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, GameManager.TURN_TIME / 2)
	if immune:
		if new_position.x < position.x:
			tween.interpolate_property(sprite, "rotation", sprite.rotation, deg2rad(-90), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)		
		elif new_position.x > position.x:
			tween.interpolate_property(sprite, "rotation", sprite.rotation, deg2rad(90), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)				
		elif new_position.y < position.y:
			tween.interpolate_property(sprite, "rotation", sprite.rotation, 0, GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)				
		elif new_position.y > position.y:
			tween.interpolate_property(sprite, "rotation", sprite.rotation, deg2rad(180), GameManager.TURN_TIME / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)				
		
	tween.start()
	yield(tween, "tween_all_completed")
	last_position = global_position	

func set_immune() -> void:
	immune = true
	
func set_phasing() -> void:
	phaser = true
	
func toggle_connectable() -> void:
	connectable = !connectable

func toggle_goal_reached() -> void:
	goal_reached = !goal_reached

func disable_control() -> void:
	if immune or goal_reached or not connectable:
		return
	if not control_disabled:
		control_disabled = true	
		$AnimationPlayer.play("Disconnected")
		$Disconnected.play()

func enable_control() -> void:
	if immune or goal_reached or not connectable:
		return
	if control_disabled:
		control_disabled = false
		$AnimationPlayer.play_backwards("Disconnected")		
		$Connected.play()

func score_goal() -> void:
	if goal_reached:
		return
	disconnected_sprite.visible = false
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2.ZERO, 0.5, Tween.TRANS_QUINT)
	tween.interpolate_property(sprite, "rotation", sprite.rotation, -3, 0.5, Tween.TRANS_QUINT)
	tween.start()
	goal_reached = true
	if not control_disabled:
		control_disabled = true
	toggle_connectable()	
	if not goal_score_sound.is_playing():
		goal_score_sound.pitch_scale = rand_range(0.9,1.1)
		goal_score_sound.play()
