extends Node3D

@export var is_locked : bool = false
@export var key_color : String
@export var material : StandardMaterial3D

@onready var mesh_instance = $"low_poly_garage_door/Door "

var is_open : bool = false

var initial_pos : Vector3

func _ready() -> void:
	initial_pos = mesh_instance.global_position
	if (is_locked and material and mesh_instance):
		set_material(material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_open:
		mesh_instance.global_position.y = lerp(mesh_instance.global_position.y, initial_pos.y + 5, 3.0 * delta)
	else:
		mesh_instance.global_position.y = lerp(mesh_instance.global_position.y, initial_pos.y, 3.0 * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		if is_locked:
			if key_color:
				if GameManager.keys.has(key_color):
					if GameManager.keys[key_color]:
						is_open = true
		else:
			is_open = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		is_open = false
		
func set_material(new_material : StandardMaterial3D):
	mesh_instance.material = new_material
