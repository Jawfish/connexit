extends "res://Engine/Commands/ActorCommand.gd"

export (float) var tween_time: float = 0.5

func execute() -> void:
	if 'control' in actor.get_next_to_last_command().name.to_lower():
		actor.get_next_to_last_command().unexecute()
	hide_disconnect_sprite()	
	actor.toggle_goal()
	
func unexecute() -> void:
	if 'control' in actor.get_next_to_last_command().name.to_lower():
		actor.get_next_to_last_command().unexecute()
	hide_disconnect_sprite()
	actor.toggle_goal()
	queue_free()

# workaround for disconnect sprite erroniously becoming visible
func hide_disconnect_sprite() -> void:
	actor.disconnected_sprite.visible = false
