class_name BaseRoom extends Node

# Prepare the player variable.
@onready var player: Player = $Player

# Prepare the spawn location for Player.
@onready var entrance_markers: Node2D = $EntranceMarkers

# Spawn player inside the room.
func _ready() -> void:
	# Check if there is a instance of the Player.
	if starship_manager.player:
		# Free the Player data if he exists in room. 
		if player:
			player.queue_free()
		
		# Set Player data in this room.
		player = starship_manager.player
		add_child(player) # add Player to this room.
	
	set_player_pos() # correct the location of the Player in this room.

# Set position of the Player.
func set_player_pos() -> void:
	# Check if this is first room.
	var previous_room = starship_manager.previous_room_name
	if previous_room.is_empty():
		# If this is the first room, set the starting position. 
		starship_manager.previous_room_direction = "StartPosition"
	
	# Find the correct location for player to spawn.
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == starship_manager.previous_room_direction:
			# When encountered correct location spawn the Player.
			player.global_position = entrance.global_position
			
			# Make player ready for game.
			player.start() 
