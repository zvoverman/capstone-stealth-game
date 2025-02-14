extends Node3D

class_name Lazer

@onready var mesh : CSGCylinder3D = $CSGCylinder3D
@onready var ray_cast : RayCast3D = $RayCast3D

@export var detection_fov : DetectionFOV

var initial_length : float
var initial_position_z : float

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		var distance = ray_cast.global_transform.origin.distance_to(collision_point)

		mesh.height = distance
		mesh.position.z = distance / 2.0
		
	else:
		mesh.height = initial_length
		mesh.position.z = initial_position_z
		
func initialize(length: float, radius: float) -> void:
	initial_length = length
	initial_position_z = initial_length / 2.0
	
	ray_cast.enabled = true
	ray_cast.target_position.z = initial_length
	
	var angle_rad = atan2(detection_fov.radius, detection_fov.length)  # atan2(y, x) = atan(y/x) but handles all quadrants
	rotation.x = angle_rad
		
