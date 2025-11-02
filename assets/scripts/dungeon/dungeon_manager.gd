class_name Dungeon extends Node2D

#---CONSTANTS---------------------

const ROOM_SIZE: Vector2 = Vector2(1152, 648)
const DIRECTIONS: Array[Vector2i] = [
	Vector2i( 0,-1),
	Vector2i( 1, 0),
	Vector2i( 0, 1),
	Vector2i(-1, 0)
	]
const OBJECT_SPAWN_LOCATIONS_NUMBER: int = 2
const MAX_CONNECTIONS: int = 4

#---VARIABLES---------------------

# Variables for room scenes
@export_category("Room Types")
@export var _starting_room : PackedScene

# Variables for dungeon generating
@export_category("Dungeon Generating")
@export var _dimensions : Vector2i = Vector2i(10,10)
@export var _start : Vector2i = Vector2i(-1, -1)
@export var _critical_path_length : int = 50
@export var _branch_probability : float = 0.3
@export var _escape_pod_activated : bool = false
@export var _colors_number: int
var dungeon : Array = []
var terminals : Array = []
var special_rooms : Array = []
var next_id : int = 0
var room_nodes : Dictionary = {}
var escape_pod : Dictionary = {
	"room_id": -1,
	"color_id": -1,
	"location_id": -1,
	"active": false
	}
var current_room = make_room(-1, Vector2i(-1, -1))

# Variables for Player 1
@onready var player: Player = $"../Player"
@onready var entrance_markers: Node2D = $"../EntranceMarkers"

#---INITIALIZE-VARIABLES----------

# Initialize max colors number.
func _initialize_colors_number() -> void:
	if (_colors_number == null or _colors_number > game_manager.COLORS.size() or _colors_number < 1):
		_colors_number = game_manager.COLORS.size()

# Create a room.
func make_room(id: int, pos: Vector2i) -> Dictionary:
	return {
		"id": id,
		"pos": pos,
		"doors": [false, false, false, false],
		"door_color": [-1, -1, -1, -1],
		"connections": [-1, -1, -1, -1],
		"end_color": -1,
		"room_scene" : PackedScene
	}

# Create a terminal.
func make_terminal(room_id: int, color_id: int) -> Dictionary:
	return {
		"room_id": room_id,
		"color_id": color_id,
		"color": game_manager.COLORS[color_id],
		"location_id": randi_range(0, OBJECT_SPAWN_LOCATIONS_NUMBER - 1),
		"active": false
	}

# Initialize the array of the dungeon to the correct size.
func _initialize_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(null)

#---SETTERS-----------------------

# Set stance of _escape_pod_activated
func set_escape_pod_activated(new_stance: bool):
	_escape_pod_activated = new_stance

#---GETTERS-----------------------

# Get spaceship dimension x
func get_dimension_x():
	return _dimensions.x

# Get spaceship dimension y 
func get_dimension_y():
	return _dimensions.y

# Get stance of _escape_pod_activated
func is_escape_pod_activated():
	return _escape_pod_activated

#---GAME-START--------------------

# Start spaceship at the start of the game.
func _ready() -> void:
	# Initialize important variables.
	_initialize_colors_number()
	
	# Generate dungeon first
	_initialize_dungeon()
	_generate_dungeon()
	
	# Set current room at starting position.
	current_room = dungeon[_start.x][_start.y]
	
	# Initialize variables for game_manager singleton.
	game_manager.dungeon_init(self)
	game_manager.player_init(player)
	game_manager.sound_init()
	
	# Display starting room.
	update_room("StartPosition")
	
	# Debug print.
	_debug_print()

#---DUNGEON-GENERATION------------

# Generate the dungeon.
func _generate_dungeon() -> void:
	_place_entrance()
	_generate_path(_start, _critical_path_length, "C")
	_place_escape_pod()
	_set_active_color()
	_add_branches(_branch_probability)
	_place_terminals()

# Place entrence point for generating the dungeon.
func _place_entrance() -> void:
	# If entrence coordinates are outside of the spacespip, generate new entrance.
	if _start.x < 0 or _start.x >= _dimensions.x or _start.y < 0 or _start.y >= _dimensions.y:
		_start = Vector2i(randi_range(0, _dimensions.x - 1), randi_range(0, _dimensions.y - 1))
	
	# Add the starting room to special rooms.
	special_rooms.append(next_id)
	
	# When the starting room is within the dungeon, place room there.
	dungeon[_start.x][_start.y] = make_room(next_id, _start)
	next_id += 1

# Generate dungeon based on random path across it.
func _generate_path(from : Vector2i, length : int, marker: String) -> bool:
	# If length of a dungeon is equal to zero return true.
	if length == 0:
		return true
	
	# Setting varbiables for the generating path.
	var current : Vector2i = from #starting coordinates
	var random: int = randi_range(0, MAX_CONNECTIONS - 1) #random number from 0 to 3.
	var direction : Vector2i = DIRECTIONS[random] #random direction.
	
	# For every side of the room.
	for i in MAX_CONNECTIONS:
		# Coordinates of the next room.
		var nx = current.x + direction.x
		var ny = current.y + direction.y
		
		# If next room is within the spaceship.
		if nx >= 0 and nx < _dimensions.x and ny >= 0 and ny < _dimensions.y and dungeon[nx][ny] == null:
			# Create a room.
			dungeon[nx][ny] = make_room(next_id, Vector2i(nx, ny))
			next_id += 1
			
			# Generate next room using reccurence.
			if await _generate_path(Vector2i(nx, ny), length - 1, marker):
				return true
			else:
				# Rollback in case of fail.
				dungeon[current.x][current.y].doors[random] = false
				dungeon[nx][ny] = null
				next_id -= 1
		
		# When there cannot be room at (nx,ny) select next side.
		random = (random + 1) % MAX_CONNECTIONS
		direction = DIRECTIONS[random]
	# If there is no room for generating another room return false.
	return false

# Create connections between the rooms of the spaceship.
func _add_branches(probability: float):
	# Set id of the last isolated room as last room id.
	var next_isolated_id = next_id
	
	# Go through all of the rooms.
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			var room = dungeon[x][y]
			
			# If at x,y is no room or the room is isolated, skip those coordinates. 
			if room == null or room.id > next_id: 
				continue
			
			# Check all sides of the room in search of nearby rooms.
			for i in MAX_CONNECTIONS: 
				var dir = DIRECTIONS[i]
				var nx = x+dir.x
				var ny = y+dir.y
				var random_color: int = randi_range(0, _colors_number - 1)
				
				# If if the next room coordinates are within the dungeon skip those coordinates.
				if nx < 0 or nx >= _dimensions.x or ny < 0 or ny >= _dimensions.y: 
					continue
				
				# If there is no room behind a wall, spawn a isolated room.
				if dungeon[nx][ny] == null: 
					if randf() >= probability:  
						continue
					dungeon[nx][ny] = make_room(next_isolated_id, Vector2i(nx, ny))
					next_isolated_id += 1
					_set_door_data(i, random_color, room, nx, ny)
				# Check if there is no connection yet and if the connection is with singular room.
				if room.connections[i] == -1 and !(dungeon[nx][ny].id > next_id):
					_set_door_data(i, random_color, room, nx, ny)
	
	# Set id of the last room as last isolated room id.
	next_id = next_isolated_id

# Set currently active color.
func _set_active_color() -> void:
	game_manager.active_color_id = randi_range(0, _colors_number)

# Assign data for the doors and connection.
func _set_door_data(door_id: int, door_color: int, room, room_x: int, room_y: int) -> void:
	var opposite_id = (door_id+2)%4
	
	# Set connections to room id, for representing corridor.
	room.connections[door_id] = dungeon[room_x][room_y].id
	dungeon[room_x][room_y].connections[opposite_id] = room.id
	
	# Set doors to true for spawning doors.
	room.doors[door_id] = true
	dungeon[room_x][room_y].doors[opposite_id] = true
	
	room.door_color[door_id] = door_color
	dungeon[room_x][room_y].door_color[opposite_id] = door_color

# Place escape pods in the dungeon.
func _place_escape_pod() -> void:
	# Set values of escape pod.
	escape_pod.room_id = next_id - 1
	escape_pod.color_id = randi_range(0, _colors_number - 1)
	escape_pod.location_id = randi_range(0, OBJECT_SPAWN_LOCATIONS_NUMBER - 1)
	
	# Add the escape pod room to special rooms.
	special_rooms.append(escape_pod.room_id)

# Place escape pods in the dungeon.
func _place_terminals() -> void:
	# Variable for checking if color is used.
	var color_used: Array
	color_used.resize(_colors_number)
	color_used.fill(false)
	
	# Start from the color of the escape pod. 
	var color_id = escape_pod.color_id
	
	# Place terminals in the dungeon. 
	for i in _colors_number:
		# Set the terminal room id.
		var room_id = randi_range(0, next_id)
		while special_rooms.has(room_id): #if selected room is used, use the previous free one.
			room_id = (room_id - 1) % next_id
		
		# Select the terminal color.
		while color_used[color_id]: #if selected color is used, use the next free one.
			color_id = (color_id + 1) % _colors_number
		color_used[color_id] = true
		
		# Add new terminal values of the terminal.
		terminals.append(make_terminal(room_id, color_id))
		
		# Add the terminal room to special rooms.
		special_rooms.append(terminals[i].room_id)

#---ROOM-DISPLAY------------------

# Update displayed room to the current room.
func update_room(previous_direction: String):
	# If there is previous room delete it.
	if self.get_child_count() != 0:
		var previous_room = self.get_child(0)
		self.call_deferred("remove_child", previous_room)
		previous_room.call_deferred("queue_free")
	
	# Initiate node with current room.
	var cell = dungeon[current_room.pos.x][current_room.pos.y]
	var room: Node  = _starting_room.instantiate()
	self.call_deferred("add_child", room)
	
	# Put Player in correct position.
	_set_player_pos(previous_direction)
	
	# Put doors in correct spots.
	_draw_doors(room, cell)
	
	# Put escape pod in correct spot.
	_draw_escape_pod(room, cell)
	
	# Put terminal in correct spot.
	_draw_terminal(room, cell)
	
	# Debug print
	_print_current_room()

# Display doors in the active room.
func _draw_doors(room_scene: Node, active_room) -> void:
	# Print all doors in correct positions.
	for i in MAX_CONNECTIONS:
		if active_room.doors[i]:
			room_scene.call_deferred("add_door", i, active_room.connections[i], active_room.door_color[i])

# Display escape pods in the active room.
func _draw_escape_pod(room_scene: Node, active_room) -> void:
	# Add escape pod if there is one in this active room.
	if active_room.id == escape_pod.room_id:
		room_scene.call_deferred("add_escape_pod", escape_pod.color_id, escape_pod.location_id)

# Display terminal in the active room.
func _draw_terminal(room_scene: Node, active_room) -> void:
	# Add terminal if there is one in this active room.
	for i in terminals.size():
		if active_room.id == terminals[i].room_id:
			room_scene.call_deferred("add_terminal", terminals[i].color_id, terminals[i].location_id)

# Put Player in correct location given by variable "direction" 
func _set_player_pos(direction: String) -> void:
	# Find correct spawn location
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == direction:
			# When encountered correct location spawn the Player.
			player.global_position = entrance.global_position

#---DEBUG-PRINT-------------------

# Main debug print
func _debug_print() -> void:
	_print_dungeon()
	#_print_connections()
	_print_terminals()
	print("Go to the room ", escape_pod.room_id)
	print("Escape pod is ",game_manager.COLORS[escape_pod.color_id])

# Print map of the spaceship.
func _print_dungeon() -> void:
	print("--- DUNGEON MAP ---")
	var dungeon_as_string : String = ""
	for y in _dimensions.y:
		for x in _dimensions.x:
			
			# Setting the room map in the pattern: "[xx]" (xx - room id). 
			var cell = dungeon[x][y]
			dungeon_as_string += "["
			if cell != null: #if there is a room, print room id.
				if cell.id < 10: #if cell id is lower than 10 add a space.
					dungeon_as_string += " " 
				dungeon_as_string += str(cell.id)
			else: #if there is no a room, print empty space.
				dungeon_as_string += "  "
			dungeon_as_string += "]"
		dungeon_as_string += "\n"
	print(dungeon_as_string)

# Print terminal informations.
func _print_terminals() -> void:
	print("---- TERMINALS ----")
	for i in _colors_number:
		print(terminals[i].color," Terminal is in room ", terminals[i].room_id)
	print("")

# Print all connections.
func _print_connections() -> void:
	print("--- CONNECTIONS ---")
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			var r = dungeon[x][y]
			if r != null:
				# Start the line variable
				var line = "Room " 
				
				# Goal: line = "Room xx at ("
				if r.id < 10:
					line += " "
				line += str(r.id) + " at (" 
				
				# Goal: line = "Room xx at (xx,"
				if r.pos.x < 10:
					line += " "
				line += str(r.pos.x) + ","
				
				# Goal: line = "Room xx at (xx,xx) connects to ["
				if r.pos.y < 10:
					line += " "
				line += str(r.pos.y) + ") connects to ["
				
				# Goal: line = "Room xx at (xx,xx) connects to [xx/C, xx/C, xx/C, xx/C]"
				for i in MAX_CONNECTIONS:
					if r.connections[i] == -1:
						line += " -/-"
					else:
						if r.connections[i] < 10:
							line += " "
						line += str(r.connections[i]) + "/"
						
						# Get color first leter from door_color
						match r.door_color[i]:
							0:
								line += "R"
							1:
								line += "B"
							2:
								line += "G"
							3:
								line += "Y"
					if i < 3:
						line += ", "
				line += "]"
				
				# Print formatted line.
				print(line)
	print("")

# Print room in which Player is located.
func _print_current_room() -> void:
	print("you are in room: ",current_room.id)
