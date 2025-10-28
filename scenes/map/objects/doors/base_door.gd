class_name BaseDoor extends Area2D

#---VARIABLES---------------------

# Variables used for traveling across the rooms.
@export_group("Next Room")
@export var connected_room: int #name of the room behind the door
@export var direction: String #location of the door in the room: N, E, S, or W

# Ready the door stance variable.
@export var open = false #is this door open

# Ready the door animation.
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

#---DOOR-START---------------------

# Prepare the door
func _ready() -> void:
	# Connect changing color with game manager.
	game_manager.color_stance_changed.connect(_on_color_stance_changed)
	
	# Set the correct state of the door from game memory.
	var global_open = self.get_groups()
	global_open.remove_at(global_open.find("Doors"))
	match global_open[0]:
		"Red":
			open = game_manager.red
		"Blue":
			open = game_manager.blue
		"Green":
			open = game_manager.green
		"Yellow":
			open = game_manager.yellow
	
	# Set the correct stance of the door animation.
	if open:
		animation.play("opened")
	else:
		animation.play("closed")

#---CHANGING-COLOR----------------

# Change stance of the door if it matches emited color.
func _on_color_stance_changed(changed_color: String):
	# Change stance of the door with matching color. 
	if is_in_group(changed_color):
		change_door_stance_animation() #play openine/closing animation
		open = !open #change door stance to opposite
	
	# When the doors are just now open, reset monitoring
	if open:
		#monitoring = false
		monitoring = true

# Change door stance animation.
func change_door_stance_animation() -> void:
	# Play correct animation.
	if open:
		animation.play("closing")
	else:
		animation.play("opening")

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
