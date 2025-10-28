extends Node2D

#---VARIABLES---------------------

# Variable for colored doors.
@onready var _door = [
	"res://scenes/map/objects/doors/red_door.tscn",
	"res://scenes/map/objects/doors/blue_door.tscn",
	"res://scenes/map/objects/doors/green_door.tscn",
	"res://scenes/map/objects/doors/yellow_door.tscn"
]

# Variable for location of the doors.
@onready var _east_door : Node2D = $DoorMarkers/EastDoor
@onready var _north_door : Node2D = $DoorMarkers/NorthDoor
@onready var _west_door : Node2D = $DoorMarkers/WestDoor
@onready var _south_door : Node2D = $DoorMarkers/SouthDoor

#---ADDING-DOOR--------------------

# Add door to room parent node.
func add_door(direction: int, connected_room: int, color_id: int) -> void:
	# Select correct door color.
	var door: BaseDoor = load(_door[color_id]).instantiate()
	
	# Add selected door to the room.
	add_child(door)
	
	# Set correct location of the door.
	match direction:
		0: #the door are located on the north side of the room
			door.position =_north_door.global_position
			door.direction = "N"
			
		1: #the door are located on the east side of the room
			door.position =_east_door.global_position
			door.direction = "E"
			
		2: #the door are located on the south side of the room
			door.position =_south_door.global_position
			door.direction = "S"
			
		3: #the door are located on the west side of the room
			door.position =_west_door.global_position
			door.direction = "W"
			
	# Set correct orientation and connection to the door.
	door.rotation = PI * direction / 2.0
	door.connected_room = connected_room
