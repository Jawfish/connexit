extends Node2D

class_name Level

onready var level_name_label: Label = $Labels/LevelName
onready var player_manager: PlayerManager = $PlayerManager
onready var map: TileMap = $TileMap

var objects: Array = [
				preload("res://Levels/Construction/Spawn.tscn"),
				preload("res://Levels/Construction/Goal.tscn"),
				preload("res://Levels/Construction/Disconnector.tscn"),
				preload("res://Levels/Construction/Connector.tscn")
				]

func _ready() -> void:
	generate_level()
	level_name_label.text = "Level " + str(SceneManager.current_level + 1)	
	for label in get_tree().get_nodes_in_group("Label"):
		label.add_color_override("font_color", ColorSchemes.current_theme['Player'])

func generate_level() -> void:
	for tile in map.get_used_cells():
		var tile_index: int = map.get_cellv(tile)
		if tile_index != 0:
			map.set_cellv(tile, -1)			
			var object
			var tile_position := Vector2(
								 map.map_to_world(tile).x + round(GameManager.TILE_SIZE / 2), 
								 map.map_to_world(tile).y + round(GameManager.TILE_SIZE / 2))

			match tile_index:
				1:
					object = objects[0].instance()
				2:
					object = objects[1].instance()
					player_manager.goal_locations.append(tile)
				3:
					object = objects[2].instance()
					player_manager.disconnector_locations.append(tile)					
				4: 
					object = objects[3].instance()
					player_manager.connector_locations.append(tile)		
								
			object.position.x = tile_position.x
			object.position.y = tile_position.y
			add_child(object)
