extends Node3D

class_name CameraController

@export var yaw_node : Node3D
@export var pitch_node : Node3D
@export var forward_direction : Node3D

@export var yaw_acceleration : float = 10
@export var pitch_acceleration : float = 10

@export var pitch_max : float = 90
@export var pitch_min : float = -90

var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07

var yaw : float = 0
var pitch : float = 0

const STICK_DEADZONE := 0.5
const YAW_STICK_LOOK_SPEED := 80
const PITCH_STICK_LOOK_SPEED := 30

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

func _physics_process(delta: float) -> void:
	# TODO: Should probably be updated by signal
	yaw_sensitivity =  get_scaled_sensitivity(GameManager.get_settings().get_camera_sensitivity())
	pitch_sensitivity = get_scaled_sensitivity(GameManager.get_settings().get_camera_sensitivity())
	
	check_joystick_movement()
	
	# Rotate the camera root's pitch, but leave yaw rotation to the player armature itself.
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	# Adjust forward direction pitch as well for better orientation control
	forward_direction.position.y = lerp(forward_direction.rotation_degrees.x, pitch, pitch_acceleration * delta)
	
	# Must bring yaw back to 0 or will endlessly rotate
	yaw = lerp(yaw, 0.0, yaw_acceleration * delta)
	
func _on_sensitivity_changed(new_value: float):
	yaw_sensitivity = new_value
	pitch_sensitivity = new_value
	
func get_scaled_sensitivity(x: float) -> float:
	return ((x - 1) / (100 - 1)) * (0.15 - 0.01) + 0.01
