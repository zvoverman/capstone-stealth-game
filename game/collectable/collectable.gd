extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body.name == "PlayerDrone":
		queue_free()
