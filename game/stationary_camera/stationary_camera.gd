extends Node3D

class_name StationaryCamera

@onready var forward_direction : Marker3D = $ForwardDirection
@onready var detection_fov : DetectionFOV = $DetectionFOV

# Array of Marker3D nodes to look at
@export var markers : Array[Marker3D] = []
var current_marker_index : int = 0
var look_at_threshold : float = 0.1

@export var game_manager : GameManager
@export var player : CharacterBody3D

@export var length : float = 15.0
@export var radius : float = 2.0

enum CameraState {
	SCANNING,
	DETECTED,
	OFF
}

var current_state : CameraState = CameraState.SCANNING

func _ready() -> void:
	detection_fov.length = length
	detection_fov.radius = radius
	
# Called every frame
func _process(delta):
	if markers.size() == 0:
		return
	
	match current_state:
		CameraState.SCANNING:
			# Get the target marker position
			var target_marker = markers[current_marker_index]
			var target_position = target_marker.global_position
			var direction = (target_position - global_transform.origin).normalized()
			
			# Move forward direction to next target
			forward_direction.global_position = lerp(forward_direction.global_position, target_position, delta)
			
			look_at_point(forward_direction.global_position)
			
			var forward_dir = (forward_direction.global_transform.origin - global_transform.origin).normalized()
			var dist = forward_dir.distance_to(direction)
			if  dist > -look_at_threshold and dist < look_at_threshold:
				current_marker_index = (current_marker_index + 1) % markers.size()
		CameraState.DETECTED:
			var target_position = player.global_position
			forward_direction.global_position = lerp(forward_direction.global_position, target_position, 2.0 * delta)
			look_at_point(forward_direction.global_position)
		CameraState.OFF:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_E and player.global_position.distance_to(global_position) < 1.0:
			queue_free()
			
func look_at_point(target_pos : Vector3) -> void:
	# I don't even know, look_at() looks backwards for some reason
	var opposite_dir = target_pos - global_transform.origin
	look_at(global_transform.origin - opposite_dir, Vector3.UP)


func _on_detection_fov_player_detected() -> void:
	current_state = CameraState.DETECTED
	game_manager.add_detection(get_instance_id())


func _on_detection_fov_player_undetected() -> void:
	current_state = CameraState.SCANNING
	game_manager.remove_detection(get_instance_id())
