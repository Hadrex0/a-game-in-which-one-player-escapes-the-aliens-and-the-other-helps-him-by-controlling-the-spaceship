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

var door_sfx : Node
var enter_sfx : Node

# Variables for Dungeon data
var _dungeon: Dungeon

# Variables for Player 1.
var _player: Player #Player data

# Variables for Player 2.
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
			"interaction":
				_interaction()

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
	
	# Play the entering sound.
	enter_sfx.play()
	
	# Set current room as the new one, and update screen.
	_dungeon.current_room = _dungeon.dungeon[nx][ny]
	_dungeon.update_room(direction)

#---GAME-ENDS---------------------

# What happens when Player wins.
func game_won() -> void:
	print("YOU WON!")
	get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/menu/main_menu.tscn")

# What happens when Player looses.
func game_lost() -> void:
	print("YOU LOST!")
	get_tree().change_scene_to_file("res://assets/scenes/menu/main_menu.tscn")
