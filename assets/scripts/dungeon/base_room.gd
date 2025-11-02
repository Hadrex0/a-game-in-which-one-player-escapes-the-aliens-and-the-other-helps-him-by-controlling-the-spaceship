class_name BaseRoom extends Node2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variable for colored doors.
@onready var _door = [
	"res://assets/scenes/map/objects/doors/red_door.tscn",
	"res://assets/scenes/map/objects/doors/blue_door.tscn",
	"res://assets/scenes/map/objects/doors/green_door.tscn",
	"res://assets/scenes/map/objects/doors/yellow_door.tscn"
	]

# Variable for location of the doors.
@onready var _door_location = [
	$DoorMarkers/NorthDoor,
	$DoorMarkers/EastDoor,
	$DoorMarkers/SouthDoor,
	$DoorMarkers/WestDoor
	]

# Variable for colored doors.
@onready var _escape_pod = [
	"res://assets/scenes/map/objects/escape_pod/red_escape_pod.tscn",
	"res://assets/scenes/map/objects/escape_pod/blue_escape_pod.tscn",
	"res://assets/scenes/map/objects/escape_pod/green_escape_pod.tscn",
	"res://assets/scenes/map/objects/escape_pod/yellow_escape_pod.tscn"
	]

@onready var _escape_pod_location = [
	$EscapePodMarkers/EastEscapePod,
	$EscapePodMarkers/WestEscapePod
	]

@onready var _alien_location = [
	$AlienMarkers/AlienSpot1,
	$AlienMarkers/AlienSpot2,
	$AlienMarkers/AlienSpot3,
	$AlienMarkers/AlienSpot4,
	$AlienMarkers/AlienSpot5,
	$AlienMarkers/AlienSpot6
	]

#---GETTERS-----------------------

func get_alien_location_count() -> int:
	return 6

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
func add_escape_pod(color_id: int) -> void:
	# Select correct escape_pod color.
	var escape_pod: BaseEscapePod = load(_escape_pod[color_id]).instantiate()
	
	# Add selected escape_pod to the room.
	add_child(escape_pod)
	
	# Set correct location of the escape_pod.
	escape_pod.position =_escape_pod_location[randi_range(0, 1)].global_position

#---ADDING-ALIEN-------------------
func add_alien(alien_id: int, location_id: int) -> void:
	# Select correct alien.
	var alien: BaseAlien = load("res://assets/scenes/entity/alien/alien.tscn").instantiate()
	
	# Set correct id and location of the alien.
	alien.alien_id = alien_id
	alien.position = _alien_location[location_id].global_position
	
	# Add selected alien to the room.
	add_child(alien)
	
	
