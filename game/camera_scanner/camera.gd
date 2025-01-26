extends Node3D
@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var mesh : CSGCylinder3D = $Mesh
@onready var forward_direction : Marker3D = $ForwardDirection

@export var height : float = 15.0
@export var radius : float = 2.0

# Array of Marker3D nodes to look at
@export var markers : Array[Marker3D] = []
var current_marker_index : int = 0
var look_at_threshold : float = 0.1

func _ready() -> void:
	mesh.radius = radius
	mesh.height = height
	mesh.position.z = -height / 2.0
	
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
	if markers.size() == 0:
		return
	
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


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		if get_tree():
			print("DETECTED")
			#get_tree().reload_current_scene()
