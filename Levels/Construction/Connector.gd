extends ColorSchemeObject

class_name Connector

onready var area: Area2D = $Area2D
export(bool) var disconnector: bool

func _init() -> void:
	color_object = 'Objects'

func _on_Area2D_body_entered(body: Node) -> void:
	if not Input.is_action_pressed("undo"):
		if disconnector:
			for player in get_tree().get_nodes_in_group('Player'):
				if player != body.get_parent():
					player.disable_control()
		else:
			for player in get_tree().get_nodes_in_group('Player'):
				player.enable_control()
