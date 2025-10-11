extends Area2D

@export_group("Next Room")
@export var connected_room: String #name of the room behind the door
@export var direction: String #N, E, S, or W

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.invisible == false:
			starship_manager.change_room(get_owner(), connected_room, direction)
		else:
			body.invisible = false
