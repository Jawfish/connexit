extends Button

export (PackedScene) var level: PackedScene

func _on_LevelButton_pressed() -> void:
	SceneManager.transition_to_scene(level)
