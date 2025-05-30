extends ColorRect

@export var fade_duration: float = 2.0
var tween: Tween

func _ready():
	# Set initial fade state (completely black)
	material.set_shader_parameter("fade_progress", 0.0)
	
	# Start fading in
	start_fade()

func start_fade():
	tween = create_tween()
	tween.tween_method(set_fade_progress, 0.0, 1.0, fade_duration)

func fade_out():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(set_fade_progress, 1.0, 0.0, fade_duration)

func set_fade_progress(progress: float):
	material.set_shader_parameter("fade_progress", progress)
