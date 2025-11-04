class_name BaseMenu extends Node

#---CONSTANTS---------------------

#---VARIABLES---------------------

#---BUTTON-HANDLER----------------

# When mouse hovers on a button.
func _on_button_hover() -> void:
	audio_manager.play_paper_flip_sound()

# Play button click sound.
func _button_click_soud() -> void:
	audio_manager.play_paper_tear_sound()
