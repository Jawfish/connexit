extends TextureButton

func _ready() -> void:
	SignalManager.connect("color_scheme_changed", self, "update_color", ["Player"])
	update_color('Player')

func update_color(object: String) -> void:
	modulate = ColorSchemes.current_theme[object]

func _on_BackButton_mouse_entered() -> void:
	AudioManager.hover.play()		
	update_color('Objects')


func _on_BackButton_mouse_exited() -> void:
	AudioManager.hover.play()	
	update_color('Player')


func _on_BackButton_pressed() -> void:
	AudioManager.click.play()
	yield(AudioManager.click, "finished")		
	SceneManager.transition_to_scene(SceneManager.main_menu)
