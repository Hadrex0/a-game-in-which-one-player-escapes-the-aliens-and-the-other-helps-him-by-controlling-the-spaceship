extends Area2D

# Variables used for traveling across the rooms.
@export_group("Next Room")
@export var connected_room: String #name of the room behind the door
@export var direction: String #location of the door in the room: N, E, S, or W

# When something touches the door.
func _on_body_entered(body: Node2D) -> void:
	# Check if the Player touched the door.
	if body.is_in_group("Player"): 
		if body.invisible == false: #check if player can use doors
			# Changing room for the connected one.
			starship_manager.change_room(get_owner(), connected_room, direction)
		else:
			body.invisible = false #change player ability to use doors
