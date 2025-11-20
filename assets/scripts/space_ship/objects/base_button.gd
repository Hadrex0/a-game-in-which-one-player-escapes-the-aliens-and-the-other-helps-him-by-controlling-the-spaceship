class_name BaseColorButton extends BaseObject

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variable for storing the button color.
@export var color: String

#---SETTERS-----------------------

# Set the correct state of the object from game memory.
func _set_open() -> void:
	# Get groups of the object.
	var groups = self.get_groups()
	
	# Initiate color id variable.
	var color_id = -1
	
	# Set color id to the id of the object color.
	for i in game_manager.COLORS.size():
		if groups.find(game_manager.COLORS[i]) != -1:
			color_id = i
	
	# Set color of the button.
	if color_id == -1:
		color = "Gray"
	else:
		color = game_manager.COLORS[color_id]
	
	# Get stance from the game memory based on color of the object.
	_set_open_to_color(color_id)

#---OBJECT-START------------------

# Called when the object enters the scene tree for the first time.
func _ready() -> void:
	# Connect changing color signal from game manager to the function.
	game_manager.pressed_button.connect(_on_button_pressed)
	
	# Set the correct state of the object from game memory.
	_set_open()
	
	# Set the correct stance of the object animation.
	_set_object_stance_animation()
	
	# Set monitoring to correct true.
	_set_monitoring(true)

#---USING-BUTTON------------------

# When something touches the button.
func _on_body_entered(body: Node2D) -> void:
	# Check if the Player touched the button.
	if body.is_in_group("Player"): 
		# When the button is not pressed, highlight it.
		if !open:
			_highlight_animation(true)
		
		# Set touched object to button.
		body.touched_object = "Button"
		game_manager.active_button_color = color

# When something stops touching the button.
func _on_body_exited(body: Node2D) -> void:
	# Check if the Player touched the door.
	if body.is_in_group("Player"): 
		# When the button is not pressed, unhighlight it.
		if !open:
			_highlight_animation(false)
		
		# Set touched object to empty.
		body.touched_object = ""

#---CHANGING-COLOR----------------

# Change stance of the object if it matches emited color.
func _on_button_pressed(changed_color: String):
	var matching_group = is_in_group(changed_color)
	
	# When scan button is pressed do not change active color.
	if changed_color == "Gray":
		return
	
	# Open object with matching color, and close otherwise. 
	if matching_group == !open:
		open = matching_group
		
		# Play opening/closing animation.
		_change_object_stance_animation(open) 

#---ANIMATIONS--------------------

# Set the correct stance of the button animation.
func _highlight_animation(stance: bool) -> void:
	# Play correct animation.
	if stance:
		animation.play("highlighted")
	else:
		animation.play("closed")
