class_name BaseObject extends Area2D

#---CONSTANTS---------------------

# Object colors.
const colors = [
	"Red",
	"Blue",
	"Green",
	"Yellow"
	]

#---VARIABLES---------------------

# Ready the object stance variable.
@onready var open = false #is this object open

# Ready the object animation.
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

#---OBJECT-START------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect changing color with game manager.
	game_manager.color_stance_changed.connect(_on_color_stance_changed)
	
	# Set the correct state of the object from game memory.
	var global_open = self.get_groups()
	var color_id = -1
	
	for i in colors.size():
		if global_open.find(colors[i]) != -1:
			color_id = i
	
	match colors[color_id]:
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
	
	# Set the correct stance of the object animation.
	set_door_stance_animation()

#---CHANGING-COLOR----------------

# Change stance of the object if it matches emited color.
func _on_color_stance_changed(changed_color: String):
	# Change stance of the object with matching color. 
	if is_in_group(changed_color):
		change_door_stance_animation() #play openine/closing animation
		open = !open #change object stance to opposite
		self.set_deferred("monitoring", open) #change monitoring to matching stance

#---ANIMATIONS--------------------
# Set the correct stance of the object animation.
func set_door_stance_animation() -> void:
	if open:
		animation.play("opened")
	else:
		animation.play("closed")

# Change object stance animation.
func change_door_stance_animation() -> void:
	# Play correct animation.
	if open:
		animation.play("closing")
	else:
		animation.play("opening")
