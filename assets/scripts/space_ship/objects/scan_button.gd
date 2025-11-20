class_name ScanButton extends BaseColorButton

#---CONSTANTS---------------------

#---VARIABLES---------------------

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

#---CHANGING-COLOR----------------

# Change stance of the object if it matches emited color.
func _on_button_pressed(changed_color: String):
	var matching_group = is_in_group(changed_color)
	
	# Open object with matching color, and close otherwise. 
	if matching_group:
		open = true
		
		# Start cooldown timer
		$CooldownTimer.start()
		
		# Show scanned rooms. 
		game_manager.show_entities(true)
		
		# Play opening/closing animation.
		_change_object_stance_animation(open)

func _on_cooldown_timer_timeout() -> void:
	open = false
	
	# Hide scanned rooms. 
	game_manager.show_entities(false)
	
	# Play opening/closing animation.
	_change_object_stance_animation(open) 
