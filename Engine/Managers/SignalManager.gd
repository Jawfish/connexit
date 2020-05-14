extends Node

# colors
# warning-ignore:unused_signal
signal color_scheme_changed

# transitions
# warning-ignore:unused_signal
signal transition_to_level(index)
# warning-ignore:unused_signal
signal transition_to_next_level
# warning-ignore:unused_signal
signal slide_down_start
# warning-ignore:unused_signal
signal slide_down_finish
# warning-ignore:unused_signal
signal slide_up_finish

# level events
# warning-ignore:unused_signal
signal players_finished_spawning
# warning-ignore:unused_signal
signal level_complete

# player events
# warning-ignore:unused_signal
signal player_started_moving
# warning-ignore:unused_signal
signal player_finished_moving
