class_name BaseObject extends Area2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Ready the object stance variable.
@onready var open = false #is this object open

# Ready the object animation.
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

#---SETTERS-----------------------

# Set the correct state of the object from game memory.
func _set_open() -> void:
	var groups = self.get_groups()
	var color_id = -1
	
	# Set the correct color id.
	for i in game_manager.COLORS.size():
		if groups.find(game_manager.COLORS[i]) != -1:
			color_id = i
	
	# Get stance from the game memory based on color of the object.
	_set_open_to_color(color_id)

# Set open to matching color from game memory.
func _set_open_to_color(color_id: int) -> void:
	match game_manager.COLORS[color_id]:
		"Red":
			open = game_manager.red
		"Blue":
			open = game_manager.blue
		"Green":
			open = game_manager.green
		"Yellow":
			open = game_manager.yellow
	
	# Change monitoring to matching stance.
	self.set_deferred("monitoring", open)

#---OBJECT-START------------------

# Called when the object enters the scene tree for the first time.
func _ready() -> void:
	# Connect changing color signal from game manager to the function.
	game_manager.color_stance_changed.connect(_on_color_stance_changed)
	
	# Set the correct state of the object from game memory.
	_set_open()
	
	# Set the correct stance of the object animation.
	_set_object_stance_animation()

#---CHANGING-COLOR----------------

# Change stance of the object if it matches emited color.
func _on_color_stance_changed(changed_color: String):
	# Change stance of the object with matching color. 
	if is_in_group(changed_color):
		open = !open #change object stance to opposite
		_change_object_stance_animation(open) #play opening/closing animation
		self.set_deferred("monitoring", open) #change monitoring to matching stance

#---ANIMATIONS--------------------

# Set the correct stance of the object animation.
func _set_object_stance_animation() -> void:
	if open:
		animation.play("opened")
	else:
		animation.play("closed")

# Change object stance animation.
func _change_object_stance_animation(change_to: bool) -> void:
	# Play correct animation.
	if change_to:
		animation.play("opening")
	else:
		animation.play("closing")
