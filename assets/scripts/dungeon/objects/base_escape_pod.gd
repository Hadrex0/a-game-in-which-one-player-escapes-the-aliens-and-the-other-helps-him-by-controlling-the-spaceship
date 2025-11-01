class_name BaseEscapePod extends BaseObject

#---CONSTANTS---------------------

#---VARIABLES---------------------

#---ESCAPE-POD-START--------------

# When Player enters opend escape pod, they win.
func _on_body_entered(body: Node2D) -> void:
	# Check if the door is open.
	if open:
		# Check if the Player touched the door.
		if body.is_in_group("Player"): 
			game_manager.game_won()
