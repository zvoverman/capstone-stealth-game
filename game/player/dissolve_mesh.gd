extends Node3D

@export var dissolve_color: Color = "#ff7349"
@export var reform_color: Color = "#4ad2ff"

var dissolve_amount = 0.0
var dissolve_speed = 0.5
var dark_dissolve_material := load("res://materials/player/dark_grey_dissolve_shader_mat.tres") as ShaderMaterial
var light_dissolve_material := load("res://materials/player/light_grey_dissolve_shader_mat.tres") as ShaderMaterial
@onready var non_dissolve_meshes : Node3D = $PlayerBodyAndMeshes/NonDissolveMeshes

var tween: Tween
var tween_2: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#dissolve_material = get_surface_override_material(0) as ShaderMaterial
	dark_dissolve_material.set_shader_parameter("dissolve_amount", 0.0)
	light_dissolve_material.set_shader_parameter("dissolve_amount", 0.0)
	non_dissolve_meshes.visible = true

func trigger_dissolve() -> void:
	non_dissolve_meshes.visible = false
	
	dark_dissolve_material.set_shader_parameter("glow_color", dissolve_color)
	light_dissolve_material.set_shader_parameter("glow_color", dissolve_color)
	
	tween = create_tween()
	tween.tween_property(dark_dissolve_material, "shader_parameter/dissolve_amount", 1.0, dissolve_speed)
	tween.tween_callback(on_dissolve_complete)
	
	tween_2 = create_tween()
	tween_2.tween_property(light_dissolve_material, "shader_parameter/dissolve_amount", 1.0, dissolve_speed)
	tween_2.tween_callback(on_dissolve_complete)

func trigger_reform() -> void:
	non_dissolve_meshes.visible = true
	
	dark_dissolve_material.set_shader_parameter("glow_color", reform_color)
	light_dissolve_material.set_shader_parameter("glow_color", reform_color)
	
	tween = create_tween()
	tween.tween_property(dark_dissolve_material, "shader_parameter/dissolve_amount", 0.0, dissolve_speed)
	tween.tween_callback(on_dissolve_complete)
	
	tween_2 = create_tween()
	tween_2.tween_property(light_dissolve_material, "shader_parameter/dissolve_amount", 0.0, dissolve_speed)
	tween_2.tween_callback(on_dissolve_complete)
	
	
func on_dissolve_complete() -> void:
	pass
