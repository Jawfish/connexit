extends Level

func _ready() -> void:
	SceneManager.current_level = SceneManager.levels['Intro']
	spawn_players()
