extends CharacterBody3D

class_name MovementController

@export var forward_direction : Marker3D

@export var MAX_SPEED: float = 3
@export var MAX_JUMP_VELOCITY: float = 10
@export var GRAVITY_STRENGTH: float = 12

var gravity_direction = Vector3.DOWN
var current_gravity = Vector3.ZERO

var current_normal = Vector3.DOWN

var is_in_air : bool = true
var is_jumping : bool = false

var jump_direction : Vector3 = Vector3.UP

var target_basis : Basis = Basis.IDENTITY
@export var rotation_smoothness : float = 10.0

func _physics_process(delta: float) -> void:
	# Reset gravity when in the air
	if is_in_air:
		current_normal = Vector3.UP
		gravity_direction = Vector3.DOWN
		target_basis = calculate_orientation()
		current_gravity += gravity_direction * GRAVITY_STRENGTH * delta
	else:
		current_gravity = Vector3.ZERO

	# Apply speed based on current forward direction
	velocity = MAX_SPEED * get_dir()
	velocity += current_gravity

	# Toggle jump
	if Input.is_action_just_pressed("jump") and not is_jumping:
		is_jumping = true
		jump_direction = current_normal

	# Reset orientation if currently jumping
	if is_jumping:
		current_normal = Vector3.UP
		gravity_direction = Vector3.DOWN
		target_basis = calculate_orientation()
		velocity += jump_direction * MAX_JUMP_VELOCITY
	
	# Slide, and then check for collisions
	move_and_slide()
	
	# Base player orientation on latest collision normal
	var collision = get_last_slide_collision()
	if collision:
		is_in_air = false
		is_jumping = false
		current_normal = collision.get_normal()
		gravity_direction = -current_normal
		velocity = velocity.slide(current_normal)
		target_basis = calculate_orientation()
	else:
		is_in_air = true
		
	var next_basis : Basis = global_transform.basis.slerp(target_basis.get_rotation_quaternion(), delta * rotation_smoothness)
	global_transform.basis = next_basis

# Movement direction calculation based on forward direction,
# player "forward" will always be "away" from camera
func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var forwardDir : Vector3 = ( forward_direction.global_transform.origin - global_transform.origin ).normalized()
	var dirBase : Vector3 = current_normal.cross(forwardDir).normalized()

	if Input.is_action_pressed("forward"):
		dir = dirBase.rotated(current_normal.normalized(), -PI/2)
	if Input.is_action_pressed("backward"):
		dir = dirBase.rotated(current_normal.normalized(), PI/2)
	if Input.is_action_pressed("left"):
		dir = dirBase
	if Input.is_action_pressed("right"):
		dir = dirBase.rotated(current_normal.normalized(), PI)
	
	return dir.normalized()

# Calculate player orientation
func calculate_orientation() -> Basis:
	var up = current_normal
	var forward = forward_direction.global_transform.basis.z
	forward = forward.slide(up).normalized()
	var right = up.cross(forward).normalized()
	forward = right.cross(up).normalized()
	var new_basis = Basis(right, up, forward)
	
	return new_basis
