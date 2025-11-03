class_name BaseEscapePod extends BaseObject

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for escape pod opening.
@onready var active: bool = false #is the escape pod active

#---SETTERS-----------------------

# Set the active to correct value from game memory.
func _set_active() -> void:
	# Read from the game memory stance of the escape pod.
	active = game_manager.get_dungeon().escape_pod.active
	
	# Change monitoring to matching stance.
	_set_monitoring(active) 

#---OBJECT-START------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the active to correct value from game memory.
	_set_active()
	
	# Set correct stance animation.
	_set_object_stance_animation()

#--USING-ESCAPE-POD---------------

# When Player enters opend escape pod, they win.
func _on_body_entered(body: Node2D) -> void:
	# Check if the door is open.
	if game_manager.get_dungeon().escape_pod.active:
		# Check if the Player touched the door.
		if body.is_in_group("Player"): 
			game_manager.game_won()

#---ANIMATIONS--------------------

# Set the correct stance of the object animation.
func _set_object_stance_animation() -> void:
	# Play correct animation.
	if active:
		animation.play("opened")
	else:
		animation.play("closed")
