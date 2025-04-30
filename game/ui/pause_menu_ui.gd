extends Control

@export var pause_menu : Control
@export var settings_menu : Control

func _ready() -> void:
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_unpaused.connect(_on_game_unpaused)

func _on_game_paused() -> void:
	pause_menu.visible = true
	settings_menu.visible = false
	self.visible = true

func _on_game_unpaused() -> void:
	self.visible = false

func _on_resume_button_pressed() -> void:
	GameManager.unpause_game()

func _on_settings_button_pressed() -> void:
	pause_menu.visible = false
	settings_menu.visible = true

func _on_settings_back_button_pressed() -> void:
	settings_menu.visible = false
	pause_menu.visible = true

func _on_quit_button_pressed() -> void:
	GameManager.quit_to_main_menu()
