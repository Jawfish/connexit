extends ColorSchemeObject

class_name Player

onready var ray_n: RayCast2D = $RayN
onready var ray_s: RayCast2D = $RayS
onready var ray_e: RayCast2D = $RayE
onready var ray_w: RayCast2D = $RayW
onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var disconnected_sprite: Sprite = $DisconnectedSprite
var turn_locations: Array
export var control_disabled: bool = false

var last_position: Vector2
var goal_reached: bool 
var connectable: bool = true
var controllable_previous_turn: bool = true

func _init() -> void:
	color_object = 'Player'
	
func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")
	PlayerManager.players.append(self)
	disconnected_sprite.modulate = Color(2, 2, 2, 1)
	turn_locations.append(position)

func _on_scene_changed():
	queue_free()

func disable_control() -> void:
	if not control_disabled and connectable:
		control_disabled = true
		disconnected_sprite.visible = true
		$Disconnected.play()

func enable_control() -> void:
	if control_disabled and connectable:
		control_disabled = false
		disconnected_sprite.visible = false
		$Connected.play()

func score_goal() -> void:
	disconnected_sprite.visible = false
	var tween_time: float = 0.5
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2.ZERO, tween_time, Tween.TRANS_QUINT)
	tween.interpolate_property(sprite, "rotation", sprite.rotation, 3, tween_time, Tween.TRANS_QUINT)
	tween.start()
	goal_reached = true
	if not control_disabled:
		control_disabled = true
	connectable = false
	$StaticBody2D/CollisionShape2D.scale *= 0

func unscore_goal(tween_time = 0.5) -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.25, 0.25), tween_time, Tween.TRANS_QUINT)
	tween.interpolate_property(sprite, "rotation", sprite.rotation, 0, tween_time, Tween.TRANS_QUINT)
	tween.start()
	goal_reached = false
	if control_disabled:
		control_disabled = false
	connectable = true
