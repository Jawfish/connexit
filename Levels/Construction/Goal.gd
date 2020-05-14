extends ColorSchemeObject

onready var sprite: Sprite = $Sprite

func _init() -> void:
	color_object = 'Objects'

func _process(delta: float) -> void:
	sprite.rotate(-0.025 * delta * 100)
