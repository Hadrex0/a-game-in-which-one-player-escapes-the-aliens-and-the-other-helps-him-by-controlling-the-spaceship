extends CharacterBody2D
signal hit

@export var speed = 300 
const acceleration = 3000
const friction = 1500
var input = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func player_movement(input, delta):
	if input: velocity = velocity.move_toward(input * speed , delta * acceleration)
	else: velocity = velocity.move_toward(Vector2(0,0), delta * friction)

func _physics_process(delta):
	var input = Input.get_vector("move_left","move_right","move_up","move_down")
	player_movement(input, delta)
	move_and_slide()

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
