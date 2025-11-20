extends Area2D

# Variable for the object animation.
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@export var color: String
var pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.connect("_pressed_button", Callable(self, "_button_pressed"))
	animation.play("idle")

func _button_pressed(active_color: String) -> void:
	if active_color == color: 
		animation.play("pressed")
		if active_color == "Gray": 
			pressed = true
			$Timer.start()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and (color != "Gray" or !pressed):
		animation.play("highlighted")
		body.touched_object = "Button"
		game_manager.active_button_color = color



func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animation.play("idle")
		body.touched_object = ""
		game_manager.active_button_color = ""


func _on_timer_timeout() -> void:
	animation.play("idle")
	pressed = false
