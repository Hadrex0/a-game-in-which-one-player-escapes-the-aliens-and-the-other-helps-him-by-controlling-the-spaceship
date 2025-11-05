class_name BaseRoom extends Node2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variable for location of objects.
@onready var _door_location = $DoorMarkers
@onready var _object_location = $ObjectMarkers

#---ADDING-DOOR--------------------

# Add door to room parent node.
func add_door(direction: int, connected_room: int, color_id: int) -> void:
	# Create door scene path.
	var door_path = game_manager.create_object_path("door", color_id)
	
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
	
	# Set correct position of the door.
	door.position = _door_location.get_child(direction).global_position
	door.rotation = PI * direction / 2.0
	
	# Set correct connected room for the door.
	door.connected_room = connected_room

#---ADDING-ESCAPE-POD--------------

# Add escape pod to room parent node.
func add_escape_pod(color_id: int, location_id: int) -> void:
	# Create escape pod scene path.
	var escape_pod_path = game_manager.create_object_path("escape_pod", color_id)
	
	# Select correct escape pod color.
	var escape_pod: BaseEscapePod = load(escape_pod_path).instantiate()
	
	# Add selected escape pod to the room.
	add_child(escape_pod)
	
	# Set correct location of the escape pod.
	escape_pod.position = _object_location.get_child(location_id).global_position

#---ADDING-TERMINAL----------------

# Add terminal to room parent node.
func add_terminal(color_id: int, location_id: int) -> void:
	# Create terminal scene path.
	var terminal_path = game_manager.create_object_path("terminal", color_id)
	
	# Select correct terminal color.
	var terminal: BaseTerminal = load(terminal_path).instantiate()
	
	# Set correct location of the terminal.
	terminal.position = _object_location.get_child(location_id).global_position
	
	# Add selected terminal to the room.
	add_child(terminal)

#---ADDING-ALIEN-------------------

# Add alien to room parent node.
func add_alien(alien_id: int, location: Vector2) -> void:
	# Create alien scene path.
	var alien_path = game_manager.create_entity_path("alien")
	
	# Select correct alien.
	var alien: BaseAlien = load(alien_path).instantiate()
	
	# Set correct id and location of the alien.
	alien.alien_id = alien_id
	alien.position = location
	
	# Add selected alien to the room.
	add_child(alien)
