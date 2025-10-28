extends Control


func _on_host_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/map/main/dungeon.tscn")
