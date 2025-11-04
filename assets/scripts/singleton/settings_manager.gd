extends Node

var config = ConfigFile.new()
 
var video_setting
var audio_setting

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var music_bus = AudioServer.get_bus_index("BGM")

const SETTINGS_FILE_PATH = "res://options.ini"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("video", "fullscreen", false)
		config.set_value("audio", "general", 1.0)
		config.set_value("audio", "music", 1.0)
		config.set_value("audio", "sfx", 1.0)
		
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	
	video_setting = load_video_settings()
	video_loader()
	
	audio_setting = load_audio_settings()
	audio_loader()

func video_loader():
	if video_setting.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func audio_loader():
	AudioServer.set_bus_volume_db(master_bus,linear_to_db(audio_setting.general))
	AudioServer.set_bus_volume_db(music_bus,linear_to_db(audio_setting.music))
	AudioServer.set_bus_volume_db(sfx_bus,linear_to_db(audio_setting.sfx))
	

func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func save_audio_setting(key: String, value: float):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings
