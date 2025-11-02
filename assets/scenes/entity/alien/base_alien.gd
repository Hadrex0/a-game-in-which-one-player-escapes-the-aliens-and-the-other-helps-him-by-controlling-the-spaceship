class_name BaseAlien extends CharacterBody2D

#---CONSTANTS---------------------

#---VARIABLES---------------------

# Variables for alien movement.
@export var speed = 200 #alien max movement speed
var target : Vector2

#---SETTERS-----------------------

# Set new target position for alien.
func set_new_target() -> void:
	var size = game_manager._dungeon.ROOM_SIZE
	
	var nx = randi_range(size.min.x, size.max.x)
	var ny = randi_range(size.min.y, size.max.y)
	
	target = Vector2(nx, ny)
	print(target)

#---ALIEN-START--------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the target location of the alien.
	set_new_target()

#---ALIEN-MOVEMENT-----------------

#Alien physic system.
func _physics_process(delta: float) -> void:
	# Set the location of the alien and distance to the target location.
	var distance = alien_movement(delta)
	
	# Move the alien to correct location.
	if distance < 5.0: #if alien is near the target
		set_new_target()
	else: #if alien is not near the target
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
