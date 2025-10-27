extends Node2D

@export var _room_scene : PackedScene

@export var _dimensions : Vector2i = Vector2i(10,10)
@export var _start : Vector2i = Vector2i(-1, -1)
@export var _critical_path_length : int = 50
@export var _branch_probability : float = 0.3

var dungeon : Array = []
var next_id : int = 0

enum Doors {
	RIGHT = 1,
	UP = 2,
	LEFT = 4,
	DOWN = 8,
}

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i(0, 1),
	Vector2i.LEFT,
	Vector2i(0, -1)
]

const ROOM_SIZE: Vector2 = Vector2(1152, 648)

# 🧱 Room structure
func make_room(id: int, pos: Vector2i) -> Dictionary:
	return {
		"id": id,
		"pos": pos,
		"doors": 0,
		"connections": []
	}
	
var room_nodes : Dictionary = {}
var current_room_id : int = -1


func _ready() -> void:
	_initialize_dungeon()
	_place_entrance()
	_generate_path(_start, _critical_path_length, "C")
	_add_branches(_branch_probability)
	_print_dungeon()
	_print_connections()
	_draw_dungeon()
	current_room_id = dungeon[_start.x][_start.y].id
	_show_current_room()

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

			# 🧱 Add door & connections
			dungeon[current.x][current.y].doors |= Doors.values()[random]
			dungeon[nx][ny].doors |= Doors.values()[(random + 2) % 4]
			dungeon[current.x][current.y].connections.append(dungeon[nx][ny].id)
			dungeon[nx][ny].connections.append(dungeon[current.x][current.y].id)

			if await _generate_path(Vector2i(nx, ny), length - 1, marker):
				return true
			else:
				# rollback in case of fail
				dungeon[current.x][current.y].doors &= ~Doors.values()[random]
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
			for i in range(4):
				var dir = DIRECTIONS[i]
				var nx = x + dir.x
				var ny = y + dir.y
				if nx < 0 or nx >= _dimensions.x or ny < 0 or ny >= _dimensions.y:
					continue
				if dungeon[nx][ny] == null and randf() < probability:
					dungeon[nx][ny] = make_room(next_id, Vector2i(nx, ny))
					next_id += 1
					room.doors |= Doors.values()[i]
					dungeon[nx][ny].doors |= Doors.values()[(i + 2) % 4]
					room.connections.append(dungeon[nx][ny].id)
					dungeon[nx][ny].connections.append(room.id)

# 📜 Debug prints
func _print_dungeon() -> void:
	var dungeon_as_string : String = ""
	for y in range(_dimensions.y -1, -1, -1):
		for x in _dimensions.x:
			var cell = dungeon[x][y]
			if cell != null:
				dungeon_as_string += "[" + str(cell.id) + "]"
			else:
				dungeon_as_string += "[ ]"
		dungeon_as_string += "\n"
	print(dungeon_as_string)

func _print_connections() -> void:
	print("--- CONNECTIONS ---")
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			var r = dungeon[x][y]
			if r != null:
				print("Room ", r.id, " at ", r.pos, " connects to ", r.connections)

# 🎨 Drawing
func _draw_dungeon() -> void:
	for y in range(_dimensions.y -1, -1, -1):
		for x in _dimensions.x:
			var cell = dungeon[x][y]
			if cell == null:
				continue

			var room = _room_scene.instantiate()
			add_child(room)
			for i in Doors.size():
				if dungeon[x][y].doors & Doors.values()[i]:
					room.add_door(i)
			room.visible = false  # keep hidden initially

			room_nodes[cell.id] = room

func _show_current_room():
	for room_id in room_nodes.keys():
		room_nodes[room_id].visible = (room_id == current_room_id)

func go_to_room(new_room_id: int):
	if new_room_id in room_nodes:
		current_room_id = new_room_id
		_show_current_room()
