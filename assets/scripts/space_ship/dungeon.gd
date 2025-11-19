extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Loads user interface
	var ui = load("res://assets/scenes/UI/user_interface.tscn").instantiate()
	add_child(ui)
