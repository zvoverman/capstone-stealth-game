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
const STICK_LOOK_SPEED := 5  # how fast the stick turns the camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	yaw_sensitivity = GameManager.get_settings().get_camera_sensitivity() / 100
	pitch_sensitivity = GameManager.get_settings().get_camera_sensitivity() / 100
	SettingsManager.sensitivity_changed.connect(_on_sensitivity_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not GameManager.is_paused:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
		
		print(yaw)
		# Clamp pitch to avoid flipping the camera
		pitch = clamp(pitch, pitch_min, pitch_max)
		
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventJoypadMotion and not GameManager.is_paused:
		#if abs(event.axis_value) < STICK_DEADZONE:
			#return  # ignore slight nudges
#
		#if event.axis == JOY_AXIS_RIGHT_X:
			#yaw += -event.axis_value * STICK_LOOK_SPEED
		#elif event.axis == JOY_AXIS_RIGHT_Y:
			#pitch += -event.axis_value * STICK_LOOK_SPEED
#
		#pitch = clamp(pitch, pitch_min, pitch_max)
	

func _physics_process(delta: float) -> void:
	# Process potential controller input
	var inputDirection := Vector3.ZERO
	inputDirection.x = Input.get_axis("look_right", "look_left")
	inputDirection.y = Input.get_axis( "look_down", "look_up")
	
	if inputDirection != Vector3.ZERO:
		yaw += inputDirection.x * STICK_LOOK_SPEED
		pitch += inputDirection.y * STICK_LOOK_SPEED
	
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
