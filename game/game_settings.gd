class_name GameSettings extends Object

enum DialogueSpeedOptions
{
	SLOW,
	DEFAULT,
	FAST
}

enum ColorBlindModeOptions
{
	OFF,
	PROTANOPIA,
	DEUTERANOPIA,
	TRITANOPIA
}

var _camera_sensitivity : float = 50.0
func get_camera_sensitivity() -> float:
	return _camera_sensitivity

var _music_volume : float = 50.0
func get_music_volume() -> float:
	return _music_volume
var _sound_effect_volume : float = 50.0
func get_sound_effect_volume() -> float:
	return _sound_effect_volume

var _dialogue_speed : DialogueSpeedOptions = DialogueSpeedOptions.DEFAULT
func get_dialogue_speed() -> DialogueSpeedOptions:
	return _dialogue_speed

var _color_blind_mode : ColorBlindModeOptions = ColorBlindModeOptions.OFF
func get_color_blind_mode() -> ColorBlindModeOptions:
	return _color_blind_mode
