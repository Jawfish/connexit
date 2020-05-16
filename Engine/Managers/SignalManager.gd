extends Node

# colors
signal color_scheme_changed

# transitions
signal transition_to_level(index)
signal transition_to_next_level
signal slide_down_start
signal slide_down_finish
signal slide_up_finish

# level events
signal players_finished_spawning
signal level_complete

# player events
signal player_started_moving
signal player_finished_moving
