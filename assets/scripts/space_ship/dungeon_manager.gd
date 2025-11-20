class_name Dungeon extends Node2D

#---CONSTANTS---------------------

# Positions of room corners.
const ROOM_SIZE: Dictionary = {
	"min": Vector2(182.0, 160.0),
	"max": Vector2(1098.0, 560.0)
	}

# Positions of directions.
const DIRECTIONS: Array[Vector2i] = [
	Vector2i( 0,-1),
	Vector2i( 1, 0),
	Vector2i( 0, 1),
	Vector2i(-1, 0)
	]

# Number of spawn locations of objects in room.
const OBJECT_SPAWN_LOCATIONS_NUMBER: int = 2

# Max connections inside of a single room.
const MAX_CONNECTIONS: int = 4

#---SIGNALS-----------------------

# Signal to make actions that depend on the ticks.
signal tick_timeout

#---VARIABLES---------------------

# Variables for dungeon generating.
@export_category("Dungeon Generating")
@export var _dimensions : Vector2i = Vector2i(10,10) #dimensions of the dungeon
@export var _start : Vector2i = Vector2i(-1, -1) #starting position
@export var _critical_path_length : int = 50 #length of the path
@export var _branch_probability : float = 0.3 #propability for creating isolated room
@export var _colors_number: int #how many of the colors are active
@onready var next_id : int = 0 #id of the last room
@onready var room_type : Dictionary = { #types of rooms in the dungeon
	"starting_room": "starting_room"
	}

# Variables for storing dungeon data.
@onready var dungeon : Array = [] #array for storing dungeon map
@onready var special_rooms : Array = [] #array for storing ids of special rooms
@onready var current_room = make_room(-1, Vector2i(-1, -1), room_type.starting_room) #currently active room
@onready var terminals : Array = [] #array for storing terminals data
@onready var escape_pod : Dictionary = { #escape pod data
	"room_id": -1,
	"color_id": -1,
	"location_id": -1,
	"active": false
	}

# Variables for Aliens.
@export_category("Aliens")
@export var alien_count: int = 1 #number of aliens in the dungeon
@onready var aliens : Array = [] #array for storing alien data
@onready var alien_move_chance: float = 0.75 #chance for aliens to move in general
@onready var alien_move_to_door_chance: float = 0.1 #chance for aliens to move to another room
@onready var _alien_spawn_markers = $"../AlienMarkers"

# Variables for Player 1
@onready var player: Player = $"../Player"
@onready var entrance_markers: Node2D = $"../EntranceMarkers"

# Game tick manager.
@onready var tick_period = 1.0 # tick duration in seconds

#---INITIALIZE-VARIABLES----------

# Initialize max colors number.
func _initialize_colors_number() -> void:
	# When colors number is invalid value set it to max avaliable value.
	if (_colors_number == null or _colors_number > game_manager.COLORS.size() or _colors_number < 1):
		_colors_number = game_manager.COLORS.size()

# Create a room.
func make_room(id: int, pos: Vector2i, room_scene: String) -> Dictionary:
	return {
		"id": id, #id of the room 
		"pos": pos, #position of the room
		"doors": [false, false, false, false], #are there doors on the wall
		"door_color": [-1, -1, -1, -1], #color of the doors
		"connections": [-1, -1, -1, -1], #id's of the connected rooms
		"room_type" : room_scene #scene type of the room
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

# Create an alien.
func make_alien(location: Vector2) -> Dictionary:
	return {
		"room_id": randi_range(1, next_id - 1),
		"room_pos": Vector2i(-1,-1),
		"pos": location
	}

# Initialize the array of the dungeon to the correct size.
func _initialize_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(null)

#---SETTERS-----------------------

# Set stance of the escape pod.
func set_escape_pod_activated(new_stance: bool):
	escape_pod.active = new_stance

#---GETTERS-----------------------

# Get spaceship dimension x
func get_dimension_x():
	return _dimensions.x

# Get spaceship dimension y 
func get_dimension_y():
	return _dimensions.y

# Get stance of the escape pod.
func is_escape_pod_activated():
	return escape_pod.active

#---GAME-START--------------------

# Start spaceship at the start of the game.
func _ready() -> void:
	game_manager.connect("_send_detected_rooms", Callable(self,"_send_detected_rooms"))
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
	
	# Display starting room.
	update_room("StartPosition")
	
	# Start tick timer.
	_on_tick_timer_timeout()
	
	# Debug print.
	_debug_print()
	
	# Start game music.
	audio_manager.play_background("game")

#---GAME-TICK-HANDLER-------------

# Game tick handler main function.
func _on_tick_timer_timeout() -> void:
	# Emit tick timeout signal
	tick_timeout.emit()
	
	# Move aliens in the dungeon.
	_alien_movement()
	
	# Restart tick timer.
	$"../TickTimer".start(tick_period)

#---DUNGEON-GENERATION------------

# Generate the dungeon.
func _generate_dungeon() -> void:
	# Generate empty rooms.
	_place_entrance()
	_generate_path(_start, _critical_path_length)
	
	# Place escape pod in the last room.
	_place_escape_pod()
	
	# Place aliens in random rooms.
	_place_aliens()
	
	# Activate random color.
	_active_random_color()
	
	# Add connections, doors, and isolated rooms.
	_add_branches(_branch_probability)
	
	# Add terminals.
	_place_terminals()

# Send data about rooms with detected life forms
func _send_detected_rooms() -> void:
	game_manager.detected_life_forms = ""
	
	var rooms_array: Array = []
	
	# Collect unique room IDs from aliens
	for i in alien_count:
		if aliens[i].room_id not in rooms_array:
			rooms_array.append(aliens[i].room_id)
	
	# Pick a random room to replace
	var random_index = randi() % rooms_array.size()
	var temp_room = rooms_array[random_index]
	rooms_array[random_index] = current_room.id
	rooms_array.append(temp_room) # add the replaced room at the end if you still want it
	
	# Build string with formatting
	var formatted_string := ""
	for room_id in rooms_array:
		if room_id < 10:
			formatted_string += "[ %d]" % room_id
		else:
			formatted_string += "[%d]" % room_id
	
	game_manager.detected_life_forms = formatted_string
	game_manager._send_life_forms()

# Place entrence point for generating the dungeon.
func _place_entrance() -> void:
	# If entrence coordinates are outside of the spacespip, generate new entrance.
	if _start.x < 0 or _start.x >= _dimensions.x or _start.y < 0 or _start.y >= _dimensions.y:
		_start = Vector2i(randi_range(0, _dimensions.x - 1), randi_range(0, _dimensions.y - 1))
	
	# Add the starting room to special rooms.
	special_rooms.append(next_id)
	
	# When the starting room is within the dungeon, add a room there.
	dungeon[_start.x][_start.y] = make_room(next_id, _start, room_type.starting_room)
	next_id += 1

# Generate dungeon based on random path across it.
func _generate_path(from : Vector2i, length : int) -> bool:
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
			dungeon[nx][ny] = make_room(next_id, Vector2i(nx, ny), room_type.starting_room)
			next_id += 1
			
			# Generate next room using reccurence.
			if await _generate_path(Vector2i(nx, ny), length - 1):
				return true
			else:
				# Rollback in case of fail.
				dungeon[current.x][current.y].doors[random] = false
				dungeon[nx][ny] = null
				next_id -= 1
		
		# When there cannot be room at (nx, ny) select next side.
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
			
			# If at x, y is no room or the room is isolated, skip those coordinates. 
			if room == null or room.id > next_id: 
				continue
			
			# Check all sides of the room in search of nearby rooms.
			for i in MAX_CONNECTIONS: 
				var direction = DIRECTIONS[i]
				var nx = x+direction.x
				var ny = y+direction.y
				
				# Set random color.
				var random_color: int = randi_range(0, _colors_number - 1)
				
				# If if the next room coordinates are within the dungeon skip those coordinates.
				if nx < 0 or nx >= _dimensions.x or ny < 0 or ny >= _dimensions.y: 
					continue
				
				# If there is no room behind a wall, attempt to create an isolated room.
				if dungeon[nx][ny] == null: 
					if randf() > probability:  
						continue
					
					# Create an isolated room.
					dungeon[nx][ny] = make_room(next_isolated_id, Vector2i(nx, ny), room_type.starting_room)
					next_isolated_id += 1
					
					# Assign door data.
					_assign_door_data(i, random_color, room, nx, ny)
				
				# Check if there is no connection yet and if the connection is with singular room.
				if room.connections[i] == -1 and !(dungeon[nx][ny].id > next_id):
					# Assign door data.
					_assign_door_data(i, random_color, room, nx, ny)
	
	# Set id of the last room as last isolated room id.
	next_id = next_isolated_id

# Set currently active color.
func _active_random_color() -> void:
	game_manager.active_color_id = randi_range(0, _colors_number)

# Assign data for the doors and connection.
func _assign_door_data(door_id: int, door_color: int, room, room_x: int, room_y: int) -> void:
	# Set the opposite door id.
	var opposite_id = (door_id+2)%4
	
	# Set connections to room id, for representing corridor.
	room.connections[door_id] = dungeon[room_x][room_y].id
	dungeon[room_x][room_y].connections[opposite_id] = room.id
	
	# Set doors to true for spawning doors.
	room.doors[door_id] = true
	dungeon[room_x][room_y].doors[opposite_id] = true
	
	# Set the color of the doors.
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
	# Place terminals in the dungeon. 
	for i in _colors_number:
		# Set the terminal room id.
		var room_id = randi_range(0, next_id - 1)
		while special_rooms.has(room_id): #if selected room is used, use the previous free one.
			room_id = (room_id + 1) % next_id
		
		# Add new terminal values of the terminal.
		terminals.append(make_terminal(room_id, i))
		
		# Add the terminal room to special rooms.
		special_rooms.append(terminals[i].room_id)

# Place aliens in the dungeon.
func _place_aliens() -> void:
	# Add all aliens to the memory.
	for i in alien_count:
		aliens.append(make_alien(_random_alien_location()))
	
	# Go through all of the rooms and add room position for all aliens.
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			# If there is no room at those coordinates, skip it.
			if dungeon[x][y] == null:
				continue
			
			# Set room position of all aliens inside of this room. 
			for i in aliens.size():
				if aliens[i].room_id == dungeon[x][y].id:
					aliens[i].room_pos = dungeon[x][y].pos

#---ROOM-DISPLAY------------------

# Update displayed room to the current room.
func update_room(previous_direction: String):
	# If there is previous room delete it.
	if self.get_child_count() != 0:
		# Get previous room node.
		var previous_room = self.get_child(0)
		
		# Remove previous room from display.
		self.call_deferred("remove_child", previous_room)
		previous_room.call_deferred("queue_free")
	
	# Create escape pod scene path.
	var room_path = game_manager.create_room_path(current_room.room_type)
	
	# Add current room to the active scene.
	var room: Node = load(room_path).instantiate()
	
	# Add current room to active scene.
	self.call_deferred("add_child", room)
	
	# Put Player in correct position.
	_set_player_pos(previous_direction)
	
	# Put doors in correct spots.
	_draw_doors(room, current_room)
	
	# Put escape pod in correct spot.
	_draw_escape_pod(room, current_room)
	
	# Put terminal in correct spot.
	_draw_terminal(room, current_room)
	
	# Put aliens in correct spots.
	_draw_aliens(room, current_room)
	
	# Debug print
	_print_current_room()

# Display doors in the active room.
func _draw_doors(room_scene: Node, active_room) -> void:
	# Add all doors in correct positions.
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

# Display aliens in correct spots.
func _draw_aliens(room_scene: Node, active_room) -> void:
	# Add aliens that are in this active room.
	for i in aliens.size():
		if aliens[i].room_id == active_room.id:
			room_scene.call_deferred("add_alien", i, aliens[i].pos)

# Put Player in correct location given by variable "direction" 
func _set_player_pos(direction: String) -> void:
	# Find correct spawn location
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == direction:
			# When encountered correct location spawn the Player.
			player.global_position = entrance.global_position

# Remove alien from screen.
func remove_alien_from_display(alien_id: int) -> void:
	# Search for the alien with given id on the screen. 
	var the_alien: Node
	var alien_nodes = get_tree().get_nodes_in_group("Alien")
	for alien in alien_nodes:
		if alien.alien_id == alien_id:
			the_alien = alien
			break
	
	# When there is no alien with given id, stop removing alien.
	if the_alien == null:
		return
	
	# Remove alien from display.
	self.get_child(0).call_deferred("remove_child", the_alien)
	the_alien.call_deferred("queue_free")

#---ALIEN-MOVEMENT-AI-------------

# Alien movement handler.
func _alien_movement() -> void:
	for i in aliens.size():
		# Check if alien will move.
		if (randf() <= alien_move_chance and current_room.id != aliens[i].room_id):
			# Moving to another room.
			if randf() <= alien_move_to_door_chance:
				# Check which doors are open.
				var door_ids = _alien_look_for_open_doors(i)
				
				# If there is no open doors, alien do not move.
				if door_ids.size() == 0:
					continue
				
				# Select next room for alien.
				var direction = door_ids[randi_range(0, door_ids.size() - 1)]
				
				# Move alien to the next room.
				_move_alien_to_room(i, direction)
			
			# Moving inside the room.
			else:
				_move_alien_in_room(i)

# Look for open doors.
func _alien_look_for_open_doors(alien_id: int) -> Array:
	# Make array with id of the doors that are open.
	var answer_door_ids: Array
	
	# Check doors in room with given alien.
	var x = aliens[alien_id].room_pos.x
	var y = aliens[alien_id].room_pos.y
	for i in dungeon[x][y].door_color.size():
		# If the door is open, add it the the answer array.
		if dungeon[x][y].door_color[i] == game_manager.active_color_id:
			answer_door_ids.append(i)
	
	# Return Array with found doors.
	return answer_door_ids

# Set random location of the alien.
func _random_alien_location() -> Vector2:
	var id = randi_range(0, _alien_spawn_markers.get_children().size() - 1)
	return _alien_spawn_markers.get_child(id).position

# Alien movement in room logic.
func _move_alien_in_room(alien_id: int) -> void:
	# Change alien position to random.
	aliens[alien_id].pos = _random_alien_location()

# Alien movement to room logic.
func _move_alien_to_room(alien_id: int, direction: int) -> void:
	# Select next room.
	var nx = aliens[alien_id].room_pos.x + DIRECTIONS[direction].x
	var ny = aliens[alien_id].room_pos.y + DIRECTIONS[direction].y
	var new_room = dungeon[nx][ny]
	
	# Set new room in alien data.
	aliens[alien_id].room_id = new_room.id
	aliens[alien_id].room_pos = new_room.pos
	aliens[alien_id].pos = entrance_markers.get_child(direction + 1).position
	
	# When the alien moves to the current room display them.
	if (new_room.id == current_room.id):
		self.get_child(0).call_deferred("add_alien", alien_id, aliens[alien_id].pos)

#---DEBUG-PRINT-------------------

# Main debug print
func _debug_print() -> void:
	_print_dungeon()
	#_print_connections()
	_print_terminals()
	print("Go to the room ", escape_pod.room_id)
	print("Escape pod is ",game_manager.COLORS[escape_pod.color_id])

# Print map of the dungeon.
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
	game_manager._map_generated(dungeon_as_string)

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
