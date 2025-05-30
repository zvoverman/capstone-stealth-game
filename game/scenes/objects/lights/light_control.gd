extends Node

@onready var spotlight: SpotLight3D = $SpotLight3D2
@onready var light_mesh: MeshInstance3D = $big_hanging_spotlight/Light

@export var isOn: bool = true

func _ready() -> void:
	if isOn:
		enable_light()
	else:
		disable_light()

func disable_light():
	spotlight.light_energy = 0.0
	light_mesh.visible = false
	
func enable_light():
	spotlight.light_energy = 1.0
	light_mesh.visible = true
