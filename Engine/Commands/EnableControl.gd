extends "res://Engine/Commands/ActorCommand.gd"


func execute() -> void:
	actor.enable_control()

func unexecute() -> void:
#	actor.disable_control()
	queue_free()
