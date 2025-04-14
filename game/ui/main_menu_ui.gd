extends Control

@export var main_menu : Control
@export var settings_menu : Control

func _on_start_button_pressed() -> void:
	# TODO : Tell game manager the game has started
	pass

func _on_settings_button_pressed() -> void:
	main_menu.visible = false
	settings_menu.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_settings_back_button_pressed() -> void:
	settings_menu.visible = false
	main_menu.visible = true
