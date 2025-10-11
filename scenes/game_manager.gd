class_name GameManager extends Node

# Variables for Player 1.
var player: Player #Player data

# Variables for Player 2.
signal color_stance_changed
var red = false #stance of red color items
var blue = false #stance of red color items
var green = false #stance of red color items
var yellow = false #stance of red color items

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
	player.get_parent().remove_child(player)
	
	# Place player in the next room.
	var next_room_path = room_path + next_room + ".tscn"
	previous_room.get_tree().call_deferred("change_scene_to_file",next_room_path)

# Checking the key that was pressed.
func set_action_for_event(event):
	for action in InputMap.get_actions():
		if event.is_action_pressed(action):
			return action
	return null

# Control room listener
func _unhandled_input(event: InputEvent) -> void:
	var action = set_action_for_event(event)
	if action != null:
		match action:
			"cheat_red":
				red = !red
				color_stance_changed.emit("Red")
			"cheat_blue":
				blue = !blue
				color_stance_changed.emit("Blue")
			"cheat_green":
				green = !green
				color_stance_changed.emit("Green")
			"cheat_yellow":
				yellow = !yellow
				color_stance_changed.emit("Yellow")
