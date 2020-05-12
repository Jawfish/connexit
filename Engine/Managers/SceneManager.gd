extends Node

onready var tween: Tween = $Tween
onready var color_rect: ColorRect = $CanvasLayer/ColorRect
onready var level_complete_sound: AudioStreamPlayer = $LevelCompleteSound
onready var slide_sound: AudioStreamPlayer = $SlideSound

var wall: PackedScene = preload("res://Levels/Construction/Wall.tscn")
var level: PackedScene = preload("res://Levels/Level.tscn")
var current_level: String

var levels = {
	'Level 1' : preload("res://Levels/Level1.tscn"),
	'Level 2' : preload("res://Levels/Level2.tscn"),
	'Level 3' : preload("res://Levels/Level3.tscn"),
	'Level 4' : preload("res://Levels/Level4.tscn"),
	'Level 5' : preload("res://Levels/Level5.tscn"),
	'Level 6' : preload("res://Levels/Level6.tscn"),
#	'Level 7' : preload("res://Levels/Level7.tscn"),
#	'Level 8' : preload("res://Levels/Level8.tscn"),
#	'Level 9' : preload("res://Levels/Level9.tscn"),
#	'Level 10' : preload("res://Levels/Level10.tscn"),
#	'Level 11' : preload("res://Levels/Level11.tscn"),
#	'Level 12' : preload("res://Levels/Level12.tscn"),
#	'Level 13' : preload("res://Levels/Level13.tscn"),
#	'Level 14' : preload("res://Levels/Level14.tscn"),
#	'Level 15' : preload("res://Levels/Level15.tscn"),
#	'Level 16' : preload("res://Levels/Level16.tscn"),
#	'Level 17' : preload("res://Levels/Level17.tscn"),
#	'Level 18' : preload("res://Levels/Level18.tscn"),
#	'Level 19' : preload("res://Levels/Level19.tscn"),
#	'Level 20' : preload("res://Levels/Level20.tscn"),
#	'Level 21' : preload("res://Levels/Level21.tscn"),
#	'Level 22' : preload("res://Levels/Level22.tscn"),
#	'Level 23' : preload("res://Levels/Level23.tscn"),
#	'Level 24' : preload("res://Levels/Level24.tscn"),
#	'Level 25' : preload("res://Levels/Level25.tscn"),
#	'Level 26' : preload("res://Levels/Level26.tscn"),
#	'Level 27' : preload("res://Levels/Level27.tscn"),
#	'Level 28' : preload("res://Levels/Level28.tscn"),
#	'Level 29' : preload("res://Levels/Level29.tscn"),
#	'Level 30' : preload("res://Levels/Level30.tscn"),
#	'Level 31' : preload("res://Levels/Level31.tscn"),
#	'Level 32' : preload("res://Levels/Level32.tscn"),
#	'Level 33' : preload("res://Levels/Level33.tscn"),
#	'Level 34' : preload("res://Levels/Level34.tscn"),
#	'Level 35' : preload("res://Levels/Level35.tscn"),
#	'Level 36' : preload("res://Levels/Level36.tscn"),
#	'Level 37' : preload("res://Levels/Level37.tscn"),
#	'Level 38' : preload("res://Levels/Level38.tscn"),
#	'Level 39' : preload("res://Levels/Level39.tscn"),
#	'Level 40' : preload("res://Levels/Level40.tscn"),
#	'Level 41' : preload("res://Levels/Level41.tscn"),
#	'Level 42' : preload("res://Levels/Level42.tscn"),
#	'Level 43' : preload("res://Levels/Level43.tscn"),
#	'Level 44' : preload("res://Levels/Level44.tscn"),
#	'Level 45' : preload("res://Levels/Level45.tscn"),
#	'Level 46' : preload("res://Levels/Level46.tscn"),
#	'Level 47' : preload("res://Levels/Level47.tscn"),
#	'Level 48' : preload("res://Levels/Level48.tscn"),
#	'Level 49' : preload("res://Levels/Level49.tscn"),
#	'Level 50' : preload("res://Levels/Level50.tscn")
}

func _ready() -> void:
	SignalManager.connect("transition_to_level", self, "transition_to_level")
	SignalManager.connect("level_complete", self, "_on_level_complete")

func transition_to_level(level_name: String) -> void:
	SignalManager.emit_signal("scene_change_start")
	slide_down()
	yield(tween, "tween_all_completed")
	unload_scene()
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")	
	SignalManager.emit_signal("scene_changed")
	get_tree().change_scene_to(levels[level_name])
	current_level = level_name
	slide_up()
	yield(tween, "tween_all_completed")

func unload_scene() -> void:
	get_tree().current_scene.queue_free()

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
