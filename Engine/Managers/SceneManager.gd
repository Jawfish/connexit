extends Node

onready var tween: Tween = $Tween
onready var color_rect: ColorRect = $CanvasLayer/ColorRect

var wall: PackedScene = preload("res://Levels/Construction/Wall.tscn")
var game_ui: PackedScene = preload("res://UI/GameUI.tscn")
var level: PackedScene = preload("res://Levels/Level.tscn")
var current_level: PackedScene
var transition_period: float = 0.33
var wait_period: float = 0.2

var levels = {
	'Level 1' : preload("res://Levels/Level1.tscn"),
	'Level 2' : preload("res://Levels/Level2.tscn")
}

func transition_to_scene(level_name: String) -> void:
	InputManager.block_input = true
	SignalManager.emit_signal("scene_change_start")
	slide_down()
	yield(tween, "tween_all_completed")
	get_tree().current_scene.queue_free()
	yield(get_tree().create_timer(wait_period), "timeout")	
	current_level = levels[level_name]
	SignalManager.emit_signal("scene_changed")
	get_tree().change_scene_to(levels[level_name])
	ColorSchemes.change_theme()
	slide_up()
	yield(tween, "tween_all_completed")
	SignalManager.emit_signal("scene_change_end")		

func reload_current_scene() -> void:
	InputManager.block_input = true	
	SignalManager.emit_signal("scene_change_start")	
	slide_down()
	yield(tween, "tween_all_completed")
	get_tree().current_scene.queue_free()
	yield(get_tree().create_timer(wait_period), "timeout")
	SignalManager.emit_signal("scene_changed")	
	get_tree().change_scene_to(current_level)
	ColorSchemes.change_theme()
	slide_up()
	yield(tween, "tween_all_completed")
	SignalManager.emit_signal("scene_change_end")

func slide_down() -> void:
	InputManager.block_input = true	
	tween.interpolate_property(color_rect, "margin_bottom", color_rect.margin_bottom, 0, transition_period, Tween.TRANS_ELASTIC)	
	tween.start()	

func slide_up() -> void:
	InputManager.block_input = true		
	tween.interpolate_property(color_rect, "margin_bottom", color_rect.margin_bottom, -641, transition_period, Tween.TRANS_ELASTIC)	
	tween.start()	
	
