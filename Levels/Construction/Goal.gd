extends ColorSchemeObject

onready var sprite: Sprite = $Sprite
export(String) var next_level: String

func _init() -> void:
	color_object = 'Objects'

func _ready() -> void:
	sprite.self_modulate = Color(1, 1, 1, 0.5)

func _process(delta: float) -> void:
	sprite.rotate(0.025)


func _on_Area2D_body_entered(body: Node) -> void:
	body.get_parent().score_goal()