extends "res://Engine/Commands/ActorCommand.gd"

func execute() -> void:
	pass
		
func unexecute() -> void:
	queue_free()
