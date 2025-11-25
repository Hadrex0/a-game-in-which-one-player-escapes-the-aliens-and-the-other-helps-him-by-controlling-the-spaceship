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
	# Check if the Player touched the door.
	if body.is_in_group("Player"): 
		if _activate_body_timers(body):
			# Changing room to the connected one.
			game_manager.update_room(direction)
	
	# Check if the alien touched the door.
	elif body.is_in_group("Alien"):
		if _activate_body_timers(body):
			# Move alien to the next room.
			game_manager.move_alien(body.alien_id, direction)

# Activate body timers when it can be detected.
func _activate_body_timers(body: Node2D) -> bool:
	# When body have invincibility frame active return false.
	if !body.door_touch:
		return false
	
	# Start invincibility timers.
	body.door_timer_start()
	body.entity_timer_start()
	
	# When timer have been activated return true  
	return true
