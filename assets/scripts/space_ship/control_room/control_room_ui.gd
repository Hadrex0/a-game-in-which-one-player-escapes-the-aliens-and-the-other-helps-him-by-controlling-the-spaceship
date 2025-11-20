extends Control

@export var dungeon_map_string: Label
@export var detected_rooms: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.connect("_send_dungeon_map", Callable(self, "_print_dungeon_map"))
	game_manager.connect("_receive_detected_rooms", Callable(self, "_print_detected_rooms"))

func _print_detected_rooms() -> void:
	detected_rooms.text = game_manager.detected_life_forms

func _print_dungeon_map(dungeon_map: String):
	dungeon_map_string.text = dungeon_map
	print("Przekazano: \n" + dungeon_map)
