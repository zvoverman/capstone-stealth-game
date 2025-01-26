extends Node

class_name GameManager

@export var player : CharacterBody3D

var detected_cams : Array[float] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	
