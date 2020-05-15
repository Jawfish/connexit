extends "res://Engine/Commands/ActorCommand.gd"

export (Vector2) var direction: Vector2 = Vector2.ZERO

func execute() -> void:
	var actor_cell = level.world_to_map(actor.global_position)
	actor.global_position = level.map_to_world(actor_cell + direction)
	actor.global_position += Vector2(32, 32)
	
func unexecute() -> void:
	var actor_cell = level.world_to_map(actor.global_position)
	actor.global_position = level.map_to_world(actor_cell - direction)
	actor.global_position += Vector2(32, 32)
	queue_free()
	###	tween.interpolate_property(player, "position", player.position, new_position, time, Tween.TRANS_QUINT)
#	if new_position.x != player.position.x:
##		tween.interpolate_property(player, "scale", player.scale, Vector2(1, 0.66), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
##		tween.interpolate_property(player, "scale", player.scale, Vector2(1, 1), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, time / 2)
#	elif new_position.y != player.position.y:
##		tween.interpolate_property(player, "scale", player.scale, Vector2(0.66, 1), time / 2, Tween.TRANS_LINEAR)
##		tween.interpolate_property(player, "scale", player.scale, Vector2(1, 1), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, time / 2)
#	tween.start()
#	yield(tween, "tween_all_completed")
