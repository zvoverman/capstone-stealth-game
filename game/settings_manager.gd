extends Node

# Only using sensitivty right now -> can be easily extended later
var settings := {
	"controls": {
		"sensitivity": 0.07
	}
}

const SETTINGS_PATH := "user://settings.cfg"

signal sensitivity_changed(new_value)

func _ready():
	load_settings()

# For now, there should be no need to save_settings across sessions...
# it's set up though!
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err != OK:
		print("Settings file not found, using defaults.")
		return

	# Loop through keys to load existing values safely
	for section in settings:
		for key in settings[section]:
			settings[section][key] = config.get_value(section, key, settings[section][key])

func save_settings():
	var config = ConfigFile.new()
	for section in settings:
		for key in settings[section]:
			config.set_value(section, key, settings[section][key])
	config.save(SETTINGS_PATH)

func get_sensitivity() -> float:
	return settings["controls"]["sensitivity"]

func set_sensitivity(value: float):
	settings["controls"]["sensitivity"] = value
	save_settings()
	sensitivity_changed.emit(value)
