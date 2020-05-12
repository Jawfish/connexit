extends Node

# colors
signal color_scheme_changed

# transitions
signal transition_to_level(level_name)
# when the scene transition begins to fade in
signal scene_change_start
# after the scene transition has faded out, but before it has faded in
signal scene_changed

# level events
signal players_finished_spawning
signal level_complete
signal level_loaded(new_level, next_level)

# player events
signal player_started_moving
signal player_finished_moving

# input managing
signal block_input
signal unblock_input
