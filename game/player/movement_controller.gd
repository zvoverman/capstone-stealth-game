extends CharacterBody3D

class_name MovementController

@export var forward_direction : Marker3D

@export var detection_bar_ui : ProgressBar

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
@export var rotation_smoothness : float = 4.0

var is_detected : bool = false
var detection_level : float = 0.0
@export var detection_level_step : float = 0.1
@export var max_detection_level : float = 1.0
var time_since_detected : float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		respawn()

func _ready() -> void:
	if detection_bar_ui:
		detection_bar_ui.max_value = max_detection_level

func _process(delta: float) -> void:
	if is_detected:
		increment_detection(delta)
	else:
		detection_level = lerp(detection_level, 0.0, 0.1 * delta)
		if detection_bar_ui:
			detection_bar_ui.value = detection_level

func _physics_process(delta: float) -> void:
	
	# Calculate player orientation based on average normal of rays
	var normal = average_rays()
	if normal != Vector3.ZERO:
		current_normal = normal
	else:
		current_normal = Vector3.UP
	gravity_direction = -current_normal
	target_basis = calculate_orientation()

	# No gravity if on the ground
	if is_in_air:
		current_gravity += gravity_direction * GRAVITY_STRENGTH * delta
	else:
		current_gravity = Vector3.ZERO
		
	# Knowing the new orientation, adjust the player
	var next_basis : Basis = global_transform.basis.slerp(target_basis.get_rotation_quaternion(), delta * rotation_smoothness)
	global_transform.basis = next_basis

	# Apply speed based on current forward direction
	velocity = MAX_SPEED * get_dir()
	velocity += current_gravity

	# Toggle jump
	if Input.is_action_just_pressed("jump") and not is_jumping:
		is_jumping = true
		var forwardDir : Vector3 = ( forward_direction.global_transform.origin - global_transform.origin ).normalized()
		jump_direction = (current_normal + (2 * forwardDir)).normalized()

	# Reset orientation if currently jumping
	if is_jumping:
		current_normal = Vector3.UP
		gravity_direction = Vector3.DOWN
		target_basis = calculate_orientation()
		velocity += jump_direction * MAX_JUMP_VELOCITY
		
	# Need to check for collisions, SLIDE!
	move_and_slide()
	
	# Base player orientation on latest collision normal
	var collision = get_last_slide_collision()
	if collision:
		is_in_air = false;
		is_jumping = false;
		var collider = collision.get_collider()
		if collider.is_in_group("hazard"):
			respawn()
	else:
		is_in_air = true;

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
	
# Average the collision normals of all rays in the Raycasts node
func average_rays() -> Vector3:
	var ray_container = $CollisionShape3D/Raycasts
	var ray_total : Vector3 = Vector3.ZERO
	var ray_count : int = 0
	
	for ray in ray_container.get_children():
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("no_climb"):
				continue
			else:
				ray_total += ray.get_collision_normal()
				ray_count += 1
	if ray_count > 0:
		return (ray_total / ray_count).normalized()
	else:
		return Vector3.ZERO



### NON MOVEMENT RELATED

func increment_detection(delta : float):
	detection_level += detection_level_step * delta;
	
	# Set UI
	detection_bar_ui.value = detection_level
	
	if detection_level >= max_detection_level:
		respawn()
		
func set_detection_level(new_value: float):
	detection_level = new_value
	detection_bar_ui.value = detection_level
		
func respawn():
	var game_manager = get_tree().get_root().get_node("Game/GameManager")
	game_manager.respawn()
	is_detected = false
	set_detection_level(0.0)
	
