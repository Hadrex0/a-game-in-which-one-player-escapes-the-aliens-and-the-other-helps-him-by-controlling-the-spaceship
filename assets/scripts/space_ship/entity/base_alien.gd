class_name BaseAlien extends CharacterBody2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Alien id.
@export var alien_id: int 

# Variables for alien movement.
@export var speed = 150 #alien max movement speed
var target : Vector2 #position where alien is going

#---SETTERS-----------------------

# Set new target position for alien.
func set_new_target() -> void:
	# Select random coordinates in the room.
	var size = game_manager.get_dungeon().ROOM_SIZE
	var nx = randi_range(size.min.x, size.max.x)
	var ny = randi_range(size.min.y, size.max.y)
	
	# Set new target and start timer.
	target = Vector2(nx, ny)

# Alien search new target periodicly.
func _alien_movement_logic() -> void:
	# Save current alien position.
	game_manager.get_dungeon().aliens[alien_id].pos = position
	
	# Move alien in the room.
	if randf() <= game_manager.get_dungeon().alien_move_chance:
		set_new_target()

#---ALIEN-START--------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect tick with dungeon manager.
	game_manager.get_dungeon().tick_timeout.connect(_alien_movement_logic)
	
	# Set starting position as its own.
	target = self.position
	
	# Start timer and search for target location for the alien.
	_alien_movement_logic()

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
	var displacement = target - global_transform.origin #location of target relative to position of the alien. 
	var direction = displacement.normalized() #direction to target
	var distance = displacement.length() #distance to target
	var max_speed = distance / delta #speed to move alien to target instantaneously
	
	# Set alien velocity
	velocity = direction * minf(speed, max_speed)
	
	# Return distance to the target
	return distance
