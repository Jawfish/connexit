extends "res://Engine/Commands/ActorCommand.gd"

export (float) var tween_time: float = 0.5

func execute() -> void:
	actor.toggle_goal()
	
func unexecute() -> void:
	actor.toggle_goal()
	queue_free()
