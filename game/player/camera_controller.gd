extends Node3D

class_name CameraController

@export var yaw_node : Node3D
@export var pitch_node : Node3D
@export var forward_direction : Node3D
@export var node_to_follow : Node3D

@export var yaw_acceleration : float = 10
@export var pitch_acceleration : float = 10

@export var pitch_max : float = 90
@export var pitch_min : float = -90

var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07

@export var snap_speed : float = 3

var yaw : float = 0
var pitch : float = 0

const STICK_DEADZONE := 0.5
const YAW_STICK_LOOK_SPEED := 80
const PITCH_STICK_LOOK_SPEED := 30

const CARDINAL_AXES = [
	Vector3.UP,
	Vector3.DOWN,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.FORWARD,
	Vector3.BACK
]


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	yaw_sensitivity =  get_scaled_sensitivity(GameManager.get_settings().get_camera_sensitivity())
	pitch_sensitivity = get_scaled_sensitivity(GameManager.get_settings().get_camera_sensitivity())
	SettingsManager.sensitivity_changed.connect(_on_sensitivity_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not GameManager.is_paused:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
		
		# Clamp pitch to avoid flipping the camera
		pitch = clamp(pitch, pitch_min, pitch_max)
		
func check_joystick_movement() -> void:
	# Process potential controller input
	var inputDirection := Vector3.ZERO
	inputDirection.x = Input.get_axis("look_right", "look_left")
	inputDirection.y = Input.get_axis( "look_down", "look_up")
	
	if inputDirection != Vector3.ZERO:
		yaw += inputDirection.x * YAW_STICK_LOOK_SPEED * yaw_sensitivity
		pitch += inputDirection.y * PITCH_STICK_LOOK_SPEED * pitch_sensitivity
		
	pitch = clamp(pitch, pitch_min, pitch_max)

const YAW_DEADZONE := 0.1
const PITCH_DEADZONE := 0.1

func _physics_process(delta: float) -> void:
	# Follow node to follow
	self.global_position = node_to_follow.global_position
	
	self.global_basis = lerp_to_target_quat(self.global_basis, node_to_follow.global_basis, delta, snap_speed)
	
	#snap_orientation(delta)
	
	# Sensitivity retrieval
	yaw_sensitivity = get_scaled_sensitivity(GameManager.get_settings().get_camera_sensitivity())
	pitch_sensitivity = get_scaled_sensitivity(GameManager.get_settings().get_camera_sensitivity())

	check_joystick_movement()

	yaw_node.rotation_degrees.y = safe_lerp_angle(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = safe_lerp_angle(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	
	yaw = lerp(yaw, 0.0, yaw_sensitivity)
	
func _on_sensitivity_changed(new_value: float):
	yaw_sensitivity = new_value
	pitch_sensitivity = new_value
	
func get_scaled_sensitivity(x: float) -> float:
	return ((x - 1) / (100 - 1)) * (0.15 - 0.01) + 0.01
	
func snap_orientation(delta) -> void:
	# 1. Get the player's current "up" vector
	var raw_player_up = node_to_follow.global_transform.basis.y
	
	# 2. Snap it to the nearest 90-degree world axis
	var player_up = get_snapped_axis(raw_player_up)

	# 3. Get the camera's current up vector
	var camera_up = self.global_transform.basis.y.normalized()

	# 4. Only rotate if there's a misalignment
	if camera_up.dot(player_up) < 0.999:
		var axis = camera_up.cross(player_up)
		var angle = acos(clamp(camera_up.dot(player_up), -1.0, 1.0))

		if axis.length_squared() > 0.0001:
			var target_rotation = Quaternion(axis.normalized(), angle)
			var current_transform = self.global_transform			
			var current_quat = current_transform.basis.get_rotation_quaternion()
			var target_quat = (target_rotation * current_quat).normalized()
			var smoothed_quat = lerp_to_target_quat(current_quat, target_quat, delta, snap_speed)
			
			current_transform.basis = Basis(smoothed_quat)
			self.global_transform = current_transform
	
func calculate_camera_orientation(surface_normal: Vector3, forward_hint: Vector3) -> Basis:
	var up = surface_normal.normalized()
	var forward = forward_hint.slide(up).normalized()

	if forward.length_squared() < 0.0001:
		forward = Vector3.FORWARD
		if abs(up.dot(forward)) > 0.99:
			forward = Vector3.RIGHT

	var right = up.cross(forward).normalized()
	forward = right.cross(up).normalized()
	
	return Basis(right, up, forward)
	
func get_snapped_axis(input_vector: Vector3) -> Vector3:
	var best_axis = CARDINAL_AXES[0]
	var best_dot = -1.0
	for axis in CARDINAL_AXES:
		var dot = input_vector.normalized().dot(axis)
		if dot > best_dot:
			best_dot = dot
			best_axis = axis
	return best_axis
	
func lerp_to_target_quat(current_quat: Quaternion, target_quat: Quaternion, delta: float, speed: float, deadzone: float = 0.01) -> Quaternion:
	# Calculate the angle between the two quaternions
	var angle_diff = current_quat.angle_to(target_quat)

	# If the difference is small enough (within the deadzone), directly return the target quaternion
	if angle_diff < deadzone:
		return target_quat

	# Otherwise, interpolate smoothly between current and target using slerp
	var smoothed_quat = current_quat.slerp(target_quat, delta * speed)

	print(smoothed_quat)
	return smoothed_quat

func safe_lerp_angle(from: float, to: float, weight: float) -> float:
	var delta = fmod(to - from + 180.0, 360.0) - 180.0
	if abs(delta) == 180.0:
		# Force a direction (e.g., clockwise)
		delta = 180.0
	return from + delta * weight
