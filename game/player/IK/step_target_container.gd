extends Node3D

@export var offset: float = 10.0

@onready var parent = get_parent_node_3d()
@onready var previous_position = parent.global_position

func _process(_delta):
	var velocity = parent.global_position - previous_position
	global_position = parent.global_position + velocity * offset
	
	previous_position = parent.global_position
