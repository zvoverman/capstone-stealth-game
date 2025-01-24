extends Node3D


@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var mesh : CSGCylinder3D = $Mesh

@export var height : float = 15.0
@export var radius : float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.radius = radius
	mesh.height = height
	mesh.position.z = -height / 2.0
	
	var radius_correction = radius / 4.0
	
	# Create a new ConvexPolygonShape3D instance
	var new_convex_shape : ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	
	# Define your custom points
	var points : PackedVector3Array = PackedVector3Array()
	points.append(Vector3(0, 0, 0))
	points.append(Vector3(radius - radius_correction, 0, -height))
	points.append(Vector3(-radius + radius_correction, 0, -height))
	points.append(Vector3(0, radius - radius_correction, -height))
	points.append(Vector3(0, -radius + radius_correction, -height))
	
	# Set the points for the new shape
	new_convex_shape.set_points(points)
	
	# Assuming you have a CollisionShape3D node
	collision_shape.shape = new_convex_shape  # Assign the new shape to the collision shape
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		if get_tree():
			get_tree().reload_current_scene()
