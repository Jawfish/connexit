extends "res://Engine/Commands/ActorCommand.gd"


func execute() -> void:
	actor.disable_control()

func unexecute() -> void:
	actor.enable_control()
	queue_free()
