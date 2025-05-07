class_name PlayerAudio extends Node3D

@export var moving_audio_player : AudioStreamPlayer3D
@export var landing_audio_player : AudioStreamPlayer3D

var VOLUME_DB_MAX = -14.0
var VOLUME_DB_MIN = -16.0

var PITCH_SCALE_MAX = 1.2
var PITCH_SCALE_MIN = 0.8

var MOVE_AUDIO_COOLDOWN_MAX = 0.25
var MOVE_AUDIO_COOLDOWN_MIN = 0.20
var move_audio_cooldown = 0.0

func moving():
	if move_audio_cooldown <= 0.0:
		moving_audio_player.volume_db = randf_range(VOLUME_DB_MIN, VOLUME_DB_MAX)
		moving_audio_player.pitch_scale = randf_range(PITCH_SCALE_MIN, PITCH_SCALE_MAX)
		moving_audio_player.play()
		_set_random_cooldown()
	
func landing():
	landing_audio_player.play()
	
func _process(delta: float) -> void:
	move_audio_cooldown = move_audio_cooldown - delta

func _set_random_cooldown() -> void:
	move_audio_cooldown = randf_range(MOVE_AUDIO_COOLDOWN_MIN, MOVE_AUDIO_COOLDOWN_MAX)
