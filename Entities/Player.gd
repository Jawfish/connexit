extends ColorSchemeObject

class_name Player

onready var ray_n: RayCast2D = $RayN
onready var ray_s: RayCast2D = $RayS
onready var ray_e: RayCast2D = $RayE
onready var ray_w: RayCast2D = $RayW
onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var disconnected_sprite: Sprite = $DisconnectedSprite

var last_position: Array
var control_disabled: bool = false

func _init() -> void:
	color_object = 'Player'
	
func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")
	PlayerManager.players.append(self)
	disconnected_sprite.modulate = Color(2, 2, 2, 1)

func _on_scene_changed():
	queue_free()

func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	if anim_name == "Spawn":
		PlayerManager.can_move = false

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Spawn":
		PlayerManager.can_move = true

func disable_control() -> void:
	control_disabled = true
	disconnected_sprite.visible = true	

func enable_control() -> void:
	control_disabled = false
	disconnected_sprite.visible = false

