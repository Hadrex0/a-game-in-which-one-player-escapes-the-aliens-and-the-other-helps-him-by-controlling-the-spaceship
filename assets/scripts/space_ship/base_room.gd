class_name BaseRoom extends Node2D

#---CONSTANTS---------------------

# Preloaded doors scenes.
var door_scene = [
	load("res://assets/scenes/space_ship/objects/door/red_door.tscn"),
	load("res://assets/scenes/space_ship/objects/door/blue_door.tscn"),
	load("res://assets/scenes/space_ship/objects/door/green_door.tscn"),
	load("res://assets/scenes/space_ship/objects/door/yellow_door.tscn")
	]

# Preloaded excape pod scenes.
var escape_pod_scene = [
	load("res://assets/scenes/space_ship/objects/escape_pod/red_escape_pod.tscn"),
	load("res://assets/scenes/space_ship/objects/escape_pod/blue_escape_pod.tscn"),
	load("res://assets/scenes/space_ship/objects/escape_pod/green_escape_pod.tscn"),
	load("res://assets/scenes/space_ship/objects/escape_pod/yellow_escape_pod.tscn")
	]

# Preloaded terminal scenes.
var terminal_scene = [
	load("res://assets/scenes/space_ship/objects/terminal/red_terminal.tscn"),
	load("res://assets/scenes/space_ship/objects/terminal/blue_terminal.tscn"),
	load("res://assets/scenes/space_ship/objects/terminal/green_terminal.tscn"),
	load("res://assets/scenes/space_ship/objects/terminal/yellow_terminal.tscn")
	]

# Preloaded alien scenes.
var alien_scene = load("res://assets/scenes/space_ship/entity/alien/alien.tscn")

#---VARIABLES---------------------

# Variable for location of objects.
@onready var _door_location = $DoorMarkers
@onready var _object_location = $ObjectMarkers

#---ADDING-DOOR--------------------

# Add door to room parent node.
func add_door(direction: int, connected_room: int, color_id: int) -> void:
	
	# Select correct door color.
	var door: BaseDoor = door_scene[color_id].instantiate()
	
	# Add selected door to the room.
	add_child(door)
	
	# Set correct location of the door.
	match direction:
		0: #the door is located on the north side of the room
			door.direction = "N"
		1: #the door is located on the east side of the room
			door.direction = "E"
		2: #the door is located on the south side of the room
			door.direction = "S"
		3: #the door is located on the west side of the room
			door.direction = "W"
	
	# Set correct position of the door.
	door.position = _door_location.get_child(direction).global_position
	door.rotation = PI * direction / 2.0
	
	# Set correct connected room for the door.
	door.connected_room = connected_room

#---ADDING-ESCAPE-POD--------------

# Add escape pod to room parent node.
func add_escape_pod(color_id: int, location_id: int) -> void:
	# Select correct escape pod color.
	var escape_pod: BaseEscapePod = escape_pod_scene[color_id].instantiate()
	
	# Add selected escape pod to the room.
	add_child(escape_pod)
	
	# Set correct location of the escape pod.
	escape_pod.position = _object_location.get_child(location_id).global_position

#---ADDING-TERMINAL----------------

# Add terminal to room parent node.
func add_terminal(color_id: int, location_id: int) -> void:
	# Select correct terminal color.
	var terminal: BaseTerminal = terminal_scene[color_id].instantiate()
	
	# Set correct location of the terminal.
	terminal.position = _object_location.get_child(location_id).global_position
	
	# Add selected terminal to the room.
	add_child(terminal)

#---ADDING-ALIEN-------------------

# Add alien to room parent node.
func add_alien(alien_id: int, location: Vector2) -> void:
	# Select correct alien.
	var alien: BaseAlien = alien_scene.instantiate()
	
	# Set correct id and location of the alien.
	alien.alien_id = alien_id
	alien.position = location
	
	# Add selected alien to the room.
	add_child(alien)
