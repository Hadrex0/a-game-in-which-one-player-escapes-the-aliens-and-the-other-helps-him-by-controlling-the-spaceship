class_name Player extends CharacterBody2D
#signal hit

# Variables for player movement.
@export var speed = 300 #player max movement speed
const acceleration = 1500 #how fast player speed up
const friction = 1500 #how fast player stops
var input = Vector2.ZERO #variable for storing input

# Variables for moving across the spaceship
var invisible = false
var invincibility_duration = 0.2 # seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.call_deferred("show") #player is shown on start

# Function for calculating player location when moving.
func player_movement(delta):
	# Get input from keyboard.
	input = Input.get_vector("move_left","move_right","move_up","move_down")
	
	# Set the location of the Player.
	if input: #when move keys are pressed speed up the movement of the Player
		velocity = velocity.move_toward(input * speed , delta * acceleration)
	else: #when move keys are not pressed stop the movement of the Player
		velocity = velocity.move_toward(Vector2(0,0), delta * friction)

# Player physic system.
func _physics_process(delta):
	player_movement(delta) #set the location of the Player
	move_and_slide() #move the Player to correct location

# Player can't interact with doors for some time.
func invisibility_start() -> void:
	invisible = true
	$InvisibilityTimer.start(invincibility_duration)

# Player can interact with doors again.
func _on_invisibility_timer_timeout() -> void:
	invisible = false
