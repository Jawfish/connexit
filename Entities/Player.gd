extends ColorSchemeObject

class_name Player

export var control_disabled: bool = false

onready var ray_n: RayCast2D = $RayN
onready var ray_s: RayCast2D = $RayS
onready var ray_e: RayCast2D = $RayE
onready var ray_w: RayCast2D = $RayW
onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var disconnected_sprite: Sprite = $DisconnectedSprite
onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

enum states {POSITION, CONTROL_DISABLED, LAST_POSITION, GOAL_REACHED, CONNECTABLE, CONTROLLABLE_PREVIOUS_TURN}

var turn_states: Array
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
	connectable = false	
	disable_collision()
	disconnected_sprite.visible = false
	var tween_time: float = 0.5
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2.ZERO, tween_time, Tween.TRANS_QUINT)
	tween.interpolate_property(sprite, "rotation", sprite.rotation, 3, tween_time, Tween.TRANS_QUINT)
	tween.start()
	goal_reached = true
	if not control_disabled:
		control_disabled = true
	
func unscore_goal(tween_time = 0.5) -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.25, 0.25), tween_time, Tween.TRANS_QUINT)
	tween.interpolate_property(sprite, "rotation", sprite.rotation, 0, tween_time, Tween.TRANS_QUINT)
	tween.start()
	goal_reached = false
	if control_disabled:
		control_disabled = false
	connectable = true
	enable_collision()
	
func add_turn_state() -> void:
	turn_states.append([position, control_disabled, last_position, goal_reached, connectable, controllable_previous_turn])
	
func get_state(state: int):
	var result = turn_states.back()[state]
	return result

func rewind() -> void:
	turn_states.pop_back()

func disable_collision() -> void:
	collision.scale *= 0
	collision.disabled = true
	
func enable_collision() -> void:
	collision.scale = Vector2(1,1)	
	collision.disabled = false
	

func match_state(state: int) -> bool:
	if turn_states.size() > 1:
		var s
		match state:
			0: s = position
			1: s = control_disabled
			2: s = last_position
			3: s = goal_reached
			4: s = connectable
			5: s = controllable_previous_turn
		return turn_states.back()[state] == s
	return true
