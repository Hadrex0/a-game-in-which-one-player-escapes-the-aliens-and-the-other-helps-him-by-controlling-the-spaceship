extends Node

#---CONSTANTS---------------------

# Path for settings file.
const SETTINGS_FILE_PATH = "user://settings.ini"

#---VARIABLES---------------------

# Variable for settings file.
@onready var config = ConfigFile.new()
 
# Variables for video settings.
@onready var video_settings: Dictionary = { #video settings in memory
	"fullscreen": false,
	"resolution": "1280x720"
	} 
@onready var default_resolution: String = "1280x720" #default resolution value.
@onready var resolutions: Dictionary = { #avaliable resolutions.
	"1024x600": Vector2i(1024,600),
	"1280x720": Vector2i(1280,720),
	"1366x768": Vector2i(1366,768),
	"1600x900": Vector2i(1600,900),
	"1920x1080": Vector2i(1920,1080)
	}

# Variables for audio settings.
@onready var audio_settings: Dictionary = { #audio settings in memory
	"general": 1.0,
	"music": 1.0,
	"sfx": 1.0
	}
@onready var bus: Dictionary = { #audio bus ids
	"general": AudioServer.get_bus_index("Master"),
	"music": AudioServer.get_bus_index("BGM"),
	"sfx": AudioServer.get_bus_index("SFX")
	}

#---READY-SETTINGS-MANAGER--------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load settings file.
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		# Create settings file.
		save_settings()
	else:
		# Load settings file.
		config.load(SETTINGS_FILE_PATH)
	
	# Reload settings to match those in the file.
	load_settings()

#---SAVE-SETTINGS-----------------

# Save settings file.
func save_settings() -> void:
	# Set starting video options. 
	config.set_value("video", "fullscreen", video_settings.fullscreen)
	if resolutions.keys().has(video_settings.resolution):
		config.set_value("video", "resolution", video_settings.resolution)
	else:
		config.set_value("video", "resolution", default_resolution)
	
	# Set starting audio options.
	config.set_value("audio", "general", audio_settings.general)
	config.set_value("audio", "music", audio_settings.music)
	config.set_value("audio", "sfx", audio_settings.sfx)
	
	# Save settings to the file.
	config.save(SETTINGS_FILE_PATH)

#---LOAD-SETTINGS-----------------

# Load all settings.
func load_settings() -> void:
	_load_video_settings()
	_load_audio_settings()

# Load video settings.
func _load_video_settings():
	# Load video settings from file.
	for key in config.get_section_keys("video"):
		var file_value = config.get_value("video", key)
		if (key == "resolution" and !resolutions.keys().has(file_value)):
			video_settings[key] = default_resolution
		else:
			video_settings[key] = file_value
	
	# Set correct fullscreen stance.
	if video_settings.fullscreen:
		# Set window to fullscreen mode.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# Set window to window mode.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Set window to correct resolution.
	var key = video_settings.resolution
	DisplayServer.window_set_size(resolutions[key])
	
	# Set correct window location.
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = DisplayServer.window_get_size_with_decorations()
	DisplayServer.window_set_position(screen_center - window_size / 2)

# Load audio settings.
func _load_audio_settings():
	# Load audio settings from file.
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	
	# Set correct master bus value.
	AudioServer.set_bus_volume_db(bus.general,linear_to_db(audio_settings.general))
	
	# Set correct music bus value.
	AudioServer.set_bus_volume_db(bus.music,linear_to_db(audio_settings.music))
	
	# Set correct SFX bus value.
	AudioServer.set_bus_volume_db(bus.sfx,linear_to_db(audio_settings.sfx))
