class_name MultiplayerLobby extends BaseMenu

@export var join_code: Label
@export var is_connected_one: Label
@export var is_connected_two: Label
@export var Player1: Label
@export var Player2: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	network_handler.connect("_player_connection_changed", Callable(self,"_update_connections"))
	join_code.text = "JOIN CODE: %d" % [network_handler.PORT]
	match network_handler.PLAYER_ID:
		1:
			Player1.text = "(you) PLAYER 1: "
		2:
			Player2.text = "(you) PLAYER 2: "
			$"LobbyMenu/LobbyContainer/ButtonsSection/Apply".hide()
	network_handler._emit_connection_changed()


func _update_connections() -> void:
	if network_handler.CLIENT_CONNECTED:
		is_connected_two.text = "connected"
		is_connected_two.add_theme_color_override("font_color", Color.GREEN)
	else:
		is_connected_two.text = "disconnected"
		is_connected_two.add_theme_color_override("font_color", Color.RED)
	
	if network_handler.HOST_CONNECTED:
		is_connected_one.text = "connected"
		is_connected_one.add_theme_color_override("font_color", Color.GREEN)
	else:
		is_connected_one.text = "disconnected"
		is_connected_one.add_theme_color_override("font_color", Color.RED)

# BUTTONS
func _on_exit_button_up() -> void:
	_button_click_soud()
	network_handler.stop_server()
	game_manager.exit_to_menu()

func _on_apply_button_up() -> void:
	_button_click_soud()
	game_manager.game_start()
