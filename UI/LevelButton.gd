extends Button

export (PackedScene) var level: PackedScene

func _ready() -> void:
	connect("mouse_entered", get_parent().get_parent().get_parent(), "_on_level_select_mouse_entered", [text])

func _on_LevelButton_pressed() -> void:
	AudioManager.click.play()
	yield(AudioManager.click, "finished")
	SceneManager.transition_to_scene(level)


func _on_LevelButton_mouse_entered() -> void:
	AudioManager.hover.pitch_scale = rand_range(0.9, 1.1)
	AudioManager.hover.play()
