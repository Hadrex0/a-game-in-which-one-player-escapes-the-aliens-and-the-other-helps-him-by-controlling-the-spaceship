class_name SettingsMenu extends BaseMenu

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for video settings.
@onready var video: Dictionary = { #video options
	"fullscreen": $SettingsMenu/SettingsContainer/SettingsSection/VideoSection/Fullscreen/CheckBox,
	"resolution": $SettingsMenu/SettingsContainer/SettingsSection/VideoSection/Resolution/OptionButton
	}

# Variables for audio settings.
@onready var audio: Dictionary = { #audio options
	"general_volume": $SettingsMenu/SettingsContainer/SettingsSection/AudioSection/GeneralVolume/GeneralVolume,
	"music_volume": $SettingsMenu/SettingsContainer/SettingsSection/AudioSection/MusicVolume/MusicVolume,
	"sfx_volume": $SettingsMenu/SettingsContainer/SettingsSection/AudioSection/SFXVolume/SFXVolume
	}

#---INITIALIZE-VARIABLES----------

# Initialize resolution option button.
func _resolution_init() -> void:
	# Add all avaliable resolutions to the option button.
	for resolution in settings_manager.resolutions:
		video.resolution.add_item(resolution)
	
	# Update resolution value to resolution of the screen.
	update_resolution_value()

#---START-SETTINGS-MENU-----------

# Called when the node enters the scene tree for the first time.
func  _ready() -> void:
	# Set video settings.
	_resolution_init()
	video.fullscreen.button_pressed = settings_manager.video_settings.fullscreen
	
	# Set audio settings.
	audio.general_volume.set_value_no_signal(settings_manager.audio_settings.general)
	audio.music_volume.set_value_no_signal(settings_manager.audio_settings.music)
	audio.sfx_volume.set_value_no_signal(settings_manager.audio_settings.sfx)

#---APPLY-BUTTON------------------

# Apply button funcionality.
func _on_apply_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Save settings.
	settings_manager.save_settings()
	
	# Load new settings.
	settings_manager.load_settings()

#---EXIT-BUTTON-------------------

# Exit button funcionality.
func _on_exit_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Load last saved settings.
	settings_manager.load_settings()
	
	# Return to previous scene.
	game_manager.close_settings_menu()

#---VIDEO-SETTINGS----------------

# Fullscreen button handler.
func _on_check_box_toggled(fullscreen_on: bool) -> void:
	# Set correct label for option button.
	if fullscreen_on: 
		# Select empty label for resolution
		video.resolution.selected = -1
	else: 
		# Select default resolution.
		var default = settings_manager.default_resolution
		var id = settings_manager.resolutions.keys().find(default)
		video.resolution.selected = id
	
	# Hide/Show option buton.
	video.resolution.disabled = fullscreen_on
	
	# Save button stance to settings the memory.
	settings_manager.video_settings.fullscreen = video.fullscreen.button_pressed

# Upade resolution button.
func update_resolution_value():
	# Get window resolution as string.
	var window_size_string = str(get_window().size.x, "x", get_window().size.y)
	
	# Set option button label to active resolution.
	var resolution_id = settings_manager.resolutions.keys().find(window_size_string)
	video.resolution.selected = resolution_id
	
	# Save button stance to settings the memory.
	settings_manager.video_settings.resolution = video.resolution.selected

#---AUDIO-SETTINGS----------------

# Update general volume dynamically.
func _on_general_volume_value_changed(value: float) -> void:
	# Change master bus volume.
	AudioServer.set_bus_volume_db(settings_manager.bus.general, linear_to_db(value))
	
	# Save general volume to settings the memory.
	settings_manager.audio_settings.general = audio.general_volume.value

# Update music volume dynamically.
func _on_music_volume_value_changed(value: float) -> void:
	# Change music bus volume.
	AudioServer.set_bus_volume_db(settings_manager.bus.music, linear_to_db(value))
	
	# Save music volume to settings the memory.
	settings_manager.audio_settings.music = audio.music_volume.value

# Update sfx volume dynamically.
func _on_sfx_volume_value_changed(value: float) -> void:
	# Change SFX bus volume.
	AudioServer.set_bus_volume_db(settings_manager.bus.sfx, linear_to_db(value))
	
	# Save SFX volume to settings the memory.
	settings_manager.audio_settings.sfx = audio.sfx_volume.value
