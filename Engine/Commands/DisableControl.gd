extends "res://Engine/Commands/ActorCommand.gd"


func execute() -> void:
	if not actor.goal_reached:
		if 'connect' in actor.get_next_to_last_command().name.to_lower() or 'control' in actor.get_next_to_last_command().name.to_lower():
			actor.get_next_to_last_command().unexecute()
		actor.disable_control()

func unexecute() -> void:
	if not actor.goal_reached:
		actor.enable_control()
	queue_free()
