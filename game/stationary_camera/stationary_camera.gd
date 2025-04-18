extends Node3D

class_name StationaryCamera

@onready var forward_direction : Marker3D = $NodeToMove/RotationNode/ForwardDirection
@onready var detection_fov : DetectionFOV = $NodeToMove/RotationNode/DetectionFOV
@onready var glint_overlay = $NodeToMove/RotationNode/MeshInstance3D

# Array of Marker3D nodes to look at
@export var markers : Array[Marker3D] = []
var current_marker_index : int = 0
var look_at_threshold : float = 0.1

@export var player : CharacterBody3D

@export var length : float = 20.0
@export var radius : float = 3.0

@onready var mesh_to_move = $"NodeToMove"

var patrol_wait_time: float = 2.0
var patrol_timer: float = 0.0

var initial_pos : Vector3

signal add_detection(instance_id: int)
signal remove_detection(instance_id: int)

enum CameraState {
	SCANNING,
	DETECTED,
	OFF
}

var bodyToFollow : Node3D

var current_state : CameraState = CameraState.SCANNING

func _ready() -> void:
	add_detection.connect(GameManager._on_add_detection)
	remove_detection.connect(GameManager._on_remove_detection)
	
	detection_fov.initialize(length, radius)
	initial_pos = forward_direction.global_position
	glint_overlay.get_active_material(0).albedo_color.a = 0.0
	
	forward_direction.top_level = true
	
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
			var direction = (target_position - mesh_to_move.global_transform.origin).normalized()
			
			# Move forward direction to next target
			forward_direction.global_position = lerp(forward_direction.global_position, target_position, delta)
			
			look_at_point(forward_direction.global_position)
			
			var forward_dir = (forward_direction.global_transform.origin - mesh_to_move.global_transform.origin).normalized()
			var dist = forward_dir.distance_to(direction)
			if  dist > -look_at_threshold and dist < look_at_threshold:
				patrol_timer += delta
					
				# Wait at the patrol point before moving to the next one
				if patrol_timer >= patrol_wait_time:
					patrol_timer = 0.0
					current_marker_index = (current_marker_index + 1) % markers.size()
		CameraState.DETECTED:
			if not bodyToFollow: 
				print("NO BODY TO FOLLOW")
				return
			glint_overlay.get_active_material(0).albedo_color.a = lerp(glint_overlay.get_active_material(0).albedo_color.a, 1.0, delta)
			var target_position = bodyToFollow.global_position
			forward_direction.global_position = lerp(forward_direction.global_position, target_position, 2.0 * delta)
			look_at_point(forward_direction.position)
		CameraState.OFF:
			pass
			
func look_at_point(target_pos : Vector3) -> void:
	# I don't even know, look_at() looks backwards for some reason
	var opposite_dir = target_pos - mesh_to_move.global_transform.origin
	mesh_to_move.look_at(global_transform.origin - opposite_dir, Vector3.UP)


func _on_detection_fov_player_detected(body: Node3D) -> void:
	current_state = CameraState.DETECTED
	bodyToFollow = body
	#game_manager.add_detection(get_instance_id())aww
	add_detection.emit(get_instance_id())

func _on_detection_fov_player_undetected() -> void:
	current_state = CameraState.SCANNING
	#game_manager.remove_detection(get_instance_id())
	remove_detection.emit(get_instance_id())
