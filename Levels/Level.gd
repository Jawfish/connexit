extends Node2D

class_name Level

func _ready() -> void:
	generate_outer_walls()
	var ui: CanvasLayer = SceneManager.game_ui.instance()
	add_child(ui)
	SignalManager.connect("scene_changed", self, "_on_scene_changed")					
	spawn_players()
	
func spawn_players() -> void:
	for spawn in get_tree().get_nodes_in_group("Spawn"):
		var player: Player = PlayerManager.player_scene.instance()
		player.position = spawn.position
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

func _on_scene_changed() -> void:
	queue_free()
