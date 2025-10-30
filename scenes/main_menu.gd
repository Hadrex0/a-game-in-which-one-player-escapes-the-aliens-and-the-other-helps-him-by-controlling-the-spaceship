extends Control

#----MAIN MENU-----

func _on_host_mouse_entered() -> void:
	$"SFX flip".play()

func _on_host_button_up() -> void:
	$"SFX tear".play()
	$"BGM".stop()
	get_tree().change_scene_to_file("res://scenes/map/main/dungeon.tscn")

func _on_settings_mouse_entered() -> void:
	$"SFX flip".play()

func _on_settings_button_up() -> void:
	$"SFX tear".play()
	$"main menu".hide()
	$"settings".show()

#----SETTINGS----

func _on_leave_button_up() -> void:
	$"SFX tear".play()
	$"settings".hide()
	$"main menu".show()

func _on_leave_mouse_entered() -> void:
	$"SFX flip".play()

func _on_general_2_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_music_2_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BMG"), value)

func _on_sfx_2_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
