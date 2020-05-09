extends Node

var wall: PackedScene = preload("res://Levels/Construction/Wall.tscn")
var game_ui: PackedScene = preload("res://UI/GameUI.tscn")

var current_level: PackedScene

var levels: Dictionary = {
	"Intro": preload("res://Levels/Intro.tscn")
}

func transition_to_scene(level: PackedScene) -> void:
	SignalManager.emit_signal("scene_changed")
	current_level = level
	get_tree().change_scene_to(level)
	ColorSchemes.change_theme()
