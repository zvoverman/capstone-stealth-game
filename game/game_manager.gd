extends Node

class_name GameManager

@export var player : CharacterBody3D

var detected_cams : Array[float] = []

var initial_player_position : Vector3 = Vector3.ZERO

var keys = {
	"green": false ,
	"blue": false,
	"red": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_player_position = player.global_position
	set_jump_power_up(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if detected_cams.size() > 0:
		player.is_detected = true
	else:
		player.is_detected = false
	
func add_detection(cam_id : float):
	detected_cams.append(cam_id)
	
func remove_detection(cam_id : float):
	detected_cams.erase(cam_id)
	
func respawn() -> void:
	player.global_position = initial_player_position
	
func set_jump_power_up(flag: bool) -> void:
	player.jump_power_up = flag
	
	
