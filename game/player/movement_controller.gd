extends CharacterBody3D

class_name MovementController

@onready var forward_direction = $CameraRootNode/CamYaw/CamPitch/ForwardMarker

@export var MAX_SPEED = 5.0
@export var MAX_JUMP_VELOCITY = 4.5
@export var GRAVITY_STRENGTH = 9.8

var gravity_direction = Vector3.DOWN
var current_gravity = Vector3.ZERO

var current_normal = Vector3.DOWN

var is_in_air : bool = true
var is_jumping : bool = false

var jump_direction : Vector3 = Vector3.UP

func _physics_process(delta: float) -> void:
	# apply gravity if in the air
	if is_in_air:
		current_gravity += gravity_direction * GRAVITY_STRENGTH * delta
	else:
		current_gravity = Vector3.ZERO
		
	# apply speed based on current movement axis calculation
	# this overwrite the current velocity, all forces must be added after the fact...
	velocity = MAX_SPEED * get_dir()
	velocity += current_gravity
	
	if Input.is_action_just_pressed("jump"):
		is_jumping = true
		jump_direction = current_normal

	# apply jump velocity if have previously jumped
	if is_jumping:
		velocity += jump_direction * MAX_JUMP_VELOCITY
		
	move_and_slide()
	
	# base movement on last collision
	var collision = get_last_slide_collision()
		
	if collision:
		is_in_air = false;
		is_jumping = false
		#print("I collided with ", collision.get_collider().name, " with normal ", collision.get_normal())
		current_normal = collision.get_normal()
		gravity_direction = -current_normal
		velocity = velocity.slide(current_normal)
	else:
		is_in_air = true;
		current_normal = Vector3.UP
		gravity_direction = Vector3.DOWN

# get axis of movement from cross product between current normal and forward direction
func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( forward_direction.global_transform.origin - global_transform.origin  ).normalized()
	var dirBase : Vector3 = current_normal.cross( fowardDir ).normalized()
	if Input.is_action_pressed("forward"):
		dir = dirBase.rotated( current_normal.normalized(), -PI/2 )
	if Input.is_action_pressed("backward"):
		dir = dirBase.rotated( current_normal.normalized(), PI/2 )
	if Input.is_action_pressed("left"):
		dir = dirBase
	if Input.is_action_pressed("right"):
		dir = dirBase.rotated(current_normal.normalized(), PI)
	return dir.normalized()
