extends Control

@export var main_menu : Control
@export var settings_menu : Control

@export var company_name : UiContainerDropAnimation
@export var main_menu_options : UiContainerDropAnimation
@export var settings_menu_options : UiContainerDropAnimation

func _ready():
	
	company_name.visible = true
	main_menu.visible = false
	settings_menu.visible = false
	
	# Diplay the company name
	company_name.drop_in_from_left()
	await company_name.animation_finished
	company_name.drop_out_to_right()
	await company_name.animation_finished
	
	# Display the main menu
	_main_menu_in()

func _on_start_button_pressed() -> void:
	await _main_menu_out()
	GameManager.start_game()

func _on_settings_button_pressed() -> void:
	await _main_menu_out()
	_settings_menu_in()

func _on_quit_button_pressed() -> void:
	await _main_menu_out()
	get_tree().quit()

func _on_settings_back_button_pressed() -> void:
	await _settings_menu_out()
	_main_menu_in()

func _main_menu_in() -> void:
	main_menu.visible = true
	main_menu_options.drop_in_from_above()

func _main_menu_out() -> void:
	main_menu_options.drop_out_to_below()
	await main_menu_options.animation_finished
	main_menu.visible = false
	
func _settings_menu_in() -> void:
	settings_menu.visible = true
	settings_menu_options.drop_in_from_above()

func _settings_menu_out() -> void:
	settings_menu_options.drop_out_to_below()
	await settings_menu_options.animation_finished
	settings_menu.visible = false
