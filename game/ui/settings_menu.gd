extends Control

@export var camera_sensitivity_slider : HSlider

@export var music_volume_slider : HSlider
@export var sound_effect_volume_slider : HSlider

@export var dialogue_speed_slow_button : Button
@export var dialogue_speed_default_button : Button
@export var dialogue_speed_fast_button : Button

@export var color_blind_mode_off_button : Button
@export var color_blind_mode_protanopia_button : Button
@export var color_blind_mode_deuteranopia_button : Button
@export var color_blind_mode_tritanopia_button : Button

# TODO : Put this in the game manager
#var saved_settings : GameSettings = GameSettings.new()

func _on_visibility_changed() -> void:
	
	# Visibility turned off
	if not visible:
		return
		
	# TODO: Grab current settings from game manager
	_load_settings(GameManager.get_settings())

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


func _on_save_settings_button_pressed() -> void:
	
	var settings : GameSettings = GameSettings.new()
	
	# Camera settings
	settings._camera_sensitivity = camera_sensitivity_slider.value
	
	# Audio settings
	settings._music_volume = music_volume_slider.value
	settings._sound_effect_volume = sound_effect_volume_slider.value
	
	# Dialogue settings
	if dialogue_speed_slow_button.button_pressed:
		settings._dialogue_speed = GameSettings.DialogueSpeedOptions.SLOW
	elif dialogue_speed_default_button.button_pressed:
		settings._dialogue_speed = GameSettings.DialogueSpeedOptions.DEFAULT
	elif (dialogue_speed_fast_button.button_pressed):
		settings._dialogue_speed = GameSettings.DialogueSpeedOptions.FAST

	# Color blind settings
	if color_blind_mode_off_button.button_pressed:
		settings._color_blind_mode = GameSettings.ColorBlindModeOptions.OFF
	elif color_blind_mode_protanopia_button.button_pressed:
		settings._color_blind_mode = GameSettings.ColorBlindModeOptions.PROTANOPIA
	elif color_blind_mode_deuteranopia_button.button_pressed:
		settings._color_blind_mode = GameSettings.ColorBlindModeOptions.DEUTERANOPIA
	elif color_blind_mode_tritanopia_button.button_pressed:
		settings._color_blind_mode = GameSettings.ColorBlindModeOptions.TRITANOPIA
		
	#TODO : Send setting info to game manager
	GameManager.set_settings(settings)

func _on_reset_to_default_button_pressed() -> void:
	
	# The default settings are on the settings object when it's instantiated
	var settings : GameSettings = GameSettings.new()
	
	_load_settings(settings)

func _load_settings(settings : GameSettings) -> void:
	
	# Camera settings
	camera_sensitivity_slider.value = settings.get_camera_sensitivity()
	
	# Audio settings
	music_volume_slider.value = settings.get_music_volume()
	sound_effect_volume_slider.value = settings.get_sound_effect_volume()
	
	# Dialogue settings
	match settings.get_dialogue_speed():
		GameSettings.DialogueSpeedOptions.SLOW:
			dialogue_speed_slow_button.button_pressed = true
			dialogue_speed_slow_button.pressed.emit()
		GameSettings.DialogueSpeedOptions.DEFAULT:
			dialogue_speed_default_button.button_pressed = true
			dialogue_speed_default_button.pressed.emit()
		GameSettings.DialogueSpeedOptions.FAST:
			dialogue_speed_fast_button.button_pressed = true
			dialogue_speed_fast_button.pressed.emit()

	# Color blind settings
	match settings.get_color_blind_mode():
		GameSettings.ColorBlindModeOptions.OFF:
			color_blind_mode_off_button.button_pressed = true
			color_blind_mode_off_button.pressed.emit()
		GameSettings.ColorBlindModeOptions.PROTANOPIA:
			color_blind_mode_protanopia_button.button_pressed = true
			color_blind_mode_protanopia_button.pressed.emit()
		GameSettings.ColorBlindModeOptions.DEUTERANOPIA:
			color_blind_mode_deuteranopia_button.button_pressed = true
			color_blind_mode_deuteranopia_button.pressed.emit()
		GameSettings.ColorBlindModeOptions.TRITANOPIA:
			color_blind_mode_tritanopia_button.button_pressed = true
			color_blind_mode_tritanopia_button.pressed.emit()
