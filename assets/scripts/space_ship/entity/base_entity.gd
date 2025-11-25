class_name BseEntity extends CharacterBody2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for door collision.
@onready var door_timer = Timer.new() #timer node
@onready var door_duration = 0.8 #duration in seconds
@onready var door_touch = true #is Entity detectable by doors

# Variables for entity collision.
@onready var entity_timer = Timer.new() #timer node
@onready var entity_duration = 0.6 #duration in seconds
@onready var entity_touch = true #is Entity detectable by others

#---SETTERS-----------------------

func _door_timer_init() -> void:
	door_timer.wait_time = door_duration
	self.add_child(door_timer)
	door_timer.timeout.connect(_on_door_timer_timeout)

func _entity_timer_init() -> void:
	entity_timer.wait_time = entity_duration
	self.add_child(entity_timer)
	entity_timer.timeout.connect(_on_entity_timer_timeout)

#---ALIEN-START--------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_door_timer_init()
	_entity_timer_init()

#---DOOR-INVISIBILITY--------------

# Entity can't interact with doors during timer counting.
func door_timer_start() -> void:
	# Entity starts being invincible.
	door_touch = false
	
	# Start door timer.
	door_timer.start()

# Entity can interact with doors again.
func _on_door_timer_timeout() -> void:
	# Entity stops being invincible.
	door_touch = true

#---ENTITY-INVISIBILITY------------

# Entity can't be detected by other entities during timer counting.
func entity_timer_start() -> void:
	# Entity starts being invincible.
	entity_touch = false
	
	# Start entity timer.
	entity_timer.start()

# Entity can be detected by other entities again.
func _on_entity_timer_timeout() -> void:
	# Entity stops being invincible.
	entity_touch = true
