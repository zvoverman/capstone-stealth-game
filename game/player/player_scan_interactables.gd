extends Node
class_name ScanInteractables

@export var player : CharacterBody3D = null
@export var camera : Camera3D = null

@export var interact_distance : float = 10.0
var current_interactable : Interactable = null

signal focus_interactable(collider: Interactable)
signal unfocus_interactable(collider: Interactable)

func _ready():
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()
		
func _physics_process(delta: float) -> void:
	var result = shoot_ray()
	
	if result and current_interactable != result:
		current_interactable = result
		focus_interactable.emit(current_interactable)
	else:
		unfocus_interactable.emit(current_interactable)
		current_interactable = null
		

func shoot_ray() -> Interactable:
	var space_state = player.get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	
	params.from = camera.global_transform.origin
	params.to = params.from + camera.global_transform.basis.z * -interact_distance
	params.collision_mask = 1 << 3

	var result = space_state.intersect_ray(params)
	
	if result:
		var collider = result.collider
		if collider is Interactable:
			return collider
	
	return null
	
func try_interact():
	if current_interactable:
		current_interactable.interact()
