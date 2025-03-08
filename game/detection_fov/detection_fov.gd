extends Node3D

class_name DetectionFOV

@onready var detection_area : CollisionShape3D = $DetectionArea3D/CollisionShape3D
@onready var raycast : RayCast3D = $RayCast3D

@onready var lazers_container : Node3D = $Lazers
@onready var spotlight : SpotLight3D = $SpotLight3D

@export var length : float = 20.0
@export var radius : float = 3.0
@export var lazer_rotation_speed : float = 2.0

@export var player : CharacterBody3D

var is_player_in_area : bool = false
var is_player_detected : bool = false

signal player_detected
signal player_undetected

var ray_body : Node3D

func initialize(_length: float, _radius: float) -> void:
	length = _length
	radius = _radius
	
	# Dynamically adjust spotlight dimensions
	var angle_rad = atan2(radius, length)  # atan2(y, x) = atan(y/x) but handles all quadrants
	var angle_deg = rad_to_deg(angle_rad)
	spotlight.spot_angle = angle_deg
	spotlight.spot_range = length
	
	var lazers = $Lazers
	for lazer_offset in lazers.get_children():
		var lazer: Lazer = lazer_offset.get_child(0)
		lazer.initialize(length, radius)
	
	# Dynamically build collision shape to match volume body  
	var radius_correction = radius / 4.0
	var new_convex_shape : ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	
	var points : PackedVector3Array = PackedVector3Array()
	points.append(Vector3(0, 0, 0))
	points.append(Vector3(radius - radius_correction, 0, length))
	points.append(Vector3(-radius + radius_correction, 0, length))
	points.append(Vector3(0, radius - radius_correction, length))
	points.append(Vector3(0, -radius + radius_correction, length))
	
	# Set the points for the new shape
	new_convex_shape.set_points(points)
	detection_area.shape = new_convex_shape
	
	
func _ready() -> void:
	#initialize(length, radius)
	pass
	
# Called every frame
func _process(delta):
	lazers_container.rotation.z += lazer_rotation_speed * delta
	
	if ray_body:
		raycast.global_position = global_position
		raycast.look_at(look_at_point(ray_body.global_position), Vector3.UP)
		
	if is_player_in_area:
		if not raycast.is_colliding():
			return
		
		var collider = raycast.get_collider()
		if not is_player_detected and collider.name == "PlayerDrone":
			is_player_detected = true
			player_detected.emit()
		elif is_player_detected and collider.name != "PlayerDrone":
			is_player_detected = false
			player_undetected.emit()

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		is_player_in_area = true
		ray_body = body
		

func _on_detection_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		is_player_in_area = false
		is_player_detected = false
		ray_body = null
		player_undetected.emit()
		

func look_at_point(target_pos : Vector3) -> Vector3:
	# I don't even know, look_at() looks backwards for some reason
	var opposite_dir = target_pos - global_transform.origin
	return (global_transform.origin - opposite_dir)
