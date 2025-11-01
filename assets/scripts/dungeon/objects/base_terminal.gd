class_name BaseTerminal extends BaseObject

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for terminal activation.
@onready var active: bool = false

#---SETTERS-----------------------

# Set the correct state of the object from game memory.
func _set_active() -> void:
	var terminal
	for i in game_manager.COLORS.size():
		var room_id = game_manager.get_dungeon().current_room.id
		if room_id == game_manager.get_dungeon().terminals[i].room_id:
			terminal = game_manager.get_dungeon().terminals[i]
			break
	active = terminal.active
	
	# Set the correct state of the object from game memory.
	_set_open_to_color(terminal.color_id)

#---OBJECT-START------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect changing color signal from game manager to the function.
	game_manager.color_stance_changed.connect(_on_color_stance_changed)
	
	# Connect color activation signal from game manager to the function.
	game_manager.color_activation_changed.connect(_on_color_activation_changed)
	
	# Set the active to correct value from game memory.
	_set_active()
	
	# Set correct stance animation.
	_set_object_stance_animation()

#---CHANGING-COLOR----------------

# Change stance of the object if it matches emited color.
func _on_color_stance_changed(changed_color: String):
	# Change stance of the object with matching color only if not activated. 
	if !active:
		super(changed_color)

#---ACTIVATING-COLOR--------------

# Activate the object if it matches emited color.
func _on_color_activation_changed(activated_color: String) -> void:
	# Activate the object with matching color. 
	if (is_in_group(activated_color) and !active):
		_activation_animation() #play activation animation
		active = true

#---USING-TERMINAL----------------

# When something touches the terminal.
func _on_body_entered(body: Node2D) -> void:
	# Check if the Player touched the door.
	if body.is_in_group("Player"): 
		# When the terminal is not active, highlight it.
		if !active:
			_highlight_animation(true)
		
		# Set touched object to terminal.
		body.touched_object = "Terminal"

# When something stops touching the terminal.
func _on_body_exited(body: Node2D) -> void:
	# Check if the Player touched the door.
	if body.is_in_group("Player"): 
		# When the terminal is not active, unhighlight it.
		if !active:
			_highlight_animation(false)
		
		# Set touched object to empty.
		body.touched_object = ""

#---ANIMATIONS--------------------

# Set the correct stance of the object animation.
func _set_object_stance_animation() -> void:
	if active:
		animation.play("activated")
	elif open:
		animation.play("opened")
	else:
		animation.play("closed")

# Highlight animation.
func _highlight_animation(highlight: bool) -> void:
	if highlight:
		animation.play("highlighted")
	elif open:
		animation.play("opened")
	else:
		animation.play("closed")

# Activation animation.
func _activation_animation() -> void:
	animation.play("activation")
