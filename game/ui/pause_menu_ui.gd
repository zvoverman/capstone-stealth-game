extends Control

@export var pause_menu : Control
@export var settings_menu : Control

func _ready() -> void:
	print("TODO: subscribe to game_paused signal on game-manager")

func _on_game_paused() -> void:
	pause_menu.visible = true

func _on_resume_button_pressed() -> void:
	print("TODO: call resume_game on game-manager")

func _on_settings_button_pressed() -> void:
	pause_menu.visible = false
	settings_menu.visible = true

func _on_settings_back_button_pressed() -> void:
	settings_menu.visible = false
	pause_menu.visible = true
