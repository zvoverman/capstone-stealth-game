extends Node3D

@export var is_locked : bool = false
@export var key_color : String
@export var material : StandardMaterial3D

@onready var mesh_instance = $CSGBox3D

var is_open : bool = false

var initial_pos : Vector3

var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#game_manager = get_tree().get_root().get_node("Game/GameManager")
	initial_pos = $CSGBox3D.global_position
	if (is_locked and material and mesh_instance):
		set_material(material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_open:
		$CSGBox3D.global_position.y = lerp($CSGBox3D.global_position.y, initial_pos.y + 5, 3.0 * delta)
	else:
		$CSGBox3D.global_position.y = lerp($CSGBox3D.global_position.y, initial_pos.y, 3.0 * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		if is_locked:
			if key_color:
				if game_manager.keys.has(key_color):
					if game_manager.keys[key_color]:
						is_open = true
		else:
			is_open = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		is_open = false
		
func set_material(new_material : StandardMaterial3D):
	mesh_instance.material = new_material
	
func interact():
	is_locked = false
	if game_manager:
		game_manager.set_tooltip_text("[center]A door has been opened somewhere...")
	else:
		print("No game manager??")
