extends Node2D

class_name Level

onready var level_name_label: Label = $Labels/LevelName
onready var player_manager: PlayerManager = $PlayerManager
onready var map: TileMap = $TileMap
onready var game_ui_scene: PackedScene = preload("res://UI/GameUI.tscn")
onready var game_ui: CanvasLayer = game_ui_scene.instance()

export(String) var level_name: String
export(PackedScene) var next_level: PackedScene

var objects: Array = [
				preload("res://Levels/Construction/Spawn.tscn"),
				preload("res://Levels/Construction/Goal.tscn"),
				preload("res://Levels/Construction/Disconnector.tscn"),
				preload("res://Levels/Construction/Connector.tscn")
				]

func _ready() -> void:
	SignalManager.connect("slide_up_finish", self, "_on_slide_up_finish")
	SceneManager.current_level = self
	generate_level()
	level_name_label.text = level_name
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
					$TileMap.goal_locations.append(tile)
				3:
					object = objects[2].instance()
					$TileMap.disconnector_locations.append(tile)					
				4: 
					object = objects[3].instance()
					$TileMap.connector_locations.append(tile)		
								
			object.position.x = tile_position.x
			object.position.y = tile_position.y
			add_child(object)

func _on_slide_up_finish() -> void:
	add_child(game_ui)
