extends Node2D

class_name Player


onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var disconnected_sprite: Sprite = $DisconnectedSprite
onready var goal_score_sound: AudioStreamPlayer2D = $Goal
onready var goal_score_sound_reverse: AudioStreamPlayer2D = $Ungoal

var control_disabled: bool = false
var goal_reached: bool = false
var connectable: bool = true
var commands: Array

func add_command(command: PackedScene) -> void:
	var cmd = command.instance()
	cmd.actor = self
	$CommandQueue.add_child(cmd)
	commands.append(cmd)

func execute_last_command() -> void:
	$CommandQueue.execute_last()	

func execute_newest_commands() -> void:
	for command in commands:
		command.execute()
	commands.clear()
	
func get_command(index: int) -> Node:
	return $CommandQueue.get_child(index)

func get_next_to_last_command() -> Node:
	return $CommandQueue.get_child($CommandQueue.get_children().size() - 2)

func get_last_command() -> Node:
	return $CommandQueue.get_children().back()

func toggle_connectable() -> void:
	connectable = !connectable

func toggle_goal_reached() -> void:
	goal_reached = !goal_reached

func disable_control() -> void:
	if not connectable:
		return
	if not control_disabled:
		control_disabled = true	
		$AnimationPlayer.play("Disconnected")
		$Disconnected.play()

func enable_control() -> void:
	if not connectable:
		return
	if control_disabled:
		control_disabled = false
		$AnimationPlayer.play_backwards("Disconnected")		
		$Connected.play()

func toggle_goal() -> void:
	var tween_time: float = 0.5	
	if goal_reached:
		disconnected_sprite.visible = true	
		tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.25, 0.25), tween_time, Tween.TRANS_QUINT)
		tween.interpolate_property(sprite, "rotation", sprite.rotation, 0, tween_time, Tween.TRANS_QUINT)
		tween.start()
		goal_reached = false
		if control_disabled:
			control_disabled = false
		toggle_connectable()
		if not goal_score_sound_reverse.is_playing():
			goal_score_sound_reverse.pitch_scale = rand_range(0.9,1.1)
			goal_score_sound_reverse.play()
	else:
		disconnected_sprite.visible = false
		tween.interpolate_property(sprite, "scale", sprite.scale, Vector2.ZERO, tween_time, Tween.TRANS_QUINT)
		tween.interpolate_property(sprite, "rotation", sprite.rotation, -3, tween_time, Tween.TRANS_QUINT)
		tween.start()
		goal_reached = true
		if not control_disabled:
			control_disabled = true
		toggle_connectable()	
		if not goal_score_sound.is_playing():
			goal_score_sound.pitch_scale = rand_range(0.9,1.1)
			goal_score_sound.play()
