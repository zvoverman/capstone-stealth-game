extends RayCast3D

@export var step_target: Node3D
var step_normal

func _physics_process(_delta):
	var hit_point = get_collision_point()
	if hit_point:
		step_target.global_position = hit_point
		step_normal = get_collision_normal()
		
func get_step_normal():
	return step_normal
