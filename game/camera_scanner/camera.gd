extends Node3D

class_name CameraScanner

@onready var collision_shape : CollisionShape3D = $DetectionArea3D/CollisionShape3D
@onready var mesh : CSGCylinder3D = $Mesh
@onready var forward_direction : Marker3D = $ForwardDirection

@export var height : float = 15.0
@export var radius : float = 2.0

# Array of Marker3D nodes to look at
@export var markers : Array[Marker3D] = []
var current_marker_index : int = 0
var look_at_threshold : float = 0.1

@export var player : CharacterBody3D
@export var game_manager : GameManager

enum CameraState {
	SCANNING,
	DETECTED,
	OFF
}

var current_state : CameraState = CameraState.SCANNING

func _ready() -> void:
	var angle_rad = atan2(radius, height)  # atan2(y, x) = atan(y/x) but handles all quadrants
	$SpotLight3D.spot_angle = rad_to_deg(angle_rad)
	
	var radius_correction = radius / 4.0
	
	var new_convex_shape : ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	
	# Dynamically build collision shape to match volume body
	var points : PackedVector3Array = PackedVector3Array()
	points.append(Vector3(0, 0, 0))
	points.append(Vector3(radius - radius_correction, 0, -height))
	points.append(Vector3(-radius + radius_correction, 0, -height))
	points.append(Vector3(0, radius - radius_correction, -height))
	points.append(Vector3(0, -radius + radius_correction, -height))
	
	# Set the points for the new shape
	new_convex_shape.set_points(points)

	collision_shape.shape = new_convex_shape
	
# Called every frame
func _process(delta):
	$Lazers.global_rotation.z += 2.0 * delta
	
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
			
			look_at(forward_direction.global_position)
			
			var forward_dir = (forward_direction.global_transform.origin - global_transform.origin).normalized()
			var dist = forward_dir.distance_to(direction)
			if  dist > -look_at_threshold and dist < look_at_threshold:
				current_marker_index = (current_marker_index + 1) % markers.size()
		CameraState.DETECTED:
			var target_position = player.global_position
			forward_direction.global_position = lerp(forward_direction.global_position, target_position, delta)
			look_at(forward_direction.global_position)
		CameraState.OFF:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_E and player.global_position.distance_to(global_position) < 1.0:
			queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		current_state = CameraState.DETECTED
		game_manager.add_detection(get_instance_id())
			

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		current_state = CameraState.SCANNING
		game_manager.remove_detection(get_instance_id())
