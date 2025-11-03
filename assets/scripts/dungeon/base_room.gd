class_name BaseRoom extends Node2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for path creation.
@onready var object_path = "res://assets/scenes/map/objects/"
@onready var extension = ".tscn"

# Variable for location of objects.
@onready var _door_location = [
	$DoorMarkers/NorthDoor,
	$DoorMarkers/EastDoor,
	$DoorMarkers/SouthDoor,
	$DoorMarkers/WestDoor
	]
@onready var _object_location = [
	$ObjectMarkers/EastObject,
	$ObjectMarkers/WestObject
	]

#---FILE-PATH-CREATION-------------

func _create_path(object: String, color_id: int) -> String:
	return object_path + object + "/" + game_manager.COLORS[color_id] + "_" + object + extension

#---ADDING-DOOR--------------------

# Add door to room parent node.
func add_door(direction: int, connected_room: int, color_id: int) -> void:
	# Create door path.
	var door_path = _create_path("door", color_id)
	
	# Select correct door color.
	var door: BaseDoor = load(door_path).instantiate()
	
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
			
	# Set correct orientation and connection to the door.
	door.position =_door_location[direction].global_position
	door.rotation = PI * direction / 2.0
	door.connected_room = connected_room

#---ADDING-ESCAPE-POD--------------

# Add escape pod to room parent node.
func add_escape_pod(color_id: int, location_id: int) -> void:
	# Create escape pod path.
	var escape_pod_path = _create_path("escape_pod", color_id)
	
	# Select correct escape pod color.
	var escape_pod: BaseEscapePod = load(escape_pod_path).instantiate()
	
	# Add selected escape pod to the room.
	add_child(escape_pod)
	
	# Set correct location of the escape pod.
	escape_pod.position =_object_location[location_id].global_position

#---ADDING-TERMINAL----------------

# Add terminal to room parent node.
func add_terminal(color_id: int, location_id: int) -> void:
	# Create terminal path.
	var terminal_path = _create_path("terminal", color_id)
	
	# Select correct terminal color.
	var terminal: BaseTerminal = load(terminal_path).instantiate()
	
	# Add selected terminal to the room.
	add_child(terminal)

#---ADDING-ALIEN-------------------

# Add alien to room parent node.
func add_alien(alien_id: int, location: Vector2) -> void:
	# Select correct alien.
	var alien: BaseAlien = load("res://assets/scenes/entity/alien/alien.tscn").instantiate()
	
	# Set correct id and location of the alien.
	alien.alien_id = alien_id
	alien.position = location
	
	# Add selected alien to the room.
	add_child(alien)
	
	
	# Set correct location of the terminal.
	terminal.position =_object_location[location_id].global_position
