extends Node3D

@export var console_camera : Camera3D
@export var ui_subviewport : SubViewport

func _ready() -> void:
	
	var tween : Tween = create_tween()
	tween.tween_property(console_camera, "position", Vector3(0.0, 0.0, 1.5), 2.0).set_delay(2.0).set_trans(Tween.TRANS_CUBIC)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		
		var from : Vector3 = console_camera.project_ray_origin(event.position)
		var to : Vector3 = from + console_camera.project_ray_normal(event.position) * 1000
		
		var hit : Dictionary = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1, []))
		
		# Nothing was hit
		if not hit:
			return
			
		# Something was hit, ensure it was the console screen
		if not hit["collider"].get_parent() == self:
			return
			
		# Convert world coordinates to uv coordinates for the console screen
		var shape : CollisionShape3D = hit["collider"].find_child("CollisionShape3D")
		var position2D : Vector2 = Vector2(shape.global_position.x, shape.global_position.y)
		var size2D : Vector2 = Vector2(shape.shape.size.x, shape.shape.size.y)
		var bl : Vector2 = position2D - (size2D / 2.0);
		var dist : Vector2 = Vector2(hit["position"].x, hit["position"].y) - bl;
		var uv : Vector2 = dist / size2D;
		
		# Convert uv coordinates to screen space coordinates for the console ui
		event.position = Vector2(uv.x * ui_subviewport.size.x, ui_subviewport.size.y - (uv.y * ui_subviewport.size.y))
		
		# Send screen space input to the ui displayed on the console screen
		ui_subviewport.push_input(event, true)
