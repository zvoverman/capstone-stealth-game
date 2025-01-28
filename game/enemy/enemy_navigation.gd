extends RigidBody3D

@export var player: CharacterBody3D
@export var game_manager : GameManager
@export var movement_speed: float = 4.0
@export var patrol_points: Array[Marker3D] = [] # Mker3D nodes for patrol points
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

enum EnemyState {
	PATROL,
	CHASE
}

var current_state : EnemyState = EnemyState.PATROL
var current_patrol_index: int = 0  # Track the current patrol point
var patrol_wait_time: float = 2.0  # Time to wait at each patrol point
var patrol_timer: float = 0.0  # Timer for waiting at patrol points

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	if patrol_points.size() > 0:
		set_movement_target(patrol_points[current_patrol_index].global_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	match current_state:
		EnemyState.CHASE:
			set_movement_target(player.global_position)
		EnemyState.PATROL:
			# Handle patrol behavior
			if patrol_points.size() > 0:
				# Move towards the current patrol point
				var target_position: Vector3 = patrol_points[current_patrol_index].global_position
				set_movement_target(target_position)
				
				# Check if we have reached the patrol point
				if global_position.distance_to(target_position) < 1.0:
					patrol_timer += delta
					
					# Wait at the patrol point before moving to the next one
					if patrol_timer >= patrol_wait_time:
						patrol_timer = 0.0
						current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			
			# Optionally, you can add logic to switch to the CHASE state if the player is detected
			# For example, if the enemy sees the player within a certain range, you can switch to CHASE
			if global_position.distance_to(player.global_position) < 3.0:  # Example chase range
				current_state = EnemyState.CHASE
				
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return
		
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
	# Rotate the enemy to face the direction they are moving
	rotate_towards_direction(new_velocity, delta)

func rotate_towards_direction(velocity: Vector3, delta: float):
	if velocity.length() > 0.1:  # Only rotate if there's a noticeable velocity
		var target_rotation = velocity.angle_to(Vector3.BACK)  # Find the angle of movement
		var current_rotation = global_transform.basis.get_euler().y  # Get the current rotation around Y-axis
		var rotation_step = 10.0 * delta  # Speed of rotation

		# Rotate smoothly towards the target rotation (interpolation between current and target rotation)
		var new_rotation = lerp_angle(current_rotation, target_rotation, rotation_step)

		# Apply the new rotation to the enemy (rotation around Y-axis)
		global_transform.basis = Basis(Vector3.UP, new_rotation)

func _on_velocity_computed(safe_velocity: Vector3):
	linear_velocity = safe_velocity

func _on_detection_fov_player_detected() -> void:
	game_manager.add_detection(get_instance_id())


func _on_detection_fov_player_undetected() -> void:
	game_manager.remove_detection(get_instance_id())
