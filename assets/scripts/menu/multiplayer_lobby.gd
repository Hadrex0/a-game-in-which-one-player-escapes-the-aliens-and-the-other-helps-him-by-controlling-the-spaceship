class_name MultiplayerLobby extends BaseMenu

@export var join_code: Label
@export var is_connected_one: Label
@export var is_connected_two: Label
@export var Player1: Label
@export var Player2: Label
@export var EscapeJob: Label
@export var ControlJob: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	network_handler.connect("_player_connection_changed", Callable(self,"_update_connections"))
	game_manager.connect("_switched_assignments", Callable(self,"_update_assignment"))
	join_code.text = "%s:%d" % [network_handler.IP_ADDRESS, network_handler.PORT]
	match network_handler.PLAYER_ID:
		1:
			Player1.text = "(you) PLAYER 1: "
			
		2:
			Player2.text = "(you) PLAYER 2: "
			$"LobbyMenu/LobbyContainer/ButtonsSection/Apply".hide()
			$"LobbyMenu/LobbyContainer/SplitSection/RightPaper/Margines/SettingSection/SwitchContainer/SwitchRoles".hide()
	network_handler._emit_connection_changed()
	_update_assignment()


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

func _update_assignment() -> void:
	if !game_manager.assignment:
		EscapeJob.text = "YOU"
		match network_handler.PLAYER_ID:
			1:ControlJob.text = "Player 2"
			2:ControlJob.text = "Player 1"
	else:
		ControlJob.text = "YOU"
		match network_handler.PLAYER_ID:
			1:EscapeJob.text = "Player 2"
			2:EscapeJob.text = "Player 1"

# BUTTONS
func _on_exit_button_up() -> void:
	_button_click_soud()
	network_handler.stop_server()
	game_manager.open_main_menu()

func _on_apply_button_up() -> void:
	_button_click_soud()
	game_manager.game_start()

func _on_switch_roles_button_up() -> void:
	_button_click_soud()
	game_manager._send_switch_assignments()

func _on_copy_to_clipboard_button_up() -> void:
	DisplayServer.clipboard_set(join_code.text)
