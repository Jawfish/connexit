extends "res://Engine/Commands/ActorCommand.gd"


func execute() -> void:
	if not actor.goal_reached:
		actor.enable_control()

func unexecute() -> void:
	if "nothing" in actor.get_next_to_last_command().name.to_lower() and not actor.goal_reached:
		actor.disable_control()
	queue_free()
