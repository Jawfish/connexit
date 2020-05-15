extends Node

onready var walk_north: PackedScene = preload("res://Engine/Commands/WalkUp.tscn")
onready var walk_south: PackedScene = preload("res://Engine/Commands/WalkDown.tscn")
onready var walk_east: PackedScene = preload("res://Engine/Commands/WalkRight.tscn")
onready var walk_west: PackedScene = preload("res://Engine/Commands/WalkLeft.tscn")
onready var do_nothing: PackedScene = preload("res://Engine/Commands/DoNothing.tscn")
onready var score_goal: PackedScene = preload("res://Engine/Commands/ScoreGoal.tscn")
onready var disable_control: PackedScene = preload("res://Engine/Commands/DisableControl.tscn")
onready var enable_control: PackedScene = preload("res://Engine/Commands/EnableControl.tscn")

