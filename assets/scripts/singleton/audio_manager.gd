extends Node

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variable for in game background music.
@onready var music: Array = [
	AudioStreamPlayer.new(), #menu background music
	AudioStreamPlayer.new() #game background music
	]

# Variables for sounds.
@onready var paper_flip_sound = AudioStreamPlayer.new() #sound of paper flip
@onready var paper_tear_sound = AudioStreamPlayer.new() #sound of paper tear
@onready var door_sound = AudioStreamPlayer.new() #sound for door opening/closing

# Variables for sound timer.
@onready var sound_timer = Timer.new() #timer of window when sounds cannot be played
@onready var sound_timer_duration: float = 0.04 #duration of sound timer in seconds
@onready var sound_avaliable: bool = true #can sound manager play sound. 

# Variables for audio path.
@onready var music_path = "res://assets/audio/music/" #path for music files
@onready var sound_path = "res://assets/audio/sfx/" #path for sound files

#---INITIALIZE-VARIABLES----------

# Initialize music array with game music backgrounds.
func _music_init() -> void:
	# Assign values to background music. 
	for i in music.size():
		music[i].set_stream(load(create_music_path(i)))
		music[i].bus = "BGM"
		self.add_child(music[i])

# Initialize paper flip sound node.
func paper_flip_sound_init() -> void:
	paper_flip_sound.set_stream(load(sound_path + "paper_flip_sound.wav"))
	paper_flip_sound.bus = "SFX"
	self.add_child(paper_flip_sound)

# Initialize paper tear sound node.
func _paper_tear_sound_init() -> void:
	paper_tear_sound.set_stream(load(sound_path + "paper_tear_sound.wav"))
	paper_tear_sound.bus = "SFX"
	self.add_child(paper_tear_sound)

# Initialize door sound node.
func _door_sound_init() -> void:
	door_sound.set_stream(load(sound_path + "door_sound.wav"))
	door_sound.bus = "SFX"
	self.add_child(door_sound)

# Initialize sound timer.
func _sound_timer_init() -> void:
	self.add_child(sound_timer)
	sound_timer.timeout.connect(_on_sound_timer_timeout)

#---FILE-PATH-CREATION-------------

# Create path for background music.
func create_music_path(id: int) -> String:
	# Variable for returning path.
	var path = music_path
	
	# Add correct file name to the path.
	match id:
		0: #menu background music
			path += "Fluffing a Duck.ogg"
		1: #game background music
			path += "Fnaf Ambience.ogg"
	
	# Return created path.
	return path

#---READY-AUDIO-MANAGER-----------

# Ready audio manager at start of application.
func _ready() -> void:
	# Sounds initialization.
	_music_init()
	paper_flip_sound_init()
	_paper_tear_sound_init()
	_door_sound_init()
	
	# Sound timer initialization.
	_sound_timer_init()

#---SOUND-TIMER-------------------

# Sound cannot be played.
func _start_sound_timer() -> void:
	sound_timer.start(sound_timer_duration)
	sound_avaliable = false

# Sound can be played.
func _on_sound_timer_timeout() -> void:
	sound_avaliable = true

#---START-MUSIC-------------------

# Start menu music.
func start_menu_music() -> void:
	music[0].play()

# Start game music.
func start_game_music() -> void:
	music[1].play()

#---STOP-MUSIC--------------------

# Stop menu music.
func stop_menu_music() -> void:
	music[0].stop()

# Stop game music.
func stop_game_music() -> void:
	music[1].stop()

#---PLAY-SOUND--------------------

# Play paper flip sound sound.
func play_paper_flip_sound() -> void:
	if sound_avaliable: 
		paper_flip_sound.play()
	_start_sound_timer()

# Play paper tear sound sound.
func play_paper_tear_sound() -> void:
	if sound_avaliable: 
		paper_tear_sound.play()
	_start_sound_timer()

# Play door sound.
func play_door_sound() -> void:
	if sound_avaliable: 
		door_sound.play()
	_start_sound_timer()
