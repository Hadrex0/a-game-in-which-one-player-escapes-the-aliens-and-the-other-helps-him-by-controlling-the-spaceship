class_name SettingsMenu extends BaseMenu

#---CONSTANTS---------------------

#---VARIABLES---------------------

#---START-SETTINGS-MENU-----------

# Called when the node enters the scene tree for the first time.
func  _ready() -> void:
	pass

#---APPLY-BUTTON------------------

# Apply button funcionality.
func _on_apply_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Save settings.
	

#---EXIT-BUTTON-------------------

# Exit button funcionality.
func _on_exit_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Return to previous scene.
	game_manager.close_settings_menu()
