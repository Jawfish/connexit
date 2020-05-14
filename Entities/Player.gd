extends Node2D

class_name Player

export var control_disabled: bool = false

onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var disconnected_sprite: Sprite = $DisconnectedSprite
onready var pop: AudioStreamPlayer2D = $Goal
onready var pop_reverse: AudioStreamPlayer2D = $Ungoal
enum states {POSITION, CONTROL_DISABLED, LAST_POSITION, GOAL_REACHED, CONNECTABLE, CONTROLLABLE_PREVIOUS_TURN}

var turn_states: Array
var last_position: Vector2
var goal_reached: bool 
var connectable: bool = true
var controllable_previous_turn: bool = true
var grid_location: Vector2 = Vector2.ZERO	
	
func disable_control() -> void:
	if not control_disabled and connectable:
		control_disabled = true
		$AnimationPlayer.play("Disconnected")
		$Disconnected.play()

func enable_control() -> void:
	if control_disabled and connectable:
		control_disabled = false
		$AnimationPlayer.play_backwards("Disconnected")		
		$Connected.play()

func get_location_on_grid() -> Vector2:
	grid_location.x = round((position.x - 32) / GameManager.TILE_SIZE)
	grid_location.y = round((position.y -32 )/ GameManager.TILE_SIZE)
	return grid_location

func score_goal(tween_time: float = 0.5) -> void:
	disconnected_sprite.visible = false
# warning-ignore:return_value_discarded
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2.ZERO, tween_time, Tween.TRANS_QUINT)
# warning-ignore:return_value_discarded
	tween.interpolate_property(sprite, "rotation", sprite.rotation, -3, tween_time, Tween.TRANS_QUINT)
# warning-ignore:return_value_discarded
	tween.start()
	goal_reached = true
	if not control_disabled:
		control_disabled = true
	connectable = false	
	# do not use call_deferred on this, the debugger is wrong
	if not pop.is_playing():
		pop.pitch_scale = rand_range(0.9,1.1)
		pop.play()
	yield(tween, "tween_all_completed")

func unscore_goal(tween_time: float = 0.5) -> void:
	disconnected_sprite.visible = true	
# warning-ignore:return_value_discarded
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.25, 0.25), tween_time, Tween.TRANS_QUINT)
# warning-ignore:return_value_discarded
	tween.interpolate_property(sprite, "rotation", sprite.rotation, 0, tween_time, Tween.TRANS_QUINT)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween, "tween_all_completed")
	goal_reached = false
	if control_disabled:
		control_disabled = false
	connectable = true
	# do not use call_deferred on this, the debugger is wrong	
	if not pop_reverse.is_playing():
		pop_reverse.pitch_scale = rand_range(0.9,1.1)
		pop_reverse.play()
		
func add_turn_state() -> void:
	turn_states.append([position, control_disabled, last_position, goal_reached, connectable, controllable_previous_turn])
	print(self.name + ' added turn state: ' + str(turn_states.back()))
	
func get_state(state: int):
	var result = turn_states.back()[state]
	return result

func rewind() -> void:
	print(self.name + ' removed turn state: ' + str(turn_states.pop_back()))	

func match_state(state: int) -> bool:
	if turn_states.size() > 1:
		var s
		match state:
			0: s = position
			1: s = control_disabled
			2: s = last_position
			3: s = goal_reached
			4: s = connectable
			5: s = controllable_previous_turn
		return turn_states.back()[state] == s
	return true
