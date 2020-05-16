extends Node

onready var tween: Tween = $Tween
onready var color_rect: ColorRect = $CanvasLayer/ColorRect
onready var level_complete_sound: AudioStreamPlayer = $LevelCompleteSound
onready var slide_sound: AudioStreamPlayer = $SlideSound
onready var main_menu: PackedScene = load("res://UI/MainMenu.tscn")
onready var level_select: PackedScene = load("res://UI/LevelSelect.tscn")

var current_level: Node2D

var levels: Dictionary = {
			"Level 1": load("res://Levels/Level1.tscn"),
			"Level 2": load("res://Levels/Level2.tscn"),
			"Level 3": load("res://Levels/Level3.tscn"),
			"Level 4": load("res://Levels/Level4.tscn"),
			"Level 5": load("res://Levels/Level5.tscn"),
			"Level 6": load("res://Levels/Level6.tscn"),
			"Level 7": load("res://Levels/Level7.tscn"),
			"Level 8": load("res://Levels/Level8.tscn"),
			"Level 9": load("res://Levels/Level9.tscn"),
			"Level 10": load("res://Levels/Level10.tscn"),
#			load("res://Levels/Level11.tscn"),
#			load("res://Levels/Level12.tscn"),
#			load("res://Levels/Level13.tscn"),
#			load("res://Levels/Level14.tscn"),
#			load("res://Levels/Level15.tscn"),
#			load("res://Levels/Level16.tscn"),
#			load("res://Levels/Level17.tscn"),
#			load("res://Levels/Level18.tscn"),
#			load("res://Levels/Level19.tscn"),
#			load("res://Levels/Level20.tscn")
			}

func reload_level() -> void:
	transition_to_scene(levels[current_level.level_name])

func start_game() -> void:
	transition_to_scene(levels['Level 1'])

func transition_to_scene(scene: PackedScene) -> void:
	SignalManager.emit_signal("slide_down_start")
	slide_down()
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")	
	SignalManager.emit_signal("slide_down_finish")
	get_tree().change_scene_to(scene)
	slide_up()
	yield(tween, "tween_all_completed")
	SignalManager.emit_signal("slide_up_finish")
	
func slide_down() -> void:
	tween.interpolate_property(color_rect, "margin_bottom", color_rect.margin_bottom, 0, GameManager.TURN_TIME, Tween.TRANS_QUINT)	
	tween.start()
	slide_sound.pitch_scale = 1
	slide_sound.play()

func slide_up() -> void:
	tween.interpolate_property(color_rect, "margin_bottom", color_rect.margin_bottom, -641, GameManager.TURN_TIME, Tween.TRANS_QUINT)	
	tween.start()	
	slide_sound.pitch_scale = 1.1
	slide_sound.play()
	
func _on_level_complete() -> void:
	level_complete_sound.play()
