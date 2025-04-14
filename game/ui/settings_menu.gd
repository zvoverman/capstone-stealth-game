extends Control

@export var dialogue_speed_slow_button : Button
@export var dialogue_speed_default_button : Button
@export var dialogue_speed_fast_button : Button

@export var color_blind_mode_off_button : Button
@export var color_blind_mode_protanopia_button : Button
@export var color_blind_mode_deuteranopia_button : Button
@export var color_blind_mode_tritanopia_button : Button

func _on_visibility_changed() -> void:
	
	# Visibility turned off
	if not visible:
		return
		
	dialogue_speed_default_button.button_pressed = true
	dialogue_speed_default_button.pressed.emit()
	
	color_blind_mode_off_button.button_pressed = true
	color_blind_mode_off_button.pressed.emit()

func _on_dialogue_speed_slow_button_pressed() -> void:
	_reset_all_dialogue_speed_buttons()
	dialogue_speed_slow_button.set_pressed_no_signal(true)
	dialogue_speed_slow_button.button_mask = 0

func _on_dialogue_speed_default_button_pressed() -> void:
	_reset_all_dialogue_speed_buttons()
	dialogue_speed_default_button.set_pressed_no_signal(true)
	dialogue_speed_default_button.button_mask = 0
	print("PRESSED")

func _on_dialogue_speed_fast_button_pressed() -> void:
	_reset_all_dialogue_speed_buttons()
	dialogue_speed_fast_button.set_pressed_no_signal(true)
	dialogue_speed_fast_button.button_mask = 0

func _reset_all_dialogue_speed_buttons() -> void:
	dialogue_speed_slow_button.set_pressed_no_signal(false)
	dialogue_speed_default_button.set_pressed_no_signal(false)
	dialogue_speed_fast_button.set_pressed_no_signal(false)
	dialogue_speed_slow_button.button_mask = MOUSE_BUTTON_MASK_LEFT
	dialogue_speed_default_button.button_mask = MOUSE_BUTTON_MASK_LEFT
	dialogue_speed_fast_button.button_mask = MOUSE_BUTTON_MASK_LEFT

func _on_color_blind_mode_off_button_pressed() -> void:
	_reset_all_color_blind_mode_buttons()
	color_blind_mode_off_button.set_pressed_no_signal(true)
	color_blind_mode_off_button.button_mask = 0

func _on_color_blind_mode_protanopia_button_pressed() -> void:
	_reset_all_color_blind_mode_buttons()
	color_blind_mode_protanopia_button.set_pressed_no_signal(true)
	color_blind_mode_protanopia_button.button_mask = 0

func _on_color_blind_mode_deuteranopia_button_pressed() -> void:
	_reset_all_color_blind_mode_buttons()
	color_blind_mode_deuteranopia_button.set_pressed_no_signal(true)
	color_blind_mode_deuteranopia_button.button_mask = 0

func _on_color_blind_mode_tritanopia_button_pressed() -> void:
	_reset_all_color_blind_mode_buttons()
	color_blind_mode_tritanopia_button.set_pressed_no_signal(true)
	color_blind_mode_tritanopia_button.button_mask = 0

func _reset_all_color_blind_mode_buttons() -> void:
	color_blind_mode_off_button.set_pressed_no_signal(false)
	color_blind_mode_protanopia_button.set_pressed_no_signal(false)
	color_blind_mode_deuteranopia_button.set_pressed_no_signal(false)
	color_blind_mode_tritanopia_button.set_pressed_no_signal(false)
	color_blind_mode_off_button.button_mask = MOUSE_BUTTON_MASK_LEFT
	color_blind_mode_protanopia_button.button_mask = MOUSE_BUTTON_MASK_LEFT
	color_blind_mode_deuteranopia_button.button_mask = MOUSE_BUTTON_MASK_LEFT
	color_blind_mode_tritanopia_button.button_mask = MOUSE_BUTTON_MASK_LEFT
