extends CharacterBody3D

@export var MAX_SPEED = 5.0
@export var MAX_JUMP_VELOCITY = 4.5
@export var GRAVITY_STRENGTH = 9.8

var gravity_direction = Vector3.DOWN
var current_gravity = Vector3.ZERO

var in_air = false

var current_normal = Vector3.DOWN

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		current_gravity += gravity_direction * GRAVITY_STRENGTH * delta
	else:
		current_gravity = Vector3.ZERO

	if Input.is_action_just_pressed("jump"):
		in_air = true
		var jump_direction := (transform.basis * Vector3.FORWARD).normalized()
		current_normal = Vector3.UP
		velocity.y += MAX_JUMP_VELOCITY
		velocity.z += jump_direction.z * MAX_SPEED * 2
		velocity.x += jump_direction.x * MAX_SPEED * 2
		
	velocity = MAX_SPEED * get_dir()
	velocity += current_gravity
		
	
	move_and_slide()
	
	var collision = get_last_slide_collision()
		
	if collision:
		print("I collided with ", collision.get_collider().name, " with normal ", collision.get_normal())
		self.gravity_direction = -collision.get_normal()
		self.velocity = velocity.slide(collision.get_normal())
		current_normal = collision.get_normal()
	else:
		self.gravity_direction = Vector3.DOWN
		current_normal = Vector3.UP
	
func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( $CameraRootNode/CamYaw/ForwardMarker.global_transform.origin - global_transform.origin  ).normalized()
	var dirBase : Vector3= current_normal.cross( fowardDir ).normalized()
	if Input.is_action_pressed("forward"):
		dir = dirBase.rotated( current_normal.normalized(), -PI/2 )
	if Input.is_action_pressed("backward"):
		dir = dirBase.rotated( current_normal.normalized(), PI/2 )
	if Input.is_action_pressed("left"):
		dir = dirBase
	if Input.is_action_pressed("right"):
		dir = dirBase.rotated(current_normal.normalized(), PI)
	return dir.normalized()
