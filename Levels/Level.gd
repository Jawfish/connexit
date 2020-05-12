extends Node2D

class_name Level

export var this_level: String
export var next_level: String

func _ready() -> void:
	generate_outer_walls()
	for label in get_tree().get_nodes_in_group("Label"):
		label.add_color_override("font_color", ColorSchemes.current_theme['Player'])	
	
func generate_outer_walls() -> void:
	var tile_size: int = GameManager.TILE_SIZE
	var tile_offset: int = tile_size / 2
	for i in get_viewport_rect().size.x / tile_size:
		for j in get_viewport_rect().size.y / tile_size:
			if (i == 0 or i == get_viewport_rect().size.x / tile_size - 1)  or (j == 0 or j == get_viewport_rect().size.y / tile_size - 1):
				var wall: Node2D = SceneManager.wall.instance()
				wall.position = Vector2(tile_size * i + tile_offset, tile_size * j + tile_offset)
				add_child(wall)
	SignalManager.emit_signal("level_loaded", this_level, next_level)	
