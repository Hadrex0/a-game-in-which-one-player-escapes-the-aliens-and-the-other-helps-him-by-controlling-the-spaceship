extends Node2D

#---CONSTANTS---------------------



#---VARIABLES---------------------

var door_sfx : Node
var enter_sfx : Node

# Variables for Dungeon data
var _dungeon: Dungeon

# Variables for Player 1.
var _player: Player #Player data

# Variables for Player 2.
signal color_stance_changed
var red = false #stance of red color items
var blue = false #stance of blue color items
var green = false #stance of green color items
var yellow = false #stance of yellow color items

#---INITIALIZE-VARIABLES----------

# Assign dungeon data.
func dungeon_init(created_dungeon: Dungeon) -> void:
	_dungeon = created_dungeon

# Assign player data.
func player_init(created_player: Player) -> void:
	_player = created_player
	door_sfx = get_tree().get_root().get_node("/root/Dungeon/Door SFX")
	enter_sfx = get_tree().get_root().get_node("/root/Dungeon/Enter SFX")

#---GETTERS-----------------------

# Get player data
func get_player() -> Player:
	return _player

#---INPUT-HANDLER-----------------

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
				door_sfx.play()
				if blue:
					blue = !blue
					color_stance_changed.emit("Blue")
				if green:
					green = !green
					color_stance_changed.emit("Green")
				if yellow:
					yellow = !yellow
					color_stance_changed.emit("Yellow")
				red = !red
				color_stance_changed.emit("Red")
				print("RED DOORS ARE OPEN")
			"cheat_blue":
				# Changing color Blue and emiting signal for update.
				door_sfx.play()
				if red:
					red = !red
					color_stance_changed.emit("Red")
				if green:
					green = !green
					color_stance_changed.emit("Green")
				if yellow:
					yellow = !yellow
					color_stance_changed.emit("Yellow")
				blue = !blue
				color_stance_changed.emit("Blue")
				print("BLUE DOORS ARE OPEN")
			"cheat_green":
				# Changing color Green and emiting signal for update.
				door_sfx.play()
				if red:
					red = !red
					color_stance_changed.emit("Red")
				if blue:
					blue = !blue
					color_stance_changed.emit("Blue")
				if yellow:
					yellow = !yellow
					color_stance_changed.emit("Yellow")
				green = !green
				color_stance_changed.emit("Green")
				print("GREEN DOORS ARE OPEN")
			"cheat_yellow":
				# Changing color Yellow and emiting signal for update.
				door_sfx.play()
				if red:
					red = !red
					color_stance_changed.emit("Red")
				if blue:
					blue = !blue
					color_stance_changed.emit("Blue")
				if green:
					green = !green
					color_stance_changed.emit("Green")
				yellow = !yellow
				color_stance_changed.emit("Yellow")
				print("YELLOW DOORS ARE OPEN")

#---CHANGING-CURRENT-ROOM---------

# Update the room in which Player to correct one.
func update_room(direction: String):
	# Set coordinates of new room.
	var nx = _dungeon.current_room.pos.x
	var ny = _dungeon.current_room.pos.y
	match direction:
		"N": #if player moved north, decrese y by one
				ny -= 1
		"E": #if player moved east, increase x by one
			
				nx += 1
		"S": #if player moved south, increase y by one
			
				ny += 1
		"W": #if player moved west, decrese x by one
			
				nx -= 1
	enter_sfx.play()
	# Set current room as the new one, and update screen.
	_dungeon.current_room = _dungeon.dungeon[nx][ny]
	_dungeon.update_room(direction)

#---CHANGING-CURRENT-ROOM---------

# Move alien to another room.
func move_alien(alien_id: int, direction: String) -> void:
	# Set coordinates of new room.
	var nx = _dungeon.current_room.pos.x
	var ny = _dungeon.current_room.pos.y
	match direction:
		"N": #if alien moved north, decrese y by one
				ny -= 1
		"E": #if alien moved east, increase x by one
				nx += 1
		"S": #if alien moved south, increase y by one
				ny += 1
		"W": #if alien moved west, decrese x by one
				nx -= 1
	
	# Set alien room as the new one, and update screen.
	_dungeon.aliens[alien_id].room_id = _dungeon.dungeon[nx][ny].id
	_dungeon.remove_alien_from_display(alien_id)

#---GAME-ENDS---------------------

# What happens when Player wins.
func game_won() -> void:
	print("YOU WON!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
	#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# What happens when Player looses.
func game_lost() -> void:
	print("YOU LOST!")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
