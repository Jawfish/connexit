extends ColorSchemeObject

class_name Level

func _init() -> void:
	color_object = 'walls'

func _ready() -> void:
	generate_outer_walls()
					
func spawn_player(pos: Vector2) -> void:
	var player: Player = PlayerManager.player_scene.instance()
	player.position = pos
	add_child(player)

func generate_outer_walls() -> void:
	var tile_size: int = GameManager.TILE_SIZE
	var tile_offset: int = tile_size / 2
	for i in get_viewport_rect().size.x / tile_size:
		for j in get_viewport_rect().size.y / tile_size:
			if (i == 0 or i == get_viewport_rect().size.x / tile_size - 1)  or (j == 0 or j == get_viewport_rect().size.y / tile_size - 1):
				var wall: Node2D = SceneManager.wall.instance()
				wall.position = Vector2(tile_size * i + tile_offset, tile_size * j + tile_offset)
				add_child(wall)
