extends Node

const PORT_BEGIN: int = 49152

var IP_ADDRESS: String
var PORT: int = 0
var PLAYER_ID: int = 0

# Bool to check if client can connect to the host
var can_connect: bool = false
# Variable for exeption messages
var err_message: String = ""

# Is player 1 connected
var HOST_CONNECTED: bool = false
# Is player 2 connected
var CLIENT_CONNECTED: bool = false

# Signal change of player connection
signal _player_connection_changed

var peer: ENetMultiplayerPeer

func stop_server() -> void:
	print(str(PLAYER_ID) + " STOP SERVER")
	match PLAYER_ID:
		1:
			_host_connection(false)
			_client_connection(false)
			rpc("_host_connection", false)
			print("--- Server Stopped ---")
		2:
			_client_connection(false)
			rpc("_client_connection", false)
			print("--- Client Disconnected ---")
	# Wait a second for disconnection
	var timeout := 1.0
	var timer := 0.0

	while timer < timeout:
		await get_tree().process_frame
		timer += get_process_delta_time()
	peer.close()
	multiplayer.multiplayer_peer = null
	peer = null

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	PORT = randi_range(0,16382) + PORT_BEGIN
	peer.create_server(PORT)
	IP_ADDRESS = get_local_ipv4()
	multiplayer.multiplayer_peer = peer
	PLAYER_ID = 1
	_host_connection(true)
	print("--- Server Started ---")

func start_client(ENTERED_CODE: String) -> bool:
	var connected := false
	var CODES
	can_connect = false
	peer = ENetMultiplayerPeer.new()
	if ENTERED_CODE.find(":") == -1:
		err_message = "⚠️ The code entered is in the wrong format"
		push_error(err_message)
		return false
	else:
		CODES = str(ENTERED_CODE).split(":")
		var error := peer.create_client(CODES[0], int(CODES[1]))
		if error != OK:
			err_message = "⚠️ Failed to connect to server"
			push_error(err_message)
			return false

	multiplayer.multiplayer_peer = peer

	# Wait up to 3 seconds for connection
	var timeout := 3.0
	var timer := 0.0

	while peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTING and timer < timeout:
		await get_tree().process_frame
		timer += get_process_delta_time()

	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		timer = 0
		rpc("_check_if_server_available")
		
		# Wait again to see if the server isn't full
		while !can_connect and timer < timeout:
			await get_tree().process_frame
			print(timer)
			timer += get_process_delta_time()
		
		if can_connect:
			connected = true
			PORT = int(CODES[1])
			IP_ADDRESS = CODES[0]
			PLAYER_ID = 2
			game_manager.assignment = true
			_client_connection(true)
			_host_connection(true)
			rpc("_client_connection",true)
		else:
			push_error("⚠️ Server was full")
			multiplayer.multiplayer_peer = null
			peer = null
		
	else:
		push_error("⚠️ Failed to connect to server at %s:%d" % [IP_ADDRESS, PORT])
		multiplayer.multiplayer_peer = null
		peer = null

	return connected

func get_local_ipv4() -> String:
	var addrs := IP.get_local_addresses()

	for a in addrs:
		# skip IPv6
		if a.find(":") != -1:
			continue

		# skip localhost
		if a.begins_with("127."):
			continue

		# skip APIPA garbage
		if a.begins_with("169.254."):
			continue

		# valid IPv4!
		return a

	return ""

@rpc("any_peer")
func _check_if_server_available() -> void:
	#print("CHECKING IF AVAILABLE")
	if !CLIENT_CONNECTED:
		rpc("_set_can_connect")
	else:
		rpc("_set_cant_connect")

@rpc("any_peer")
func _set_can_connect() -> void:
	can_connect = true
	#print("CAN CONNECT")

@rpc("any_peer")
func _set_cant_connect() -> void:
	can_connect = false
	#print("CANNOT CONNECT")

# Emit a signal of changed connection
@rpc("any_peer")
func _emit_connection_changed() -> void:
	emit_signal("_player_connection_changed")
	#print(str(PLAYER_ID) + " CLIENT: " + str(CLIENT_CONNECTED))
	#print(str(PLAYER_ID) + " HOST: " + str(HOST_CONNECTED))

# Host gets a signal when a client connects
@rpc("any_peer")
func _client_connection(CONNECTION: bool) -> void:
	#rpc("_send_map_to_client", dungeon_map)
	CLIENT_CONNECTED = CONNECTION
	_emit_connection_changed()
	rpc("_emit_connection_changed")

@rpc("any_peer")
func _host_connection(CONNECTION: bool) -> void:
	HOST_CONNECTED = CONNECTION
	_emit_connection_changed()
	rpc("_emit_connection_changed")
