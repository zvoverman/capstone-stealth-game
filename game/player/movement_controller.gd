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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_in_air:
		print('no grav?')
		current_gravity += gravity_direction * GRAVITY_STRENGTH * delta
	else:
		current_gravity = Vector3.ZERO
		gravity_direction = Vector3.DOWN

	if Input.is_action_just_pressed("jump"):
		var jump_direction := (transform.basis * Vector3.FORWARD).normalized()
		current_normal = Vector3.UP
		velocity.y += MAX_JUMP_VELOCITY
		velocity.z += jump_direction.z * MAX_SPEED * 2
		velocity.x += jump_direction.x * MAX_SPEED * 2
		
	velocity = MAX_SPEED * get_dir()
	velocity += current_gravity
		
	
	move_and_slide()
	
	var collision = get_last_slide_collision()
	
	var collision_count = get_slide_collision_count()
	
	for i in collision_count:
		var collision_ = get_slide_collision(i)
		var collider = collision.get_collider().name
		#if collider != 'Floor':
			#print(collider)
		
	if collision:
		#print("I collided with ", collision.get_collider().name, " with normal ", collision.get_normal())
		self.gravity_direction = -collision.get_normal()
		self.velocity = velocity.slide(collision.get_normal())
		current_normal = collision.get_normal()
		is_in_air = false;
	else:
		is_in_air = true;
		self.gravity_direction = Vector3.DOWN
		current_normal = Vector3.UP
	
func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( forward_direction.global_transform.origin - global_transform.origin  ).normalized()
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
