extends Node

onready var tween: Tween = $Tween
onready var color_rect: ColorRect = $CanvasLayer/ColorRect
onready var level_complete_sound: AudioStreamPlayer = $LevelCompleteSound
onready var slide_sound: AudioStreamPlayer = $SlideSound

var current_level: int = -1

var levels: Array = [
			load("res://Levels/Level1.tscn"),
			load("res://Levels/Level2.tscn"),
			load("res://Levels/Level3.tscn"),
			load("res://Levels/Level4.tscn"),
			load("res://Levels/Level5.tscn"),
			load("res://Levels/Level6.tscn"),
			load("res://Levels/Level7.tscn"),
			load("res://Levels/Level8.tscn"),
			load("res://Levels/Level9.tscn"),
			load("res://Levels/Level10.tscn"),
			load("res://Levels/Level11.tscn"),
			load("res://Levels/Level12.tscn"),
			load("res://Levels/Level13.tscn"),
			load("res://Levels/Level14.tscn"),
			load("res://Levels/Level15.tscn"),
			load("res://Levels/Level16.tscn"),
			load("res://Levels/Level17.tscn"),
			load("res://Levels/Level18.tscn"),
			load("res://Levels/Level19.tscn"),
			load("res://Levels/Level20.tscn")
			]

func _ready() -> void:
	SignalManager.connect("transition_to_level", self, "transition_to_level")
	SignalManager.connect("transition_to_next_level", self, "_on_transition_to_next_level")	
	SignalManager.connect("level_complete", self, "_on_level_complete")

func transition_to_level(index: int) -> void:
	SignalManager.emit_signal("slide_down_start")
	slide_down()
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(GameManager.TURN_TIME), "timeout")	
	SignalManager.emit_signal("slide_down_finish")
	get_tree().change_scene_to(levels[current_level])
	slide_up()
	yield(tween, "tween_all_completed")
	SignalManager.emit_signal("slide_up_finish")

func _on_transition_to_next_level() -> void:
	current_level += 1
	transition_to_level(current_level)	
	
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
