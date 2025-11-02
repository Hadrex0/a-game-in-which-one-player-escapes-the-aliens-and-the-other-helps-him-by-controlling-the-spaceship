class_name BaseAlien extends CharacterBody2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Alien identifiers.
@export var alien_id: int 

# Variables for alien movement.
@export var speed = 200 #alien max movement speed
var target : Vector2 
var movement_time = 3.0 # seconds
var moving: bool

# Debug movement.
var debug: bool = false

#---SETTERS-----------------------

# Set new target position for alien.
func set_new_target() -> void:
	# Select random coordinates in the room.
	var size = game_manager._dungeon.ROOM_SIZE
	var nx = randi_range(size.min.x, size.max.x)
	var ny = randi_range(size.min.y, size.max.y)
	
	# Set new target and start timer.
	target = Vector2(nx, ny)

# Alien search new target periodicly.
func _on_movement_timer_timeout() -> void:
	$MovementTimer.start(movement_time)
	if !game_manager.debug:
		set_new_target()

# Debug tool.
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("cheat_alien") and game_manager.debug):
		target = get_global_mouse_position()

#---ALIEN-START--------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = self.position
	
	# Start timer and search for target location for the alien.
	_on_movement_timer_timeout()

#---ALIEN-MOVEMENT-----------------

#Alien physic system.
func _physics_process(delta: float) -> void:
	# Set the location for the alien and distance to the target location.
	var distance = alien_movement(delta)
	
	# Move the alien to correct location.
	if distance > 2.0: #if alien is not near the target
		move_and_slide()

# Function for calculating alien location when moving.
func alien_movement(delta) -> float:
	# Set variables for alien movement
	var displacement = target - global_transform.origin
	var direction = displacement.normalized() #direction to target
	var distance = displacement.length() #distance to target
	var max_speed = distance / delta #speed to move alien to target instantaneously
	
	# Set alien velocity
	velocity = direction * minf(speed, max_speed)
	
	# Return distance to the target
	return distance
