extends Node3D

@export var is_locked : bool = false

var is_open : bool = false

var initial_pos : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = $CSGBox3D.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_open:
		$CSGBox3D.global_position.y = lerp($CSGBox3D.global_position.y, initial_pos.y + 3, 3.0 * delta)
	else:
		$CSGBox3D.global_position.y = lerp($CSGBox3D.global_position.y, initial_pos.y, 3.0 * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		if is_locked:
			var game_manager = get_tree().get_root().get_node("Game/GameManager")
			if game_manager.has_key:
				is_open = true
		else:
			is_open = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		is_open = false
