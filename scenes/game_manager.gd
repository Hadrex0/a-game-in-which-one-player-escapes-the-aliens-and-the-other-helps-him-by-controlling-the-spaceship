extends Node2D

# Variables for Dungeon data
var _dungeon: Dungeon

# Variables for Player 1.
var _player: Player #Player data

# Variables for Player 2.
signal color_stance_changed
var red = false #stance of red color items
var blue = false #stance of red color items
var green = false #stance of red color items
var yellow = false #stance of red color items

# Assign dungeon data.
func dungeon_init(created_dungeon: Dungeon) -> void:
	_dungeon = created_dungeon

# Assign player data.
func player_init(created_player: Player) -> void:
	_player = created_player

# Get player data
func get_player() -> Player:
	return _player

# Update the room in which Player to correct one.
func update_room(direction: String):
	# Set coordinates of new room.
	var nx = _dungeon.current_room.pos.x
	var ny = _dungeon.current_room.pos.y
	match direction:
		"N":
			# If player moved north, decrese y by one.
				ny -= 1
		"E":
			# If player moved east, increase x by one.
				nx += 1
		"S":
			# If player moved south, increase y by one.
				ny += 1
		"W":
			# If player moved west, decrese x by one.
				nx -= 1
	
	# Set current room as the new one, and update screen.
	_dungeon.current_room = _dungeon.dungeon[nx][ny]
	_dungeon.update_room(direction)

# Checking the key that was pressed.
func set_action_for_event(event):
	for action in InputMap.get_actions():
		if event.is_action_pressed(action):
			return action
	return null

# Control room listener.
func _unhandled_input(event: InputEvent) -> void:
	var action = set_action_for_event(event)
	if action != null:
		# Checking which color is pressed.
		match action:
			"cheat_red":
				# Changing color Red and emiting signal for update.
				red = !red
				color_stance_changed.emit("Red")
			"cheat_blue":
				# Changing color Blue and emiting signal for update.
				blue = !blue
				color_stance_changed.emit("Blue")
			"cheat_green":
				# Changing color Green and emiting signal for update.
				green = !green
				color_stance_changed.emit("Green")
			"cheat_yellow":
				# Changing color Yellow and emiting signal for update.
				yellow = !yellow
				color_stance_changed.emit("Yellow")
