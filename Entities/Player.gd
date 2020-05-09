extends ColorSchemeObject

class_name Player

onready var ray_n: RayCast2D = $RayN
onready var ray_s: RayCast2D = $RayS
onready var ray_e: RayCast2D = $RayE
onready var ray_w: RayCast2D = $RayW

func _init() -> void:
	color_object = 'player'

func _input(event: InputEvent) -> void:
		if event.is_action_pressed("ui_up") and not ray_n.is_colliding():
			position.y -= GameManager.TILE_SIZE
		elif event.is_action_pressed("ui_down") and not ray_s.is_colliding():
			position.y += GameManager.TILE_SIZE
		elif event.is_action_pressed("ui_left") and not ray_w.is_colliding():
			position.x -= GameManager.TILE_SIZE
		elif event.is_action_pressed("ui_right") and not ray_e.is_colliding():
			position.x += GameManager.TILE_SIZE
