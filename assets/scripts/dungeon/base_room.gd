extends Node2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variable for colored objects.
@onready var _door = [
	"res://assets/scenes/map/objects/doors/red_door.tscn",
	"res://assets/scenes/map/objects/doors/blue_door.tscn",
	"res://assets/scenes/map/objects/doors/green_door.tscn",
	"res://assets/scenes/map/objects/doors/yellow_door.tscn"
	]
@onready var _escape_pod = [
	"res://assets/scenes/map/objects/escape_pod/red_escape_pod.tscn",
	"res://assets/scenes/map/objects/escape_pod/blue_escape_pod.tscn",
	"res://assets/scenes/map/objects/escape_pod/green_escape_pod.tscn",
	"res://assets/scenes/map/objects/escape_pod/yellow_escape_pod.tscn"
	]
@onready var _terminal = [
	"res://assets/scenes/map/objects/terminal/red_terminal.tscn",
	"res://assets/scenes/map/objects/terminal/blue_terminal.tscn",
	"res://assets/scenes/map/objects/terminal/green_terminal.tscn",
	"res://assets/scenes/map/objects/terminal/yellow_terminal.tscn"
	]

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

#---ADDING-DOOR--------------------

# Add door to room parent node.
func add_door(direction: int, connected_room: int, color_id: int) -> void:
	# Select correct door color.
	var door: BaseDoor = load(_door[color_id]).instantiate()
	
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
func add_escape_pod(color_id: int, location_id: int) -> void:
	# Select correct escape pod color.
	var escape_pod: BaseEscapePod = load(_escape_pod[color_id]).instantiate()
	
	# Add selected escape pod to the room.
	add_child(escape_pod)
	
	# Set correct location of the escape pod.
	escape_pod.position =_object_location[location_id].global_position

#---ADDING-TERMINAL----------------
func add_terminal(color_id: int, location_id: int) -> void:
	# Select correct terminal color.
	var terminal: BaseTerminal = load(_terminal[color_id]).instantiate()
	
	# Add selected terminal to the room.
	add_child(terminal)
	
	# Set correct location of the terminal.
	terminal.position =_object_location[location_id].global_position
