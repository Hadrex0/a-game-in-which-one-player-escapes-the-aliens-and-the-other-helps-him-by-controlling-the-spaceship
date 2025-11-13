extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 28008

var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("--- Server Started ---")

func start_client() -> bool:
	var connected := false
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(IP_ADDRESS, PORT)
	if error != OK:
		push_error("⚠️ Failed to connect to server")
		return false

	multiplayer.multiplayer_peer = peer

	# Wait up to 3 seconds for connection
	var timeout := 3.0
	var timer := 0.0

	while peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTING and timer < timeout:
		await get_tree().process_frame
		timer += get_process_delta_time()

	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		connected = true
	else:
		push_error("⚠️ Failed to connect to server at %s:%d" % [IP_ADDRESS, PORT])
		multiplayer.multiplayer_peer = null
		peer = null

	return connected
