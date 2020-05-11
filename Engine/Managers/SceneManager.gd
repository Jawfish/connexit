extends Node

var wall: PackedScene = preload("res://Levels/Construction/Wall.tscn")
var game_ui: PackedScene = preload("res://UI/GameUI.tscn")
var level: PackedScene = preload("res://Levels/Level.tscn")
var current_level: PackedScene

var levels = {
	'Level 1' : preload("res://Levels/Level1.tscn"),
	'Level 2' : preload("res://Levels/Level2.tscn")
}

func transition_to_scene(level_name: String) -> void:
	current_level = levels[level_name]
	SignalManager.emit_signal("scene_changed")
	get_tree().change_scene_to(levels[level_name])
	ColorSchemes.change_theme()

func reload_current_scene() -> void:
	SignalManager.emit_signal("scene_changed")	
	get_tree().change_scene_to(current_level)
	ColorSchemes.change_theme()
