class_name StarShipManager extends Node

var player: Player
var previous_room_path = ""
var previous_room_name: String
var previous_room_direction: String
var room_path = "res://scenes/map/rooms/"

#func _ready() -> void:
	

func change_room(previous_room, next_room: String, direction: String) -> void:
	previous_room_name = previous_room.name
	previous_room_direction = direction
	player = previous_room.player
	#player.stop()
	player.invisible = true
	player.get_parent().remove_child(player)
	
	var next_room_path = room_path + next_room + ".tscn"
	previous_room.get_tree().call_deferred("change_scene_to_file",next_room_path)
	#get_tree().change_scene_to_file(next_room_path)
	#get_tree().reload_current_scene()
