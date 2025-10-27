class_name BaseDoor extends Area2D

# Variables used for traveling across the rooms.
@export_group("Next Room")
@export var connected_room: String #name of the room behind the door
@export var direction: String #location of the door in the room: N, E, S, or W

# Ready the door stance variable.
@export var open = false #is this door open

# Ready the door animation.
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

# Prepare the door
func _ready() -> void:
	# Connect changing color with game manager.
	game_manager.color_stance_changed.connect(_on_color_stance_changed)
	
	# Set the correct stance of the door.
	if open:
		animation.play("opened")
	else:
		animation.play("closed")

# Change door stance animation.
func change_door_stance_animation() -> void:
	# Play correct animation.
	if open:
		animation.play("closing")
	else:
		animation.play("opening")

# Change stance of the door if it matches emited color.
func _on_color_stance_changed(changed_color: String):
	# Change stance of the door with matching color. 
	if is_in_group(changed_color):
		change_door_stance_animation() #play openine/closing animation
		open = !open #change door stance to opposite

# When something touches the door.
func _on_body_entered(body: Node2D) -> void:
	# Check if the door is open.
	if open == true: 
		# Check if the Player touched the door.
		if body.is_in_group("Player"): 
			# Changing room to the connected one.
			pass
