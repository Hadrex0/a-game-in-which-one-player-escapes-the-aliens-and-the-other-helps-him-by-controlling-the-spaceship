extends Node

#---CONSTANTS---------------------

# Colors of objects in game.
const COLORS: Array = [
	"Red",
	"Blue",
	"Green",
	"Yellow"
	]

#---SIGNALS-----------------------

# Signal to change assignments
signal _switched_assignments

# Signal to open/close objects on the screen.
signal color_stance_changed

# Signal to activate objects on the screen.
signal color_activation_changed

# Signal to send dungeon map
signal send_dungeon_map(map)

# Signal of a player pressing a button
signal pressed_button(color: String)

# Signal to send rooms with active life forms
signal receive_detected_rooms
signal show_detected_rooms

#---VARIABLES---------------------

# Entering debug mode
var DEBUG_MODE: bool = false

# Variables for Dungeon data.
var _dungeon: Dungeon #dungeon data
var active_color_id: int = 0 #currently active objects color
var active_button_color: String = ""
var detected_life_forms: String

# Variables for Player 1.
var _player: Player #Player data

# Decide which job player has assigned
# False = Escape
# True = Control
var assignment: bool = false

# Variables for menu.
var menu_open: bool = true #is menu open
var last_scene: String #last scene that was displayed
var game_result: String #result of the game end

#---INITIALIZE-VARIABLES----------

# Assign dungeon data.
func dungeon_init(created_dungeon: Dungeon) -> void:
	_dungeon = created_dungeon

# Assign player data.
func player_init(created_player: Player) -> void:
	_player = created_player

#---GETTERS-----------------------

# Get player data
func get_player() -> Player:
	return _player

# Get dungeon data
func get_dungeon() -> Dungeon:
	return _dungeon

#---INPUT-HANDLER-----------------

# Checking the key that was pressed.
func set_action_for_event(event):
	for action in InputMap.get_actions():
		# When ui action is pressed, but manu is not displayed ignore it.
		if (action.contains("ui_") and !menu_open):
			continue
		
		# Return pressed action.
		if event.is_action_pressed(action):
			return action
	
	# When pressed input do not match any action, return null.
	return null

# Control room listener.
func _unhandled_input(event: InputEvent) -> void:
	# Get pressed action.
	var action = set_action_for_event(event)
	if action != null:
		# Checking which action is pressed.
		match action:
			"p1_debug_mode": #entering debug mode
				DEBUG_MODE = true
			"p1_interaction": #pressed interaction key
				_interaction()
			"p2_activate_red": #change active color to red
				if DEBUG_MODE: _activate_color(COLORS.find("Red"))
			"p2_activate_blue": #change active color to blue
				if DEBUG_MODE: _activate_color(COLORS.find("Blue"))
			"p2_activate_green": #change active color to green
				if DEBUG_MODE: _activate_color(COLORS.find("Green"))
			"p2_activate_yellow": #change active color to yellow
				if DEBUG_MODE: _activate_color(COLORS.find("Yellow"))

# Player interaction.
func _interaction() -> void:
	match _player.touched_object:
		"Terminal": # Player is interacting with a terminal.
			# Find the color the interacted terminal.
			for i in COLORS.size():
				if _dungeon.terminals[i].room_id == _dungeon.current_room.id:
					# Get terminal color id.
					var color_id = _dungeon.terminals[i].color_id
					
					# Active escape pod if it matches the color.
					if color_id == _dungeon.escape_pod.color_id:
						_dungeon.escape_pod.active = true
					
					# Active the terminal.
					_dungeon.terminals[i].active = true
					color_activation_changed.emit(COLORS[color_id])
		"Button":
			emit_signal("pressed_button", active_button_color)
			_activate_button(active_button_color)

#---MAIN-MENU---------------------

# Return to main menu.
func open_main_menu() -> void:
	# A menu is open.
	game_manager.menu_open = true
	
	# Change scene to main menu.
	get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/menu/main_menu.tscn")

#---SETTINGS----------------------

# Open settings menu.
func open_settings_menu() -> void:
	# A menu is open.
	game_manager.menu_open = true
	
	# Save current scene for returning.
	last_scene = get_tree().current_scene.scene_file_path
	
	# Change scene to settings menu.
	get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/menu/settings_menu.tscn")

#---LOBBY-------------------------
func open_lobby_menu() -> void:
	# A menu is open.
	game_manager.menu_open = true
	
	# Save current scene for returning.
	last_scene = get_tree().current_scene.scene_file_path
	
	# Change scene to lobby menu.
	get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/menu/multiplayer_lobby.tscn")

# Return to previous scene.
func exit_to_menu() -> void:
	# Set menu open to correct value.
	game_manager.menu_open = last_scene.find("menu")
	
	# Change scene to main menu.
	get_tree().call_deferred("change_scene_to_file", last_scene)

#---GAME-MENU---------------------

# Game start.
func game_start() -> void:
	initialize_startnig_color()
	job_assignment()
	rpc("job_assignment")

@rpc("any_peer")
func job_assignment() -> void:
	if !assignment:
		# Change scene to dungeon for a player.
		get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/space_ship/dungeon.tscn")
	else:
		# Change scene to controls for a player.
		get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/space_ship/control_room.tscn")

# Start host.
func game_host() -> void:
	# Menu isn't active.
	game_manager.menu_open = false
	
	# Start server
	network_handler.start_server()
	
	# Change scene to Lobby as host
	open_lobby_menu()

# Join game.
func game_join(CODE: String) -> String:
	# Menu isn't active
	game_manager.menu_open = false
	
	# Awaits for connection
	var connected := await network_handler.start_client(CODE)
	
	# Enters Player 2 screen or not depending on connection
	if connected:
		open_lobby_menu()
		return ""
	else:
		return network_handler.err_message

# What happens when Player wins.
func game_won() -> void:
	game_end("won")
	rpc("game_end", "won")

# What happens when Player looses.
func game_lost() -> void:
	game_end("lost")
	rpc("game_end", "lost")

@rpc("any_peer")
func game_end(state: String) -> void:
	game_result = state
	open_game_end_menu()

#---GAME-END-MENU-----------------

# Open game end menu.
func open_game_end_menu() -> void:
	# A menu is open.
	game_manager.menu_open = true
	
	# Change scene to main menu.
	get_tree().call_deferred("change_scene_to_file", "res://assets/scenes/menu/game_end_menu.tscn")

#---CHANGING-CURRENT-ROOM---------

# Update the room in which Player to correct one.
func update_room(direction: String):
	# Set coordinates of new room.
	var nx = _dungeon.current_room.pos.x
	var ny = _dungeon.current_room.pos.y
	match direction:
		"N": #if player moved north, decrese y by one
				ny -= 1
		"E": #if player moved east, increase x by one
				nx += 1
		"S": #if player moved south, increase y by one
				ny += 1
		"W": #if player moved west, decrese x by one
				nx -= 1
	
	# Play the room changing sound.
	audio_manager.play_paper_flip_sound()
	
	# Set current room as the new one, and update screen.
	_dungeon.current_room = _dungeon.dungeon[nx][ny]
	_dungeon.update_room(direction)

#---MOVING-ALIENS-----------------

# Move alien to another room.
func move_alien(alien_id: int, direction: String) -> void:
	# Set coordinates of new room.
	var nx = _dungeon.current_room.pos.x
	var ny = _dungeon.current_room.pos.y
	match direction:
		"N": #if alien moved north, decrese y by one
				ny -= 1
		"E": #if alien moved east, increase x by one
				nx += 1
		"S": #if alien moved south, increase y by one
				ny += 1
		"W": #if alien moved west, decrese x by one
				nx -= 1
	
	# Set alien room as the new one, and update screen.
	_dungeon.aliens[alien_id].room_id = _dungeon.dungeon[nx][ny].id
	_dungeon.remove_alien_from_display(alien_id)

#--- NETWORKING ---

func _send_switch_assignments() -> void:
	_switch_assignments()
	rpc("_switch_assignments")

@rpc("any_peer")
func _switch_assignments() -> void:
	assignment = !assignment
	emit_signal("_switched_assignments")

func _map_generated(map_info: Dictionary) -> void:
	rpc("_send_map_to_client", map_info)

# Send the map to the client
@rpc("any_peer")
func _send_map_to_client(map_info_received: Dictionary) -> void:
	emit_signal("send_dungeon_map", map_info_received)

# Player 2 interaction.
@rpc("any_peer")
func _activate_color(color_id: int) -> void:
	if color_id == -1:
		return
	
	# Set previous color id and color of the door.
	var previous_color_id = active_color_id
	var door_colors = _dungeon.current_room.door_color
	
	# Play sound if the doors in the current room are changing.
	if (color_id != previous_color_id and (door_colors.has(color_id) or door_colors.has(previous_color_id))):
		audio_manager.play_door_sound()
	
	# Change active color.
	active_color_id = color_id
	color_stance_changed.emit(COLORS[color_id])
	
	# Synchronize active color across all players.
	rpc("update_active_color", active_color_id)

func _activate_button(color: String) -> void:
	var pressed_color_id = COLORS.find(color)
	if pressed_color_id != active_color_id:
		audio_manager.play_door_sound()
	
	if color == "Gray":
		rpc("_search_life_forms")
	else:
		rpc("_activate_color", pressed_color_id)

func show_entities(visible: bool) -> void:
	emit_signal("show_detected_rooms", visible)

func initialize_startnig_color() -> void:
	active_color_id = randi_range(0, COLORS.size())
	rpc("update_active_color", active_color_id)

@rpc("any_peer")
func update_active_color(new_color: int) -> void:
	active_color_id = new_color

@rpc("any_peer")
func _search_life_forms() -> void:
	var entities: Array
	
	# Add position of the Player.
	entities.append(get_dungeon().current_room.pos)
	
	# Fill with positions of aliens.
	for alien in get_dungeon().aliens:
		if entities.has(alien.room_pos):
			continue
		else:
			entities.append(alien.room_pos)
	
	rpc("_receive_life_forms", entities)

@rpc("any_peer")
func _receive_life_forms(entities: Array) -> void:
	emit_signal("receive_detected_rooms", entities)
