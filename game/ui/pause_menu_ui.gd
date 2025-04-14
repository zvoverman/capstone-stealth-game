extends Control

@export var pause_menu : Control
@export var settings_menu : Control

func _ready() -> void:
	# TODO : Listen for pausing and unpausing on the Game Manager
	pass

func _on_game_paused() -> void:
	pause_menu.visible = true

func _on_resume_button_pressed() -> void:
	# TODO : Tell the Game Manager that we want to unpause the game
	pass

func _on_settings_button_pressed() -> void:
	pause_menu.visible = false
	settings_menu.visible = true

func _on_settings_back_button_pressed() -> void:
	settings_menu.visible = false
	pause_menu.visible = true
