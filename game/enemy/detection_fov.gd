extends Node3D

class_name DetectionFOV

@onready var detection_area : CollisionShape3D = $DetectionArea3D/CollisionShape3D

@onready var lazers_container : Node3D = $Lazers
@onready var spotlight : SpotLight3D = $SpotLight3D

@export var length : float = 15.0
@export var radius : float = 2.0
@export var lazer_rotation_speed : float = 2.0

signal player_detected
signal player_undetected

func _ready() -> void:
	# Dynamically adjust spotlight dimensions
	var angle_rad = atan2(radius, length)  # atan2(y, x) = atan(y/x) but handles all quadrants
	spotlight.spot_angle = rad_to_deg(angle_rad)
	
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
	
# Called every frame
func _process(delta):
	lazers_container.global_rotation.z += lazer_rotation_speed * delta

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		player_detected.emit()


func _on_detection_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		player_undetected.emit()
