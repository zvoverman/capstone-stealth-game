extends CharacterBody3D

class_name MovementController

@onready var detection_overlay = $CameraRootNode/CamYaw/CamPitch/SpringArm3D/Camera3D/TextureRect
@onready var ray_container = $Raycasts
@export var forward_direction_node : Marker3D

@export var detection_bar_ui : ProgressBar
@export var jump_timer_ui : ProgressBar

@export var GROUND_SPEED: float = 3
@export var HORIZONTAL_GROUND_RESISTANCE := 0.2

# Do not set this higher than MAX_HORIZONTAL_AIR_SPEED
@export var MAX_VERTICAL_JUMP_VELOCITY: float = 12

@export var HORIZONTAL_AIR_SPEED: float = 5
@export var MAX_HORIZONTAL_AIR_SPEED: float = 15
@export var HORIZONTAL_AIR_RESISTANCE: float = 0.03

@export var DASH_SPEED: float = 20

@export var GRAVITY_STRENGTH: float = 12

var gravity_direction : Vector3 = Vector3.DOWN
var current_gravity = Vector3.ZERO

var current_normal = Vector3.DOWN

var is_in_air : bool = true
var is_jumping : bool = false

var jump_direction : Vector3 = Vector3.UP
var jump_timer : float = 0.0
@export var JUMP_COOLDOWN : float = 1.5

var target_basis : Basis = Basis.IDENTITY
@export var rotation_smoothness : float = 4.0

var is_detected : bool = false
var detection_level : float = 0.0
@export var detection_level_step : float = 0.1
@export var max_detection_level : float = 1.0
var time_since_detected : float = 0.0

var leg_targets: Array

@onready var camera = $CameraRootNode/CamYaw/CamPitch/SpringArm3D/Camera3D
@onready var mesh = $Armature/Skeleton3D/Mesh

var ability_to_status: Dictionary # Dictionary[int: int] where keys = AbilityType, values = AbilityCategory

signal player_died

signal pause_game

const PlayerAbilityType = preload("res://interactable/player_ability.gd").PlayerAbilityType
const PlayerAbilityStatus = preload("res://game_manager.gd").PlayerAbilityStatus

@export var player_audio : PlayerAudio

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		player_died.emit()
	if event.is_action_pressed("pause_game"):
		pause_game.emit()

func _ready() -> void:
	player_died.connect(GameManager._on_player_died)
	
	if detection_bar_ui:
		detection_bar_ui.max_value = max_detection_level
		
	if jump_timer_ui:
		jump_timer_ui.max_value = JUMP_COOLDOWN
		
	ability_to_status = {
		PlayerAbilityType.CLIMB: PlayerAbilityStatus.UNLOCKED,
		PlayerAbilityType.JUMP: PlayerAbilityStatus.UNLOCKED
	}

func _process(delta: float) -> void:
	# Update the jump timer
	if jump_timer > 0:
		jump_timer -= delta
		#jump_timer_ui.value = jump_timer
		
	if is_detected:
		increment_detection(delta)
		detection_overlay.self_modulate.a = lerp(detection_overlay.self_modulate.a, detection_level, 5.0 * delta)
	else:
		detection_level = lerp(detection_level, 0.0, 0.1 * delta)
		if detection_bar_ui:
			detection_bar_ui.value = detection_level
		
		detection_overlay.self_modulate.a = lerp(detection_overlay.self_modulate.a, 0.0, delta)

var prev_velocity: Vector3 = Vector3.ZERO
var is_dashing: bool = false
func _physics_process(delta: float) -> void:
	
	# Calculate player orientation based on average normal of rays
	var normal = Vector3.UP
	if (ability_to_status[PlayerAbilityType.CLIMB] == PlayerAbilityStatus.UNLOCKED):
		normal = average_rays()
	if normal != Vector3.ZERO:
		current_normal = normal
	else:
		current_normal = Vector3.UP
	gravity_direction = -current_normal
		
	# Get target basis from result of raycasts + forward_direction
	target_basis = calculate_orientation(current_normal, forward_direction_node)
	
	# Knowing the new orientation, adjust the player
	var next_basis : Basis = global_transform.basis.slerp(target_basis.get_rotation_quaternion(), delta * rotation_smoothness)
	global_transform.basis = next_basis

	# No gravity if on the ground
	if is_in_air:
		current_gravity += gravity_direction * GRAVITY_STRENGTH * delta
	else:
		current_gravity = Vector3.ZERO

	# Apply speed based on current forward direction
	var direction = get_dir()
	if get_dir() != Vector3.ZERO:
		player_audio.moving()
	
	var target_velocity := Vector3.ZERO
	
	if not is_in_air:
		target_velocity += direction * GROUND_SPEED
		velocity = lerp(prev_velocity, target_velocity, HORIZONTAL_GROUND_RESISTANCE)
	else:
		target_velocity += direction * HORIZONTAL_AIR_SPEED
		velocity = lerp(prev_velocity, target_velocity, HORIZONTAL_AIR_RESISTANCE)
	
	# FIXME: This is not working as intended
	# TODO: With many movement-based abilities... this should be a State Machine
	# Check if Player has Dashed (affects HORIZONTAL movement)
	if Input.is_action_just_pressed("dash") and ability_to_status[PlayerAbilityType.DASH] == PlayerAbilityStatus.UNLOCKED:
		#is_jumping = false
		current_gravity = Vector3.ZERO
		if direction == Vector3.ZERO:
			var forwardDir: Vector3 = ( forward_direction_node.global_transform.origin - global_transform.origin ).normalized()
			var dirBase: Vector3 = current_normal.cross(forwardDir).normalized()
			var forwardMovementAxis: Vector3 = current_normal.cross(dirBase).normalized()
			velocity += -forwardMovementAxis * DASH_SPEED
		else:
			velocity += direction * DASH_SPEED
		
	
	# Toggle jump
	if Input.is_action_just_pressed("jump") and not is_jumping and jump_timer <= 0 and ability_to_status[PlayerAbilityType.JUMP] == PlayerAbilityStatus.UNLOCKED:
		is_jumping = true
		jump_direction = current_normal
			
		velocity += jump_direction * MAX_VERTICAL_JUMP_VELOCITY
		
		print(velocity)
		
		# Reset jump timer after jumping
		jump_timer = JUMP_COOLDOWN
		
		
	# Clamp velocity for Maximum value check
	var MAX_VELOCITY: Vector3 = Vector3(MAX_HORIZONTAL_AIR_SPEED, MAX_VERTICAL_JUMP_VELOCITY, MAX_HORIZONTAL_AIR_SPEED)
	velocity = clamp(velocity, -MAX_VELOCITY, MAX_VELOCITY)
	
	prev_velocity = velocity
	
	# Tracking gravity seperately - so this is down after prev_vel is assigned
	velocity += current_gravity

	# Need to check for collisions, SLIDE!
	move_and_slide()
	
	# Base player orientation on latest collision normal
	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("hazard"):
			player_death_sequence()
		elif collider.is_in_group("no_climb"):
			var collision_normal = collision.get_normal().normalized()
			# floating point precision error with ==
			if collision_normal.is_equal_approx(Vector3.UP):
				is_in_air = false;
				is_jumping = false;
			else:
				is_in_air = true;
		else:
			is_in_air = false;
			is_jumping = false;
	else:
		is_in_air = true;
		

func get_average_leg_position(targets: Array) -> Vector3:
	var avg = Vector3.ZERO
	for pos in targets:
		avg += pos
	return avg / targets.size()


# Movement direction calculation based on forward direction,
# player "forward" will always be "away" from camera
var can_move: bool = false
func get_dir() -> Vector3:
	if not can_move: return Vector3.ZERO
	
	var dir: Vector3 = Vector3.ZERO
	var forwardDir: Vector3 = ( forward_direction_node.global_transform.origin - global_transform.origin ).normalized()
	var dirBase: Vector3 = current_normal.cross(forwardDir).normalized()
	
	var inputDirection: Vector3 = Vector3.ZERO
	
	inputDirection.x = Input.get_axis("right", "left")
	inputDirection.z = Input.get_axis("forward", "backward")
	
	inputDirection = inputDirection.normalized()
		
	# Calculate the movement direction by combining the axes
	# `dirBase` handles left/right (X axis), while `forwardMovementAxis` handles forward/backward (Z axis)
	var forwardMovementAxis: Vector3 = current_normal.cross(dirBase).normalized()
	dir = forwardMovementAxis * inputDirection.z + dirBase * inputDirection.x
	
	return dir.normalized()

# Calculate player orientation
func calculate_orientation(_normal: Vector3, _forward_direction_node: Node3D) -> Basis:
	var up = _normal                        # Up direction from surface normal
	var forward = _forward_direction_node.global_transform.basis.z  # Current forward direction
	forward = forward.slide(up).normalized()       # Project forward onto surface
	var right = up.cross(forward).normalized()     # Right vector from up × forward
	forward = right.cross(up).normalized()         # Recalculate forward to ensure orthogonal
	var new_basis = Basis(right, up, forward)      # Create new basis with right, up, forward
	
	return new_basis

	
# Average the collision normals of all rays in the Raycasts node
func average_rays() -> Vector3:
	var ray_total : Vector3 = Vector3.ZERO
	var ray_count : int = 0
	var no_climb_ray_count : int = 0
	
	for ray in ray_container.get_children():
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("hazard"):
				continue
			elif collider.is_in_group("no_climb"):
				no_climb_ray_count += 1
				#ray_total += ray.get_collision_normal()
			else:
				ray_total += ray.get_collision_normal()
				ray_count += 1
	#if no_climb_ray_count > 0 and ray_count == 0:
		#return Vector3.UP
	if no_climb_ray_count > ray_count:
		return Vector3.UP
	elif ray_count > 0:
		return (ray_total/ ray_count).normalized()
	else:
		return Vector3.ZERO

### NON MOVEMENT RELATED

func increment_detection(delta : float):
	detection_level += detection_level_step * delta;
	
	# Set UI
	#detection_bar_ui.value = detection_level
	
	if detection_level >= max_detection_level:
		player_death_sequence()
		
func set_detection_level(new_value: float):
	detection_level = new_value
	#detection_bar_ui.value = detection_level
	
func player_death_sequence() -> void:
	# Temp fix to not trigger collision multiple times while death timer is active
	if not can_move: return
	
	# Start death vfx
	can_move = false
	camera._camera_shake(0.6, 0.25)
	mesh.trigger_dissolve()
	await get_tree().create_timer(1.0).timeout
	player_died.emit()

func player_respawn_sequence(_spawn_point: Node3D) -> void:
	# Handle state change
	respawn(_spawn_point)
	
	# Start respawn vfx
	mesh.trigger_reform()
	await get_tree().create_timer(1.0).timeout
	
	# Let player move after respawn_sequence ends
	can_move = true

	
func respawn(spawn_point: Node3D):
	#jump_timer_ui.value = 0
	#jump_timer = 0
	#detection_overlay.self_modulate.a = 0.0
	is_detected = false
	is_in_air = true
	is_jumping = false 
	current_gravity = Vector3.ZERO
	set_detection_level(0.0)
	velocity = Vector3.ZERO
	
	# Spawns player with orientation matching checkpoint Marker3D
	global_position = spawn_point.transform.origin
	$CameraRootNode.global_rotation = spawn_point.global_rotation
	global_rotation = spawn_point.global_rotation

# DO NOT CALL FROM PLAYER, call from GameManager
func update_abilities(new_ability_to_status: Dictionary):
	ability_to_status = new_ability_to_status
	
