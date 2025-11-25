extends Node2D

@export var player: Player
@export var UI: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load UI.
	var ui = load("res://assets/scenes/UI/user_interface.tscn").instantiate()
	add_child(ui)
	
	# Add Player.
	game_manager.player_init(player)
	
	# Start game music.
	audio_manager.play_background("game")
