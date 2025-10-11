class_name StarShipManager extends Node

# Variable for storing player data.
var player: Player

# Variables for changing the room.
var room_path = "res://scenes/map/rooms/"
var previous_room_path = ""
var previous_room_name: String
var previous_room_direction: String

# Function to change the room from previous_room to next_room. Requires location of the door stored as direction.
func change_room(previous_room, next_room: String, direction: String) -> void:
	# Get information from room that player is exiting.
	previous_room_name = previous_room.name
	previous_room_direction = direction
	
	# Remove player from previous room.
	player = previous_room.player
	player.invisible = true
	player.get_parent().remove_child(player)
	
	# Place player in the next room.
	var next_room_path = room_path + next_room + ".tscn"
	previous_room.get_tree().call_deferred("change_scene_to_file",next_room_path)
