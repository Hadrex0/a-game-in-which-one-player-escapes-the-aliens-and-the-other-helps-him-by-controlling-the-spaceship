class_name MainMenu extends BaseMenu

#---CONSTANTS---------------------

#---VARIABLES---------------------

#---START-SETTINGS-MENU-----------

# Called when the node enters the scene tree for the first time.
func  _ready() -> void:
	# Start main menu music.
	audio_manager.play_background("main_menu")

#---HOST-BUTTON-------------------

# Host button funcionality.
func _on_host_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Open host menu.
	game_manager.game_start()

#---JOIN-BUTTON-------------------

# Host button funcionality.
func _on_join_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Open join menu.
	

#---SETTINGS-BUTTON---------------

# Host button funcionality.
func _on_settings_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Open settings menu.
	game_manager.open_settings_menu()

#---QUIT-GAME-BUTTON--------------

# Host button funcionality.
func _on_quit_game_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Quit game.
	get_tree().quit()
