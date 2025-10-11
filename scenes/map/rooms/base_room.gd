class_name BaseRoom extends Node

@onready var player: Player = $Player
@onready var entrance_markers: Node2D = $EntranceMarkers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if starship_manager.player:
		if player:
			player.queue_free()
		
		player = starship_manager.player
		add_child(player)
	set_player_pos()

func set_player_pos() -> void:
	var previous_room = starship_manager.previous_room_name
	
	if previous_room.is_empty():
		starship_manager.previous_room_direction = "StartPosition"
	
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == starship_manager.previous_room_direction:
			player.global_position = entrance.global_position
			#OS.delay_msec(100)
			player.start()
