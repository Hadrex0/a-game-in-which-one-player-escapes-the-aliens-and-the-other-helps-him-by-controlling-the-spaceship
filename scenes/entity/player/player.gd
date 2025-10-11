class_name Player extends CharacterBody2D
signal hit

@onready var timer = $Timer
@export var speed = 400 
const acceleration = 4000
const friction = 2000
var invisible: bool

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

func start() -> void:
	show()
	#invisible = false
	collision(true)

func stop() -> void:
	hide()
	#invisible = true
	collision(false)

func collision(stance: bool) -> void:
	$CollisionShape2D.disabled = !stance
