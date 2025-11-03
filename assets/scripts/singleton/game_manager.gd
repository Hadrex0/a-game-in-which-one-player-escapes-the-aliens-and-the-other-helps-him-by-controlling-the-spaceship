extends Node2D

#---CONSTANTS---------------------

# Colors of objects in game.
const COLORS: Array = [
	"Red",
	"Blue",
	"Green",
	"Yellow"
	]

#---SIGNALS-----------------------

# Signal to open/close objects on the screen.
signal color_stance_changed

# Signal to activate objects on the screen.
signal color_activation_changed

#---VARIABLES---------------------

# Sounds variables. 
var door_sfx : Node
var room_change_sfx : Node

# Variables for Dungeon data.
var _dungeon: Dungeon

# Variables for Player 1.
var _player: Player #Player data

# Variables for Player 2.
var active_color_id: int = 0 #currently active objects color

#---INITIALIZE-VARIABLES----------

# Assign dungeon data.
func dungeon_init(created_dungeon: Dungeon) -> void:
	_dungeon = created_dungeon

# Assign player data.
func player_init(created_player: Player) -> void:
	_player = created_player
	
func sound_init() -> void:
	door_sfx = get_tree().get_root().get_node("/root/Dungeon/Sounds/DoorSFX")
	room_change_sfx = get_tree().get_root().get_node("/root/Dungeon/Sounds/RoomChangeSFX")

#---GETTERS-----------------------

# Get player data
func get_player() -> Player:
	return _player

# Get dungeon data
func get_dungeon() -> Dungeon:
	return _dungeon

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
			"interaction": #pressed interaction key
				_interaction()
			"activate_red": #change active color to red
				_activate_color(COLORS.find("Red"))
			"activate_blue": #change active color to blue
				_activate_color(COLORS.find("Blue"))
			"activate_green": #change active color to green
				_activate_color(COLORS.find("Green"))
			"activate_yellow": #change active color to yellow
				_activate_color(COLORS.find("Yellow"))

# Player 1 interaction.
func _interaction() -> void:
	match _player.touched_object:
		"Terminal": # Player is interacting with a terminal.
			# Find the color the interacted terminal.
			for i in COLORS.size():
				if _dungeon.terminals[i].room_id == _dungeon.current_room.id:
					# Get terminal color id.
					var color_id = _dungeon.terminals[i].color_id
					
					# Active escape pod if it matches the color.
					if color_id == _dungeon.escape_pod.color_id:
						_dungeon.escape_pod.active = true
					
					# Active the terminal.
					_dungeon.terminals[i].active = true
					color_activation_changed.emit(COLORS[color_id])

# Player 2 interaction.
func _activate_color(color_id: int) -> void:
	# Play sound if the doors in the current room are changing.
	var previous_color_id = active_color_id
	var door_colors = _dungeon.current_room.door_color
	if color_id != previous_color_id:
		if (door_colors.has(color_id) or door_colors.has(previous_color_id)):
			_door_sound()
	
	# Change active color.
	active_color_id = color_id
	color_stance_changed.emit(COLORS[color_id])

#---AUDIO-HANDLER-----------------

# Play the door opening/closing sound.
func _door_sound() -> void:
	door_sfx.play()

# Play the room changing sound.
func _room_change_sound() -> void:
	room_change_sfx.play()

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
	
	# Play the room changing sound.
	_room_change_sound()
	
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
	get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/menu/main_menu.tscn")

# What happens when Player looses.
func game_lost() -> void:
	print("YOU LOST!")
	get_tree().change_scene_to_file("res://assets/scenes/menu/main_menu.tscn")
