extends ColorRect

@export var fade_duration: float = 1.0

func _ready():
	# Make it cover the whole screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color.BLACK
	modulate.a = 0.0  # Start transparent

func fade_to_black():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)

func fade_from_black():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
