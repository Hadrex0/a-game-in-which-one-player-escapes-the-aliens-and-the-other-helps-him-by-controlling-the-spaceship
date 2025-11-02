class_name Player extends CharacterBody2D

#---CONSTANTS---------------------

# Constants for player movement.
const acceleration = 3000 #how fast player speed up
const friction = 2500 #how fast player stops

#---VARIABLES---------------------

# Variables for player movement.
@onready var speed = 300 #player max movement speed
var input = Vector2.ZERO #variable for storing input

# Variables for moving across the spaceship
var invisible = false
var invincibility_duration = 0.2 # seconds

#---PLAYER-START-------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.call_deferred("show") #player is shown on start

#---PLAYER-MOVEMENT----------------

# Function for calculating player location when moving.
func player_movement(delta):
	# Get input from keyboard.
	input = Input.get_vector("move_left","move_right","move_up","move_down")
	# Set the location of the Player.
	if input: #when move keys are pressed speed up the movement of the Player
		velocity = velocity.move_toward(input * speed , delta * acceleration)
		$AnimatedSprite2D.play("walk-down")
	else: #when move keys are not pressed stop the movement of the Player
		velocity = velocity.move_toward(Vector2(0,0), delta * friction)
		$AnimatedSprite2D.play("idle")

# Player physic system.
func _physics_process(delta):
	player_movement(delta) #set the location of the Player
	move_and_slide() #move the Player to correct location

#---TOUCHING-OBJECT----------------

# When Player is touching something
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the Player is touched by the alien.
	if body.is_in_group("Alien"):
		game_manager.game_lost()

#---PLAYER-INVISIBILITY------------

# Player can't interact with doors for some time.
func invisibility_start() -> void:
	invisible = true
	$InvisibilityTimer.start(invincibility_duration)

# Player can interact with doors again.
func _on_invisibility_timer_timeout() -> void:
	invisible = false
