class_name BaseDoor extends BaseObject

#---CONSTANTS---------------------



#---VARIABLES---------------------

# Variables used for traveling across the rooms.
@export_group("Next Room")
@export var connected_room: int #name of the room behind the door
@export var direction: String #location of the door in the room: N, E, S, or W

#---USING-DOORS-------------------

# When something touches the door.
func _on_body_entered(body: Node2D) -> void:
	# Check if the door is open.
	if open:
		# Check if the Player touched the door.
		if body.is_in_group("Player"): 
			if !game_manager.get_player().invisible:
				game_manager.get_player().invisibility_start()
				# Changing room to the connected one.
				game_manager.update_room(direction)
		elif body.is_in_group("Alien"):
			game_manager.move_alien(body.alien_id, direction)
			
