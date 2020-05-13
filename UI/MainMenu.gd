extends Control

func _on_Button_pressed() -> void:
	SignalManager.emit_signal("transition_to_next_level")
