class_name SettingsMenu extends BaseMenu

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for video settings.
@onready var fullscreen = $SettingsMenu/SettingsContainer/SettingsSection/VideoSection/Fullscreen/CheckBox

# Variables for audio settings.
@onready var general_volume = $SettingsMenu/SettingsContainer/SettingsSection/AudioSection/GeneralVolume/GeneralVolume
@onready var general_bus = AudioServer.get_bus_index("Master")
@onready var music_volume = $SettingsMenu/SettingsContainer/SettingsSection/AudioSection/MusicVolume/MusicVolume
@onready var music_bus = AudioServer.get_bus_index("BGM")
@onready var sfx_volume = $SettingsMenu/SettingsContainer/SettingsSection/AudioSection/SFXVolume/SFXVolume
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

#---START-SETTINGS-MENU-----------

# Called when the node enters the scene tree for the first time.
func  _ready() -> void:
	var video_settings = settings_manager.load_video_settings()
	var audio_settings = settings_manager.load_audio_settings()
	
	fullscreen.button_pressed = video_settings.fullscreen
	
	general_volume.set_value_no_signal(audio_settings.general)
	music_volume.set_value_no_signal(audio_settings.music)
	sfx_volume.set_value_no_signal(audio_settings.sfx)

#---APPLY-BUTTON------------------

# Apply button funcionality.
func _on_apply_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Save settings.
	settings_manager.save_video_setting("fullscreen", fullscreen.button_pressed)
	settings_manager.save_audio_setting("general",general_volume.value)
	settings_manager.save_audio_setting("music",music_volume.value)
	settings_manager.save_audio_setting("sfx",sfx_volume.value)

#---EXIT-BUTTON-------------------

# Exit button funcionality.
func _on_exit_button_up() -> void:
	# Play button click sound.
	_button_click_soud()
	
	# Return to previous scene.
	game_manager.close_settings_menu()

#---VIDEO-SETTINGS----------------

# Full screen button clicked.
func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#---AUDIO-SETTINGS----------------

# When SFC Volume value has changed.
func _on_general_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(general_bus, linear_to_db(value))

# When SFC Volume value has changed.
func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

# When SFC Volume value has changed.
func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
