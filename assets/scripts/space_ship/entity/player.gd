class_name Player extends BseEntity

#---CONSTANTS---------------------

# Constants for player movement.
const acceleration = 3000 #how fast player speed up
const friction = 2500 #how fast player stops

#---VARIABLES---------------------

# Variables for player movement.
@onready var speed = 300 #player max movement speed
@onready var input = Vector2.ZERO #variable for storing input

# Variables for player interaction.
@onready var touched_object: String #object that player is touching

#---PLAYER-MOVEMENT----------------

# Function for calculating player location when moving.
func player_movement(delta):
	# Get input from keyboard.
	input = Input.get_vector("p1_move_left","p1_move_right","p1_move_up","p1_move_down")
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
	if body.is_in_group("Alien") and entity_touch:
		if body.entity_touch:
			game_manager.game_lost()
