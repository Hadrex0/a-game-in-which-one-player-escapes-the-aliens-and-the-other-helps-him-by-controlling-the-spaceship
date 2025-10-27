extends Node2D

@export var _red_door: PackedScene
@onready var _east_door : Node2D = $DoorMarkers/EastDoor
@onready var _north_door : Node2D = $DoorMarkers/NorthDoor
@onready var _west_door : Node2D = $DoorMarkers/WestDoor
@onready var _south_door : Node2D = $DoorMarkers/SouthDoor

func add_door(direction: int) -> void:
	var door: BaseDoor = _red_door.instantiate()
	add_child(door)
	match direction:
		1:
			door.position =_east_door.global_position
		2:
			door.position =_north_door.global_position
		4:
			door.position =_west_door.global_position
		8:
			door.position =_south_door.global_position
	door.rotation = PI * direction / 2.0
