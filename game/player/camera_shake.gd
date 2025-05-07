extends Camera3D

func _camera_shake(period: float, magnitude: float) -> void:
	var initial_transform = self.transform
	var elapsed_time = 0.0

	while elapsed_time < period:
		var t = elapsed_time / period
		var decay = exp(-4.0 * t)  # Stronger falloff; tune the factor (e.g. 3.0–6.0)
		var current_magnitude = magnitude * decay

		# Generate smooth random offset oscillating around 0
		var offset = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			0.0
		) * current_magnitude

		# Apply offset to the original position each frame
		self.transform.origin = initial_transform.origin + offset

		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	# No visible snap-back; already near original position
	self.transform = initial_transform
