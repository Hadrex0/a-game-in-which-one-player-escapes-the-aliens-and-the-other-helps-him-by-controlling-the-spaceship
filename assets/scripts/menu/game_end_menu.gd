class_name GameEndMenu extends BaseMenu

#---CONSTANTS---------------------

#---VARIABLES---------------------

@onready var result_label = Label.new()

#---INITIALIZE-VARIABLES----------

# Initialize result label.
func _result_init() -> void:
	# Set paretnt for result label.
	var title_section = $SettingsMenu/SettingsContainer/TitleSection
	
	# Set basic values for result label.
	result_label.label_settings = load("res://assets/fonts/menu_title.tres")
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.text = "YOU " + game_manager.game_result.to_upper() + "!"
	
	# Add result label to the scene.
	title_section.add_child(result_label)

#---START-SETTINGS-MENU-----------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize variables.
	_result_init()

#---RETURN-BUTTON-----------------

# Return button funcionality.
func _on_return_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Open main menu.
	game_manager.open_main_menu()
