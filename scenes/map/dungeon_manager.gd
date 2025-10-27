class_name Dungeon extends Node2D


@export var _room_scene : PackedScene

# Variables for dungeon generating
@export var _dimensions : Vector2i = Vector2i(10,10)
@export var _start : Vector2i = Vector2i(-1, -1)
@export var _critical_path_length : int = 50
@export var _branch_probability : float = 0.3
var dungeon : Array = []
var next_id : int = 0

# Variables for Player 1
@onready var player: Player = $"../Player"
@onready var entrance_markers: Node2D = $"../EntranceMarkers"


const DIRECTIONS: Array[Vector2i] = [
	Vector2i( 0,-1),
	Vector2i( 1, 0),
	Vector2i( 0, 1),
	Vector2i(-1, 0)
]

const ROOM_SIZE: Vector2 = Vector2(1152, 648)

# 🧱 Room structure
func make_room(id: int, pos: Vector2i) -> Dictionary:
	return {
		"id": id,
		"pos": pos,
		"doors": [false, false, false, false],
		"connections": [-1, -1, -1, -1],
		"room_scene" : PackedScene
	}
	
var room_nodes : Dictionary = {}
var current_room = make_room(-1, Vector2i(-1, -1))

func get_dimension_x():
	return _dimensions.x

func get_dimension_y():
	return _dimensions.y

func _ready() -> void:
	_initialize_dungeon()
	_place_entrance()
	_generate_path(_start, _critical_path_length, "C")
	_add_branches(_branch_probability)
	_print_dungeon()
	#_print_connections()
	#_draw_dungeon()
	current_room = dungeon[_start.x][_start.y]
	game_manager.dungeon_init(self)
	game_manager.player_init(player)
	update_room("StartPosition")
	

func _initialize_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(null)

func _place_entrance() -> void:
	if _start.x < 0 or _start.x >= _dimensions.x or _start.y < 0 or _start.y >= _dimensions.y:
		_start = Vector2i(randi_range(0, _dimensions.x - 1), randi_range(0, _dimensions.y - 1))
	dungeon[_start.x][_start.y] = make_room(next_id, _start)
	next_id += 1

func _generate_path(from : Vector2i, length : int, marker: String) -> bool:
	if length == 0:
		return true

	var current : Vector2i = from
	var random: int = randi_range(0, 3)
	var direction : Vector2i = DIRECTIONS[random]

	for i in 4:
		var nx = current.x + direction.x
		var ny = current.y + direction.y

		if nx >= 0 and nx < _dimensions.x and ny >= 0 and ny < _dimensions.y and dungeon[nx][ny] == null:
			# 🔗 Create room
			dungeon[nx][ny] = make_room(next_id, Vector2i(nx, ny))
			next_id += 1

			if await _generate_path(Vector2i(nx, ny), length - 1, marker):
				return true
			else:
				# rollback in case of fail
				dungeon[current.x][current.y].doors[random] = false
				dungeon[nx][ny] = null
				next_id -= 1

		random = (random + 1) % 4
		direction = DIRECTIONS[random]

	return false

# 🌿 random branches around main path
func _add_branches(probability: float):
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			var room = dungeon[x][y]
			if room == null:
				continue
			for i in 4:
				var dir = DIRECTIONS[i]
				#var nx = x+(i%2*-1*(i-2))
				#var ny = y+((i+1)%2*(i-1))
				var nx = x+dir.x
				var ny = y+dir.y
				
				if nx < 0 or nx >= _dimensions.x or ny < 0 or ny >= _dimensions.y:
					continue
				if dungeon[nx][ny] == null:
					if randf() >= probability:
						continue
					dungeon[nx][ny] = make_room(next_id, Vector2i(nx, ny))
					next_id += 1
					room.doors[i] = true
				elif room.connections[i] != -1:
					continue 
				
				room.doors[i] = true
				dungeon[nx][ny].doors[(i+2)%4] = true
				room.connections[i] = dungeon[nx][ny].id
				dungeon[nx][ny].connections[(i+2)%4] = room.id

# 📜 Debug prints
func _print_dungeon() -> void:
	var dungeon_as_string : String = ""
	#for y in range(_dimensions.y -1, -1, -1):
	for y in _dimensions.y:
		for x in _dimensions.x:
			var cell = dungeon[x][y]
			if cell != null:
				if cell.id < 10:
					dungeon_as_string += "[ " + str(cell.id) + "]"
				else:
					dungeon_as_string += "[" + str(cell.id) + "]"
			else:
				dungeon_as_string += "[  ]"
		dungeon_as_string += "\n"
	print(dungeon_as_string)

func _print_connections() -> void:
	print("--- CONNECTIONS ---")
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			var r = dungeon[x][y]
			if r != null:
				print("Room ", r.id, " at ", r.pos, " connects to ", r.connections)

# 
func update_room(previous_direction: String):
	# If there is previous room delete it.
	if self.get_child_count() != 0:
		var previous_room = self.get_child(0)
		self.call_deferred("remove_child", previous_room)
		previous_room.call_deferred("queue_free")
	
	# Initiate node with current room.
	var cell = dungeon[current_room.pos.x][current_room.pos.y]
	var room = _room_scene.instantiate()
	self.call_deferred("add_child", room)
	
	# Put Player in correct position.
	_set_player_pos(previous_direction)
	
	# Print all doors in correct positions.
	for i in 4:
		if cell.doors[i]:
			room.call_deferred("add_door", i, cell.connections[i])
	
	print(current_room.id)
	
# Put Player in correct location given by variable "direction" 
func _set_player_pos(direction: String) -> void:
	
	# Find correct spawn location
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == direction:
			# When encountered correct location spawn the Player.
			player.global_position = entrance.global_position
	
