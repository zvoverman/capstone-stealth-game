extends Node3D

@export var key_color : String
@export var material : StandardMaterial3D

@onready var mesh_instance = $CSGBox3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_material(material)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		var game_manager = get_tree().get_root().get_node("Game/GameManager")
		game_manager.set_key(key_color)
		queue_free()
		
func set_material(new_material : StandardMaterial3D):
	mesh_instance.material = new_material
