extends Node3D

class_name StationaryCamera

@onready var forward_direction : Marker3D = $ForwardDirection
@onready var detection_fov : DetectionFOV = $DetectionFOV
@onready var glint_overlay = $MeshInstance3D

# Array of Marker3D nodes to look at
@export var markers : Array[Marker3D] = []
var current_marker_index : int = 0
var look_at_threshold : float = 0.1

@export var game_manager : GameManager
@export var player : CharacterBody3D

@export var length : float = 20.0
@export var radius : float = 3.0

var patrol_wait_time: float = 2.0
var patrol_timer: float = 0.0

var initial_pos : Vector3

signal add_detection(instance_id: String)
signal remove_detection(instance_id: String)

enum CameraState {
	SCANNING,
	DETECTED,
	OFF
}

var current_state : CameraState = CameraState.SCANNING

func _ready() -> void:
	detection_fov.initialize(length, radius)
	initial_pos = global_position
	glint_overlay.get_active_material(0).albedo_color.a = 0.0
	
# Called every frame
func _process(delta):
	match current_state:
		CameraState.SCANNING:
			glint_overlay.get_active_material(0).albedo_color.a = lerp(glint_overlay.get_active_material(0).albedo_color.a, 0.0, 3.0 * delta)
			
			if markers.size() == 0:
				forward_direction.global_position = lerp(forward_direction.global_position, initial_pos, delta)
				return
			
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
				patrol_timer += delta
					
				# Wait at the patrol point before moving to the next one
				if patrol_timer >= patrol_wait_time:
					patrol_timer = 0.0
					current_marker_index = (current_marker_index + 1) % markers.size()
		CameraState.DETECTED:
			glint_overlay.get_active_material(0).albedo_color.a = lerp(glint_overlay.get_active_material(0).albedo_color.a, 1.0, delta)
			var target_position = player.global_position
			forward_direction.global_position = lerp(forward_direction.global_position, target_position, 2.0 * delta)
			look_at_point(forward_direction.global_position)
		CameraState.OFF:
			pass
			
func look_at_point(target_pos : Vector3) -> void:
	# I don't even know, look_at() looks backwards for some reason
	var opposite_dir = target_pos - global_transform.origin
	look_at(global_transform.origin - opposite_dir, Vector3.UP)


func _on_detection_fov_player_detected() -> void:
	current_state = CameraState.DETECTED
	#game_manager.add_detection(get_instance_id())
	add_detection.emit(get_instance_id())


func _on_detection_fov_player_undetected() -> void:
	current_state = CameraState.SCANNING
	#game_manager.remove_detection(get_instance_id())
	remove_detection.emit(get_instance_id())
