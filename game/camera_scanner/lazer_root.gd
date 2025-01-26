extends Node3D

@onready var ray_cast : RayCast3D = $RayCast3D
@onready var mesh : CSGCylinder3D = $CSGCylinder3D

@export var camera : CameraScanner

var initial_height : float
var initial_position_z : float

func _ready() -> void:
	initial_height = -camera.height
	initial_position_z = mesh.position.z
	
	ray_cast.enabled = true
	ray_cast.target_position.z = initial_height
	
	var angle_rad = atan2(camera.radius, camera.height)  # atan2(y, x) = atan(y/x) but handles all quadrants
	rotation.x = angle_rad

func _process(delta: float) -> void:
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		var distance = ray_cast.global_transform.origin.distance_to(collision_point)

		mesh.height = distance
		mesh.position.z = -distance / 2.0
		
	else:
		mesh.height = initial_height
		mesh.position.z = initial_position_z
		
