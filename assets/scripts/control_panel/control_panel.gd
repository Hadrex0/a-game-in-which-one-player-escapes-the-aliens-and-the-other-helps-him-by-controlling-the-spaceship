extends Node

@export var dungeon_map_string: Label

func _ready():
	game_manager.connect("_send_dungeon_map", Callable(self, "_print_dungeon_map"))

func _print_dungeon_map(dungeon_map: String):
	dungeon_map_string.text = dungeon_map
	print("Przekazano: \n" + dungeon_map)


func _on_red_button_up() -> void:
	game_manager._activate_door("Red")


func _on_blue_button_up() -> void:
	game_manager._activate_door("Blue")


func _on_yellow_button_up() -> void:
	game_manager._activate_door("Yellow")


func _on_green_button_up() -> void:
	game_manager._activate_door("Green")
