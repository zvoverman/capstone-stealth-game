@tool

extends Node3D

@export var distance_from_origin : float = 5.0
@export var speed : float = 2.0  # Adjust the speed of movement
@export var height : int = 16

var initial_position : float
var direction : int = 1  # 1 for right, -1 for left

@onready var mesh : CSGCylinder3D = $CSGCylinder3D6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = mesh.position.x  # Save the initial local position (x coordinate) when the node is ready.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh.height = height
	# Update the local position (x coordinate) of the laser
	mesh.position.x += speed * direction * delta
	
	# Check if the laser has moved beyond the allowed range in local space
	if mesh.position.x > initial_position + distance_from_origin:
		mesh.position.x = initial_position + distance_from_origin
		direction = -1  # Change direction to left
	elif mesh.position.x < initial_position:
		mesh.position.x = initial_position
		direction = 1  # Change direction to right
