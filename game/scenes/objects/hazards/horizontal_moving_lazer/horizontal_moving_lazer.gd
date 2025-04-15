@tool

extends Node3D

@export var distance_from_origin : float = 5.0
@export var speed : float = 2.0
@export var height : int = 16

var initial_position : float
var direction : int = 1  # 1 for right, -1 for left

@onready var mesh : CSGCylinder3D = $CSGCylinder3D6

func _ready() -> void:
	initial_position = mesh.position.x 

func _process(delta: float) -> void:
	mesh.height = height
	mesh.position.x += speed * direction * delta
	
	# Check if the laser has moved beyond the allowed range in local space
	if mesh.position.x > initial_position + distance_from_origin:
		mesh.position.x = initial_position + distance_from_origin
		direction = -1
	elif mesh.position.x < initial_position:
		mesh.position.x = initial_position
		direction = 1
